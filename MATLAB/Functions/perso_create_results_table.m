function model = perso_create_results_table(model)

    % Création d'un objet de ligne d'évaluation au niveau du microphone 2
    av_mic2 = model.result.numerical.create('av_mic2', 'AvLine');   
    av_mic2.selection.named('microphone2');  
    av_mic2.set('probetag', 'microphone2');  
    
    % création d'une table de résultats
    model.result.table.create('tbl1', 'Table');
    av_mic2.set('table', 'tbl1');
    model.result.table('tbl1').comments('acoustic indicators');
    av_mic2.label('acoustic indicators');

    av_mic2.set('expr', ['1-abs((exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)' ...
        '/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))*exp(2*j*ta.omega/acpr.c*(d2s+d12)))^2']);
    av_mic2.set('unit', {'1'});
    av_mic2.set('descr', {'Sound absorption'});
    
    av_mic2.setIndex('expr', ['real((exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)' ...
        '/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))*exp(2*j*ta.omega/acpr.c*(d2s+d12)))'], 1);
    av_mic2.setIndex('descr', 'Re(R)', 1);
    av_mic2.setIndex('unit', '1', 1);
    
    av_mic2.setIndex('expr', ['imag((exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)' ...
        '/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))*exp(2*j*ta.omega/acpr.c*(d2s+d12)))'], 2);
    av_mic2.setIndex('descr', 'Im(R)', 2);
    av_mic2.setIndex('unit', '1', 2);
    
    av_mic2.setIndex('expr', ['real((1+(exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)' ...
        '/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))*exp(2*j*ta.omega/acpr.c*(d2s+d12)))' ...
        '/(1-(exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))' ...
        '*exp(2*j*ta.omega/acpr.c*(d2s+d12))))'], 3);
    av_mic2.setIndex('descr', 'Re(Zns)', 3);
    
    av_mic2.setIndex('expr', ['imag((1+(exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)' ...
        '/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))*exp(2*j*ta.omega/acpr.c*(d2s+d12)))' ...
        '/(1-(exp(-j*ta.omega/acpr.c*d12)-acpr.p_t)/(acpr.p_t-exp(j*ta.omega/acpr.c*d12))' ...
        '*exp(2*j*ta.omega/acpr.c*(d2s + d12))))'], 4);
    av_mic2.setIndex('descr', 'Im(Zns)', 4);
    
    av_mic2.setResult;
end