# -*- coding: utf-8 -*-
import sys, os, io, csv
import win32com.client
import pythoncom
from win32com.client import VARIANT

# === Gestion de l'encodage UTF-8 et compatibilité avec les chemins accentués ===
# (avant toute interaction COM ou accès à SolidWorks)
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

# Correction automatique du chemin d'entrée si accentué et mal décodé
if len(sys.argv) > 1:
    try:
        input_arg = sys.argv[1]
        if not os.path.exists(input_arg):
            # Tentative de recodage en UTF-8 (cas des chemins avec accents mal lus)
            alt_path = input_arg.encode('latin1').decode('utf-8', errors='replace')
            if os.path.exists(alt_path):
                sys.argv[1] = alt_path
                print(f"[i] Chemin corrigé automatiquement : {sys.argv[1]}")
    except Exception as e:
        print(f"[!] Avertissement : problème d'encodage sur le chemin ({e})")

# === Initialisation COM ===
sys.stdout.reconfigure(encoding='utf-8')
pythoncom.CoInitialize()
empty_dispatch = VARIANT(pythoncom.VT_DISPATCH, None)

# Connexion à SolidWorks
swApp = win32com.client.Dispatch("SldWorks.Application")
swApp.Visible = False

# === Fonctions utilitaires ===
def delete_existing_perforations(part):
    print("[~] Suppression des perforations existantes...")
    features = part.FeatureManager.GetFeatures(True)
    to_delete = []

    for feat in features:
        try:
            type_name = feat.GetTypeName2
            name = feat.Name
            if type_name in ["ICE", "ProfileFeature", "CutExtrude"] and (
                "Perforation" in name or "Sketch_Perforation" in name
            ):
                to_delete.append(name)
        except Exception as e:
            print(f"[!] Erreur lors du balayage : {e}")

    for name in to_delete:
        try:
            part.Extension.SelectByID2(name, "BODYFEATURE", 0, 0, 0, False, 0, empty_dispatch, 0)
            part.EditDelete
            print(f"[✓] Supprimé : {name}")
        except:
            print(f"[!] Échec de suppression : {name}")
    part.ClearSelection2(True)


def create_base_plate(part):
    print("[+] Création de la plaque de base...")

    # --- Sélection du plan de référence ---
    plan_names = ["Front Plane", "Plane de face", "Plan de face"]
    selected = False
    for pname in plan_names:
        if part.Extension.SelectByID2(pname, "PLANE", 0, 0, 0, False, 0, empty_dispatch, 0):
            print(f"[i] Plan sélectionné : {pname}")
            selected = True
            break
    if not selected:
        print("[✗] Aucun plan de référence sélectionné — création annulée.")
        return

    # --- Création d'une esquisse centrée sur ce plan ---
    part.SketchManager.InsertSketch(True)
    part.SketchManager.CreateCenterRectangle(0, 0, 0, 0.015, 0.015, 0)
    part.SketchManager.InsertSketch(True)  # Ferme le sketch

    # --- Vérifie la dernière esquisse créée ---
    feats = part.FeatureManager.GetFeatures(True)
    sketch_name = None
    for feat in reversed(feats):
        if feat.GetTypeName2 == "ProfileFeature":
            sketch_name = feat.Name
            print(f"[i] Esquisse détectée : {sketch_name}")
            break
    if not sketch_name:
        print("[✗] Aucune esquisse trouvée après la création du rectangle.")
        return

    # --- Sélectionne explicitement cette esquisse pour l'extrusion ---
    ok = part.Extension.SelectByID2(sketch_name, "SKETCH", 0, 0, 0, False, 0, empty_dispatch, 0)
    if not ok:
        print(f"[✗] Impossible de sélectionner l'esquisse {sketch_name}")
        return

    # --- Crée l'extrusion ---
    feat = part.FeatureManager.FeatureExtrusion2(
        True,  # BossExtrude
        False, False,
        0, 0,
        0.002, 0.0,  # 2 mm d'épaisseur
        False, False, False, False,
        0, 0,
        False, False, False, False,
        True, True, True,
        0, 0,
        False
    )

    # --- Validation ---
    part.EditRebuild3
    if feat:
        feat.Name = "Base_Plate"
        print("[✓] Extrusion 'Base_Plate' créée avec succès.")
    else:
        print("[✗] Échec de l'extrusion — vérifie le sketch ou le plan.")

    # --- Reconstruction forcée pour exposer le corps ---
    part.ForceRebuild3(False)
    bodies = part.GetBodies2(0, False)
    if bodies:
        print(f"[✓] Corps solides détectés : {len(bodies)}")
    else:
        print("[!] Aucun corps détecté après extrusion.")


def add_perforations(part, points):
    print("[+] Ajout des perforations...")

    # === Forcer la reconstruction et récupérer le corps ===
    part.EditRebuild3
    bodies = part.GetBodies2(0, False)

    # Vérification robuste
    if not bodies:
        print("[!] Aucun corps détecté, tentative de reconstruction complète...")
        part.ForceRebuild3(False)
        bodies = part.GetBodies2(0, False)
        if not bodies:
            print("[✗] Impossible de récupérer le corps solide. Vérifie que la plaque de base a bien été créée.")
            return

    body = bodies[0]

    faces = body.GetFaces()
    if not faces:
        print("[!] Aucun plan de face détecté.")
        return

    # === Recherche de la face supérieure ===
    top_face = None
    for face in faces:
        try:
            normal = face.Normal
            if normal and abs(normal[2] - 1.0) < 1e-3:
                top_face = face
                break
        except Exception:
            continue

    if not top_face:
        print("[!] Aucune face supérieure trouvée, perforations ignorées.")
        return

    # === Création des trous ===
    top_face.Select2(False, 0)
    part.SketchManager.InsertSketch(True)
    for x, y, r in points:
        part.SketchManager.CreateCircleByRadius(x, y, 0, r)
        print(f"[✓] Trou ajouté : x={x:.3f}, y={y:.3f}, r={r:.3f}")
    part.SketchManager.InsertSketch(True)

    # Renommer l’esquisse
    features = part.FeatureManager.GetFeatures(True)
    sketch_name = None
    for feat in reversed(features):
        if feat.GetTypeName2 == "ProfileFeature":
            sketch_name = feat.Name
            feat.Name = "Sketch_Perforations"
            break

    # Découpe
    if sketch_name:
        part.Extension.SelectByID2("Sketch_Perforations", "SKETCH", 0, 0, 0, False, 0, empty_dispatch, 0)
        feat = part.FeatureManager.FeatureCut4(
            True, False, False, 0, 0, 0.01, 0.01, False, False, False, False,
            0.01745, 0.01745, False, False, False, False,
            False, True, True, True, True, False, 0, 0, False, False
        )
        if feat:
            feat.Name = "Cut_Perforations"
        part.EditRebuild3


# === Script principal ===
if len(sys.argv) < 2:
    print("[✗] Usage : python build_MPPSBH_from_json.py <chemin_du_dossier>")
    sys.exit(1)

base_folder = sys.argv[1]
coord_folder = os.path.join(base_folder, "Coordonnées des perforations")
out_folder = os.path.join(base_folder, "fichiers_sldprt")
os.makedirs(out_folder, exist_ok=True)

csv_files = sorted(f for f in os.listdir(coord_folder) if f.endswith(".csv"))
if not csv_files:
    print(f"[!] Aucun fichier CSV trouvé dans : {coord_folder}")
    sys.exit(1)

for csv_file in csv_files:
    print("=" * 60)
    print(f"[>] Fichier : {csv_file}")
    csv_path = os.path.join(coord_folder, csv_file)

    # Lecture des trous
    points = []
    with open(csv_path, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            try:
                x = float(row['X']) / 1000
                y = float(row['Y']) / 1000
                r = float(row['R']) / 1000
                points.append((x, y, r))
            except Exception as e:
                print(f"[!] Ligne invalide : {row} -> {e}")

    part_filename = csv_file.replace(".csv", ".SLDPRT")
    part_path = os.path.join(out_folder, part_filename)

    if os.path.exists(part_path):
        print(f"[•] Ouverture de la pièce existante : {part_filename}")
        longstatus = VARIANT(pythoncom.VT_BYREF | pythoncom.VT_I4, 0)
        longwarnings = VARIANT(pythoncom.VT_BYREF | pythoncom.VT_I4, 0)
        part = swApp.OpenDoc6(part_path, 1, 0, "", longstatus, longwarnings)
        if part is None:
            print("[!] Échec de l’ouverture du fichier.")
            continue
        delete_existing_perforations(part)
    else:
        print(f"[+] Création de la nouvelle pièce : {part_filename}")
        part = swApp.NewDocument("C:\\ProgramData\\SOLIDWORKS\\SOLIDWORKS 2025\\templates\\Pièce.prtdot", 0, 0.0, 0.0)
        part = swApp.ActiveDoc
        create_base_plate(part)

    add_perforations(part, points)

    part.EditRebuild3
    
    # === Sauvegarde robuste ===
    errors = VARIANT(pythoncom.VT_BYREF | pythoncom.VT_I4, 0)
    warnings = VARIANT(pythoncom.VT_BYREF | pythoncom.VT_I4, 0)

    # Enregistrement explicite du chemin complet
    print(f"[i] Sauvegarde dans : {part_path}")
    ok = part.SaveAs3(part_path, 0, 2)  # (fichier, options, warnings)
    part.EditRebuild3

    # Vérifie après le SaveAs3
    if os.path.exists(part_path):
        print(f"[✓] Pièce sauvegardée : {part_filename}")
    else:
        print(f"[✗] Échec de la sauvegarde : {part_filename}")
        
    swApp.CloseDoc(part.GetTitle)
    
