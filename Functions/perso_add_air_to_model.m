function output_model = perso_add_air_to_model(input_model)
    
    model = input_model;
    mat = model.component('component').material.create('air_perso', 'Common');
    mat.label('Air');
    mat.set('family', 'air');
    mat.materialType('nonSolid');
    
    mat.propertyGroup('def').set('thermalexpansioncoefficient', '');
    mat.propertyGroup('def').set('molarmass', '');
    mat.propertyGroup('def').set('bulkviscosity', '');
    mat.propertyGroup('def').set('thermalexpansioncoefficient', {'alpha_p(pA,T)' '0' '0' '0' 'alpha_p(pA,T)' '0' '0' '0' 'alpha_p(pA,T)'});
    mat.propertyGroup('def').set('molarmass', '0.02897[kg/mol]');
    mat.propertyGroup('def').set('bulkviscosity', 'muB(T)');
    mat.propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
    mat.propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
    mat.propertyGroup('def').set('dynamicviscosity', 'eta(T)');
    mat.propertyGroup('def').set('ratioofspecificheat', '1.4');
    mat.propertyGroup('def').set('electricconductivity', {'0[S/m]' '0' '0' '0' '0[S/m]' '0' '0' '0' '0[S/m]'});
    mat.propertyGroup('def').set('heatcapacity', 'Cp(T)');
    mat.propertyGroup('def').set('density', 'rho(pA,T)');
    mat.propertyGroup('def').set('thermalconductivity', {'k(T)' '0' '0' '0' 'k(T)' '0' '0' '0' 'k(T)'});
    mat.propertyGroup('def').set('soundspeed', 'cs(T)');
    mat.propertyGroup('def').addInput('temperature');
    mat.propertyGroup('def').addInput('pressure');
    
    mat_eta = mat.propertyGroup('def').func.create('eta', 'Piecewise');
    mat_eta.set('arg', 'T');
    mat_eta.set('pieces', {'200.0' '1600.0' '-8.38278E-7+8.35717342E-8*T^1-7.69429583E-11*T^2+4.6437266E-14*T^3-1.06585607E-17*T^4'});
    mat_eta.set('argunit', 'K');
    mat_eta.set('fununit', 'Pa*s');
    
    mat_Cp = mat.propertyGroup('def').func.create('Cp', 'Piecewise');
    mat_Cp.set('arg', 'T');
    mat_Cp.set('pieces', {'200.0' '1600.0' '1047.63657-0.372589265*T^1+9.45304214E-4*T^2-6.02409443E-7*T^3+1.2858961E-10*T^4'});
    mat_Cp.set('argunit', 'K');
    mat_Cp.set('fununit', 'J/(kg*K)');
    
    mat_rho = mat.propertyGroup('def').func.create('rho', 'Analytic');
    mat_rho.set('expr', 'pA*0.02897/R_const[K*mol/J]/T');
    mat_rho.set('args', {'pA' 'T'});
    mat_rho.set('fununit', 'kg/m^3');
    mat_rho.set('argunit', {'Pa' 'K'});
    mat_rho.set('plotargs', {'pA' '101325' '101325'; 'T' '273.15' '293.15'});
    
    mat_k = mat.propertyGroup('def').func.create('k', 'Piecewise');
    mat_k.set('arg', 'T');
    mat_k.set('pieces', {'200.0' '1600.0' '-0.00227583562+1.15480022E-4*T^1-7.90252856E-8*T^2+4.11702505E-11*T^3-7.43864331E-15*T^4'});
    mat_k.set('argunit', 'K');
    mat_k.set('fununit', 'W/(m*K)');
    
    mat_cs = mat.propertyGroup('def').func.create('cs', 'Analytic');
    mat_cs.set('expr', 'sqrt(1.4*R_const[K*mol/J]/0.02897*T)');
    mat_cs.set('args', {'T'});
    mat_cs.set('fununit', 'm/s');
    mat_cs.set('argunit', {'K'});
    mat_cs.set('plotargs', {'T' '273.15' '373.15'});
    
    mat_an1 = mat.propertyGroup('def').func.create('an1', 'Analytic');
    mat_an1.set('funcname', 'alpha_p');
    mat_an1.set('expr', '-1/rho(pA,T)*d(rho(pA,T),T)');
    mat_an1.set('args', {'pA' 'T'});
    mat_an1.set('fununit', '1/K');
    mat_an1.set('argunit', {'Pa' 'K'});
    mat_an1.set('plotargs', {'pA' '101325' '101325'; 'T' '273.15' '373.15'});
    
    mat_an2 = mat.propertyGroup('def').func.create('an2', 'Analytic');
    mat_an2.set('funcname', 'muB');
    mat_an2.set('expr', '0.6*eta(T)');
    mat_an2.set('args', {'T'});
    mat_an2.set('fununit', 'Pa*s');
    mat_an2.set('argunit', {'K'});
    
    mat_an2.set('plotargs', {'T' '200' '1600'});
    
    mat_refract = mat.propertyGroup.create('RefractiveIndex', 'Refractive index');
    mat_refract.set('n', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
    
    mat_nlm = mat.propertyGroup.create('NonlinearModel', 'Nonlinear model');
    mat_nlm.set('BA', '(def.gamma+1)/2');
    
    mat_idlg = mat.propertyGroup.create('idealGas', 'Ideal gas');
    mat_idlg_Cp = mat_idlg.func.create('Cp', 'Piecewise');
    mat_idlg_Cp.label('Piecewise 2');
    mat_idlg_Cp.set('arg', 'T');
    mat_idlg_Cp.set('pieces', {'200.0' '1600.0' '1047.63657-0.372589265*T^1+9.45304214E-4*T^2-6.02409443E-7*T^3+1.2858961E-10*T^4'});
    mat_idlg_Cp.set('argunit', 'K');
    mat_idlg_Cp.set('fununit', 'J/(kg*K)');
    mat_idlg.set('Rs', 'R_const/Mn');
    mat_idlg.set('heatcapacity', 'Cp(T)');
    mat_idlg.set('ratioofspecificheat', '1.4');
    mat_idlg.set('molarmass', '0.02897');
    mat_idlg.addInput('temperature');
    mat_idlg.addInput('pressure');
    
    mat.propertyGroup('def').set('thermalexpansioncoefficient', '');
    mat.propertyGroup('def').set('molarmass', '');
    mat.propertyGroup('def').set('bulkviscosity', '');
    mat.propertyGroup('def').set('thermalexpansioncoefficient', {'alpha_p(pA,T)' '0' '0' '0' 'alpha_p(pA,T)' '0' '0' '0' 'alpha_p(pA,T)'});
    mat.propertyGroup('def').set('molarmass', '0.02897[kg/mol]');
    mat.propertyGroup('def').set('bulkviscosity', 'muB(T)');
    mat.propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
    mat.propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
    mat.propertyGroup('def').set('dynamicviscosity', 'eta(T)');
    mat.propertyGroup('def').set('ratioofspecificheat', '1.4');
    mat.propertyGroup('def').set('electricconductivity', {'0[S/m]' '0' '0' '0' '0[S/m]' '0' '0' '0' '0[S/m]'});
    mat.propertyGroup('def').set('heatcapacity', 'Cp(T)');
    mat.propertyGroup('def').set('density', 'rho(pA,T)');
    mat.propertyGroup('def').set('thermalconductivity', {'k(T)' '0' '0' '0' 'k(T)' '0' '0' '0' 'k(T)'});
    mat.propertyGroup('def').set('soundspeed', 'cs(T)');
    mat.propertyGroup('def').addInput('temperature');
    mat.propertyGroup('def').addInput('pressure');

    output_model = model;
end