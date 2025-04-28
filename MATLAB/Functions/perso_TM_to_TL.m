function TL = perso_TM_to_TL(TM, env)
    c0 = env.air.parameters.c0;
    rho = env.air.parameters.rho;
    
    % Reference : perso_ouvrir_lien_Zotero('zotero://open-pdf/library/items/GNXTFEBQ?page=27&annotation=L929ZIHP');
    TL = 20*log((TM.T11 + rho*c0*TM.T12 + rho*c0*TM.T21+TM.T22) / 2);
end