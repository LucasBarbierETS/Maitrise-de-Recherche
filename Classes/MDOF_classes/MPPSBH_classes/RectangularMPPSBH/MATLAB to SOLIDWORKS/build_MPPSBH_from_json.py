# -*- coding: utf-8 -*-
import sys, os, io, csv
import win32com.client
import pythoncom
from win32com.client import VARIANT

# ============================================================
#       ENCODAGE / INITIALISATION COM
# ============================================================
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
pythoncom.CoInitialize()
empty_dispatch = VARIANT(pythoncom.VT_DISPATCH, None)

swApp = win32com.client.Dispatch("SldWorks.Application")
swApp.Visible = False

# ============================================================
#       PARAMÈTRES DE LA PLAQUE 0 (PLUS GRANDE)
# ============================================================
FIRST_PLATE_WIDTH  = 0.040   # 40 mm
FIRST_PLATE_DEPTH  = 0.040   # 40 mm
FIRST_PLATE_THICK  = 0.002   # 2 mm

# ============================================================
#       OUTILS SOLIDWORKS
# ============================================================
def select_reference_plane(part):
    for pn in ["Front Plane", "Plan de face", "Plane de face"]:
        if part.Extension.SelectByID2(pn, "PLANE", 0, 0, 0, False, 0, empty_dispatch, 0):
            return True
    return False

def create_plate_base(part, width=0.03, depth=0.03, thickness=0.002):
    if not select_reference_plane(part):
        return False

    part.SketchManager.InsertSketch(True)
    part.SketchManager.CreateCenterRectangle(0, 0, 0, width/2, depth/2, 0)
    part.SketchManager.InsertSketch(True)

    feats = part.FeatureManager.GetFeatures(True)
    sketch = None
    for f in reversed(feats):
        if f.GetTypeName2 == "ProfileFeature":
            sketch = f.Name
            break
    if sketch is None:
        return False

    part.Extension.SelectByID2(sketch, "SKETCH", 0, 0, 0, False, 0, empty_dispatch, 0)

    feat = part.FeatureManager.FeatureExtrusion2(
        True, False, False, 0, 0,
        thickness, 0,
        False, False, False, False,
        0, 0,
        False, False, False, False,
        True, True, True,
        0, 0,
        False
    )

    part.EditRebuild3
    return feat is not None

def add_plate_perforations(part, points):
    part.EditRebuild3
    bodies = part.GetBodies2(0, False)
    if not bodies:
        return

    body = bodies[0]
    faces = body.GetFaces()
    top = None
    for face in faces:
        n = face.Normal
        if n and abs(n[2] - 1) < 1e-3:
            top = face
            break
    if not top:
        return

    top.Select2(False, 0)
    part.SketchManager.InsertSketch(True)
    for x, y, r in points:
        part.SketchManager.CreateCircleByRadius(x, y, 0, r)
    part.SketchManager.InsertSketch(True)

    part.FeatureManager.FeatureCut4(
        True, False, False, 0, 0,
        0.01, 0.01,
        False, False, False, False,
        0.01745, 0.01745,
        False, False, False, False,
        False, True, True, True, True,
        False, 0, 0, False, False
    )
    part.EditRebuild3

def create_cavity_block(part, width_m, depth_m, thick_m):
    if not select_reference_plane(part):
        return False

    part.SketchManager.InsertSketch(True)
    part.SketchManager.CreateCenterRectangle(0, 0, 0, width_m/2, depth_m/2, 0)
    part.SketchManager.InsertSketch(True)

    feats = part.FeatureManager.GetFeatures(True)
    sketch = None
    for f in reversed(feats):
        if f.GetTypeName2 == "ProfileFeature":
            sketch = f.Name
            break
    if sketch is None:
        return False

    part.Extension.SelectByID2(sketch, "SKETCH", 0, 0, 0, False, 0, empty_dispatch, 0)

    feat = part.FeatureManager.FeatureExtrusion2(
        True, False, False, 0, 0,
        thick_m, 0,
        False, False, False, False,
        0, 0,
        False, False, False, False,
        True, True, True,
        0, 0,
        False
    )

    part.EditRebuild3
    return feat is not None

def create_cavity_ring(part, width_m, depth_m, thick_m, wall=0.001):
    part.EditRebuild3
    bodies = part.GetBodies2(0, False)
    if not bodies:
        return False

    body = bodies[0]
    faces = body.GetFaces()

    # face Z+
    top_face = None
    for face in faces:
        normal = face.Normal
        if normal and abs(normal[2] - 1) < 1e-3:
            top_face = face
            break
    if not top_face:
        return False

    top_face.Select2(False, 0)
    part.SketchManager.InsertSketch(True)

    # intérieur
    inner_w = width_m/2 - wall
    inner_d = depth_m/2 - wall
    part.SketchManager.CreateCenterRectangle(0, 0, 0, inner_w, inner_d, 0)
    part.SketchManager.InsertSketch(True)

    part.FeatureManager.FeatureCut4(
        True, False, False, 0, 0,
        thick_m, thick_m,
        False, False, False, False,
        0.01745, 0.01745,
        False, False, False, False,
        False, True, True, True, True,
        False, 0, 0, False, False
    )

    part.EditRebuild3
    return True

# ============================================================
#                 SCRIPT PRINCIPAL
# ============================================================

if len(sys.argv) < 2:
    print("[✗] Usage : python build_MPPSBH_from_json.py <dossier>")
    sys.exit(1)

base = sys.argv[1]
coord_folder = os.path.join(base, "Coordonnées des perforations")
out_folder = os.path.join(base, "fichiers_sldprt")

os.makedirs(out_folder, exist_ok=True)

plates_folder = os.path.join(out_folder, "Plaques")
cav_folder = os.path.join(out_folder, "Cavites")
os.makedirs(plates_folder, exist_ok=True)
os.makedirs(cav_folder, exist_ok=True)

csvs = [f for f in os.listdir(coord_folder) if f.lower().endswith(".csv")]
plate_csvs = [f for f in csvs if f.lower().startswith("plaque_")]
cav_csv = next((f for f in csvs if "cav" in f.lower()), None)

# ============================================================
#         PLAQUE 0 — PLAQUE SPÉCIALE PLUS GRANDE
# ============================================================

print("[+] Création plaque 0")

swApp.NewDocument(
    "C:\\ProgramData\\SOLIDWORKS\\SOLIDWORKS 2025\\templates\\Pièce.prtdot",
    0, 0, 0
)
part = swApp.ActiveDoc

create_plate_base(
    part,
    width=FIRST_PLATE_WIDTH,
    depth=FIRST_PLATE_DEPTH,
    thickness=FIRST_PLATE_THICK
)

outpath0 = os.path.join(plates_folder, "plaque_0.SLDPRT")
part.SaveAs3(outpath0, 0, 2)
swApp.CloseDoc(part.GetTitle)

# ============================================================
#         PLAQUES CLASSIQUES (AVEC PERFORATIONS)
# ============================================================

for csv_file in plate_csvs:
    print(f"[+] Plaque : {csv_file}")

    points = []
    with open(os.path.join(coord_folder, csv_file)) as f:
        rd = csv.DictReader(f)
        for row in rd:
            points.append((
                float(row["X"]) / 1000,
                float(row["Y"]) / 1000,
                float(row["R"]) / 1000
            ))

    swApp.NewDocument(
        "C:\\ProgramData\\SOLIDWORKS\\SOLIDWORKS 2025\\templates\\Pièce.prtdot",
        0, 0, 0
    )
    part = swApp.ActiveDoc

    create_plate_base(part)
    add_plate_perforations(part, points)

    outpath = os.path.join(plates_folder, csv_file.replace(".csv", ".SLDPRT"))
    part.SaveAs3(outpath, 0, 2)
    swApp.CloseDoc(part.GetTitle)

# ============================================================
#                 CAVITÉS
# ============================================================

if cav_csv:
    with open(os.path.join(coord_folder, cav_csv)) as f:
        rd = csv.DictReader(f)
        for row in rd:
            idx = int(row["Index"])
            width_m = float(row["Width_mm"]) / 1000
            depth_m = float(row["Depth_mm"]) / 1000
            thick_m = float(row["Thickness_mm"]) / 1000

            swApp.NewDocument(
                "C:\\ProgramData\\SOLIDWORKS\\SOLIDWORKS 2025\\templates\\Pièce.prtdot",
                0, 0, 0
            )
            part = swApp.ActiveDoc

            block_ok = create_cavity_block(part, width_m, depth_m, thick_m)
            if block_ok:
                create_cavity_ring(part, width_m, depth_m, thick_m)

            outpath = os.path.join(cav_folder, f"cavite_{idx}.SLDPRT")
            part.SaveAs3(outpath, 0, 2)
            swApp.CloseDoc(part.GetTitle)


print("[✓] Génération plaques + cavités terminée.")
