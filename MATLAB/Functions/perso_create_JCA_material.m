function JCAmat = perso_create_JCA_material(model, name, JCAconfig, env)
    
    JCAmat = model.component('component').material.create(name, 'Common');
    JCAmat.propertyGroup.create('PoroacousticsModel', 'Poroacoustics_model');
    JCAmat.propertyGroup('def').set('density', 'rho0');
    JCAmat.propertyGroup('def').set('soundspeed', 'co');
    JCAmat.propertyGroup('def').set('dynamicviscosity', 'neta');
    JCAmat.propertyGroup('def').set('thermalconductivity', {'kappa' '0' '0' '0' 'kappa' '0' '0' '0' 'kappa'});
    JCAmat.propertyGroup('def').set('heatcapacity', 'cp');
    % JCAmat.propertyGroup('def').set('ratioofspecificheat', 'gamma');
    JCAmat.propertyGroup('def').set('ratioofspecificheat', '1.4');
    % JCAmat.propertyGroup('def').set('gamma', 'gamma');

    % Porosité
    JCAmat.propertyGroup('def').set('porosity', num2str(JCAconfig.Porosity));
    % Longueur caractéristique visqueuse      
    JCAmat.propertyGroup('PoroacousticsModel').set('Lv', num2str(JCAconfig.ViscousCaracteristicLength));
    % Longueur caractéristiques thermique
    JCAmat.propertyGroup('PoroacousticsModel').set('Lth', num2str(JCAconfig.ThermalCaracteristicLength));
    
    % Tortuosité
    if isscalar(JCAconfig.Tortuosity)
        JCAmat.propertyGroup('PoroacousticsModel').set('tau', num2str(JCAconfig.Tortuosity));
    else
        JCAmat.propertyGroup('PoroacousticsModel').set('tau', num2str(JCAconfig.Tortuosity(env)));
    end
    % Résistivité
    JCAmat.propertyGroup('PoroacousticsModel').set('Rf', num2str(JCAconfig.AirFlowResistivity(env)));
end