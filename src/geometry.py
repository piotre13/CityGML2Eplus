import math


def parse_poslist(text: str, dim: int = 3) -> list:
    """Parse gml:posList text → list of (x,y,z) tuples; drop closing duplicate vertex."""
    vals = [float(v) for v in text.strip().split()]
    verts = [tuple(vals[i:i+dim]) for i in range(0, len(vals), dim)]
    if len(verts) > 1 and verts[-1] == verts[0]:
        verts = verts[:-1]
    return verts


def compute_origin(all_verts_lists: list) -> tuple:
    """min corner (x, y, z) over all vertex lists."""
    min_x = min_y = min_z = float('inf')
    for verts in all_verts_lists:
        for x, y, z in verts:
            if x < min_x:
                min_x = x
            if y < min_y:
                min_y = y
            if z < min_z:
                min_z = z
    if min_x == float('inf'):
        return (0.0, 0.0, 0.0)
    return (min_x, min_y, min_z)


def translate_verts(verts: list, origin: tuple) -> list:
    ox, oy, oz = origin
    return [(x - ox, y - oy, z - oz) for x, y, z in verts]


def newell_normal(verts: list) -> tuple:
    """Newell's method normal (unit vector)."""
    n = len(verts)
    nx = ny = nz = 0.0
    for i in range(n):
        cur = verts[i]
        nxt = verts[(i + 1) % n]
        nx += (cur[1] - nxt[1]) * (cur[2] + nxt[2])
        ny += (cur[2] - nxt[2]) * (cur[0] + nxt[0])
        nz += (cur[0] - nxt[0]) * (cur[1] + nxt[1])
    mag = math.sqrt(nx * nx + ny * ny + nz * nz)
    if mag < 1e-10:
        return (0.0, 0.0, 1.0)
    return (nx / mag, ny / mag, nz / mag)


def centroid(verts: list) -> tuple:
    n = len(verts)
    return (
        sum(v[0] for v in verts) / n,
        sum(v[1] for v in verts) / n,
        sum(v[2] for v in verts) / n,
    )


def simplify_to_quad(verts: list) -> list:
    """
    Reduce polygon to ≤4 vertices by computing the bounding rectangle
    in the polygon's own plane. Used for FenestrationSurface:Detailed
    which E+ limits to max 4 vertices.
    """
    if len(verts) <= 4:
        return verts

    normal = newell_normal(verts)

    # Build orthonormal basis in the polygon plane
    nx, ny, nz = normal
    if abs(nx) < 0.9:
        u = _normalize3((1.0 - nx*nx, -nx*ny, -nx*nz))
    else:
        u = _normalize3((-ny*nx, 1.0 - ny*ny, -ny*nz))
    v = (
        normal[1]*u[2] - normal[2]*u[1],
        normal[2]*u[0] - normal[0]*u[2],
        normal[0]*u[1] - normal[1]*u[0],
    )

    # Project vertices to 2D
    proj = [(_dot3(pt, u), _dot3(pt, v)) for pt in verts]

    # Axis-aligned bounding box in 2D
    min_u = min(p[0] for p in proj)
    max_u = max(p[0] for p in proj)
    min_v = min(p[1] for p in proj)
    max_v = max(p[1] for p in proj)

    # Reference point on the polygon plane (use first vertex)
    origin_3d = verts[0]
    ou, ov = _dot3(origin_3d, u), _dot3(origin_3d, v)

    # 4 corners of bounding box in 3D
    def to_3d(pu, pv):
        du, dv = pu - ou, pv - ov
        return (
            origin_3d[0] + du*u[0] + dv*v[0],
            origin_3d[1] + du*u[1] + dv*v[1],
            origin_3d[2] + du*u[2] + dv*v[2],
        )

    # Return in counterclockwise order (matching vertex entry direction)
    return [
        to_3d(min_u, min_v),
        to_3d(max_u, min_v),
        to_3d(max_u, max_v),
        to_3d(min_u, max_v),
    ]


def _dot3(a, b):
    return a[0]*b[0] + a[1]*b[1] + a[2]*b[2]


def _normalize3(v):
    mag = math.sqrt(v[0]**2 + v[1]**2 + v[2]**2)
    if mag < 1e-12:
        return v
    return (v[0]/mag, v[1]/mag, v[2]/mag)


def orient_outward(verts: list, inside_ref: tuple) -> list:
    """
    Ensure Newell normal points away from inside_ref (zone centroid).
    E+ GlobalGeometryRules = Counterclockwise → outward normal.
    """
    if len(verts) < 3:
        return verts
    normal = newell_normal(verts)
    c = centroid(verts)
    dx = inside_ref[0] - c[0]
    dy = inside_ref[1] - c[1]
    dz = inside_ref[2] - c[2]
    dot = normal[0] * dx + normal[1] * dy + normal[2] * dz
    # Positive dot = normal points toward interior → flip
    if dot > 0:
        return list(reversed(verts))
    return verts
