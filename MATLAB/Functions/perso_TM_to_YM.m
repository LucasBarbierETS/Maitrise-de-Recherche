function YM = perso_TM_to_YM(TM)
    YM.Y11 = 1 ./ TM.T12 .* TM.T22;
    YM.Y12 = 1 ./ TM.T12 .* (TM.T21 .* TM.T12 - TM.T22 .* TM.T11);
    YM.Y21 = 1 ./ TM.T12;
    YM.Y22 = -1 ./ TM.T12 .* (TM.T11);
end    