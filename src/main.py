"""
CLI entry point: parse GML → write one IDF per building.

Usage:
    python -m src.main --input samples/Alderaan_Energy_ADE_All.gml \
        [--libraries samples/lib.gml ...] \
        [--archetypes data/archetypes.csv] \
        [--outdir outputs] \
        [--lod 2|3] \
        [--verbose]
"""
import argparse
import logging
import sys

from .parse_gml import parse_gml
from .idf_writer import write_idf
from .archetypes import ArchetypeTable


def main():
    parser = argparse.ArgumentParser(description="CityGML 2.0 + EnergyADE 3.0 → EnergyPlus 26.1 IDF converter")
    parser.add_argument('--input', required=True, help="Main GML file path")
    parser.add_argument('--libraries', nargs='*', default=[], metavar='FILE',
                        help="Additional GML library files for cross-file xlink resolution")
    parser.add_argument('--archetypes', default=None,
                        help="Archetype CSV/XLSX table (default: data/archetypes.csv alongside this script)")
    parser.add_argument('--outdir', default='outputs', help="Output directory for IDF files")
    parser.add_argument('--lod', choices=['2', '3'], default='2',
                        help="Preferred LoD for surface geometry (2 or 3, default 2)")
    parser.add_argument('--verbose', '-v', action='store_true')
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format='%(levelname)s %(name)s: %(message)s',
        stream=sys.stderr,
    )

    # Locate archetype table
    archetype_path = args.archetypes
    if not archetype_path:
        import os
        here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        default_path = os.path.join(here, 'data', 'archetypes.csv')
        if os.path.exists(default_path):
            archetype_path = default_path

    archetype_table = None
    if archetype_path:
        try:
            archetype_table = ArchetypeTable(archetype_path)
            logging.getLogger(__name__).info("Loaded archetype table: %s", archetype_path)
        except Exception as e:
            logging.getLogger(__name__).warning("Failed to load archetypes from %s: %s", archetype_path, e)

    buildings = parse_gml(
        main_file=args.input,
        library_files=args.libraries or None,
        archetype_table=archetype_table,
        prefer_lod=args.lod,
    )

    if not buildings:
        logging.getLogger(__name__).warning("No buildings found in %s", args.input)
        return

    for bm in buildings:
        path = write_idf(bm, args.outdir)
        print(path)

    print(f"\nWrote {len(buildings)} IDF(s) to {args.outdir}/", file=sys.stderr)


if __name__ == '__main__':
    main()
