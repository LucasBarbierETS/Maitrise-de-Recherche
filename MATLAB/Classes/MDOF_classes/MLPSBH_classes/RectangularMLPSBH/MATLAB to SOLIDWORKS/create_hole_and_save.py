import win32com.client
import pythoncom

swApp = win32com.client.Dispatch("SldWorks.Application")
arg1 = win32com.client.VARIANT(16387, 0)
Part = swApp.OpenDoc6(r"E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Présentations\Présentations Thomas\25.04.08 - résultats optimisation pour Hutchinson\MPPSBH_bf_1\fichiers_sldprt\plaque_01.SLDPRT", 1, 0, "", arg1, arg1)
Part.FeatureManager.FeatureCut4(True, False, False, 0, 0, 0.01, 0.01, False, False, False, False, 1.74E-02, 1.74E-02, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
Part.Save3(1, arg1, arg1)