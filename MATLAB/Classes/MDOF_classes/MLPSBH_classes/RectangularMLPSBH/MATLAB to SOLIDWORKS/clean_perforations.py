import win32com.client
import pythoncom
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')
pythoncom.CoInitialize()

def safe_print(msg):
    try:
        print(msg)
    except UnicodeEncodeError:
        print(msg.encode("ascii", "replace").decode())

SEGMENT_TYPES = {
    0: "line",
    1: "arc",
    2: "spline",
    3: "ellipse",
    4: "parabola",
    5: "hyperbola",
    6: "circle",
}

if len(sys.argv) < 2:
    safe_print("[!] Aucun fichier spécifié.")
    sys.exit(1)

file_path = sys.argv[1]
if not os.path.exists(file_path):
    safe_print(f"[!] Fichier introuvable : {file_path}")
    sys.exit(1)

safe_print("=== Nettoyage effectué ===")
safe_print(f"[~] Chargement de la pièce : {file_path}")

swApp = win32com.client.Dispatch("SldWorks.Application")
swApp.Visible = False

longstatus = win32com.client.VARIANT(pythoncom.VT_BYREF | pythoncom.VT_I4, 0)
longwarnings = win32com.client.VARIANT(pythoncom.VT_BYREF | pythoncom.VT_I4, 0)
part = swApp.OpenDoc6(file_path, 1, 0, "", longstatus, longwarnings)

if part is None:
    safe_print("[!] Erreur ouverture fichier.")
    sys.exit(1)

# Fermer esquisse si active
try:
    if part.SketchManager.ActiveSketch:
        part.SketchManager.InsertSketch(True)
        safe_print("[~] Esquisse active fermée.")
except Exception as e:
    safe_print(f"[!] Erreur fermeture esquisse : {e}")

fm = part.FeatureManager
features = fm.GetFeatures(True)
empty_dispatch = win32com.client.VARIANT(pythoncom.VT_DISPATCH, None)

deleted_ice = 0
deleted_sketches = 0
total = 0

safe_print(f"[~] {len(features)} features trouvés :")

for feat in features:
    total += 1
    try:
        name = feat.Name
        type_name = feat.GetTypeName2
        safe_print(f"\n--- Feature {total} ---")
        safe_print(f"Nom     : {name}")
        safe_print(f"Type    : {type_name}")

        # Suppression des découpes (ICE)
        if type_name == "ICE":
            ok = part.Extension.SelectByID2(name, "BODYFEATURE", 0, 0, 0, False, 0, empty_dispatch, 0)
            safe_print(f"  → Sélection ICE : {ok}")
            if ok:
                part.EditDelete()
                part.ClearSelection2(True)
                safe_print("  ✓ ICE supprimé")
                deleted_ice += 1
            continue

        # Suppression esquisses simples (cercles ou lignes)
        if type_name == "ProfileFeature":
            sketch = feat.GetSpecificFeature2()
            if sketch:
                try:
                    segments = sketch.GetSketchSegments()
                    if segments and len(segments) > 0:
                        types = [seg.GetType() for seg in segments]
                        all_simple = all(t in [0, 1, 6] for t in types)
                        safe_print(f"  Segments : {[SEGMENT_TYPES.get(t, str(t)) for t in types]}")
                        if all_simple:
                            ok = part.Extension.SelectByID2(name, "SKETCH", 0, 0, 0, False, 0, empty_dispatch, 0)
                            if ok:
                                part.EditDelete()
                                part.ClearSelection2(True)
                                safe_print("  ✓ Esquisse supprimée")
                                deleted_sketches += 1
                except Exception as e:
                    safe_print(f"  ✗ Erreur lecture segments : {e}")

    except Exception as e:
        safe_print(f"[!] Erreur sur feature {total} : {e}")

# Résumé
safe_print("\n======= Résumé du nettoyage =======")
safe_print(f"Total features analysés     : {total}")
safe_print(f"Découpes solides supprimées : {deleted_ice}")
safe_print(f"Esquisses simples supprimées: {deleted_sketches}")

# Sauvegarde
try:
    part.SetReadOnlyState(False)
    part.Save3(1, 0, 0)
    title = part.GetTitle()
    swApp.CloseDoc(title)
    safe_print(f"[✓] Pièce enregistrée et fermée : {title}")
except Exception as e:
    safe_print(f"[!] Erreur à la sauvegarde/fermeture : {e}")
