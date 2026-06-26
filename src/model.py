from dataclasses import dataclass, field
from typing import Optional, Union


@dataclass
class Material:
    id: str
    conductivity: float   # W/(m·K)
    density: float        # kg/m³
    specific_heat: float  # J/(kg·K)
    thickness: float      # m (canonical; overridden per layer in Construction)


@dataclass
class NoMassMaterial:
    id: str
    r_value: float  # m²·K/W


@dataclass
class GasMaterial:
    id: str
    thickness: float  # m
    gas_type: str = "Air"
    r_value: float = 0.18  # m²K/W — ISO 6946 still air gap default


@dataclass
class Construction:
    id: str
    kind: str  # 'opaque' | 'glazing'
    # Layered: list of (material_id, thickness_m)
    layers: list = field(default_factory=list)
    # U-value path
    u: Optional[float] = None
    g: Optional[float] = None   # SHGC / g-value
    visible_transmittance: Optional[float] = None


@dataclass
class Opening:
    id: str
    verts: list        # [(x,y,z), ...]  — local coords
    constr_id: Optional[str]


@dataclass
class Surface:
    id: str
    stype: str         # 'wall' | 'roof' | 'ground' | 'floor' | 'interior' | 'party'
    verts: list        # [(x,y,z), ...]  — local coords
    constr_id: Optional[str]
    boundary: str      # 'outdoors' | 'ground' | 'adiabatic' | 'surface'
    adj_surface_id: Optional[str] = None
    openings: list = field(default_factory=list)


@dataclass
class Zone:
    id: str
    name: str
    surfaces: list = field(default_factory=list)


@dataclass
class BuildingModel:
    id: str
    name: str
    origin_xyz: tuple  # (ox, oy, oz)
    zones: list = field(default_factory=list)
    constructions: dict = field(default_factory=dict)  # id -> Construction
    materials: dict = field(default_factory=dict)      # id -> Material|NoMassMaterial|GasMaterial
