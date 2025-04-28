function M = matprod(M1,M2)
    A = M1.T11;
    B = M1.T12;
    C = M1.T21;
    D = M1.T22;

    a = M2.T11;
    b = M2.T12;
    c = M2.T21;
    d = M2.T22;
    
    M.T11 = A.*a+B.*c;
    M.T12 = A.*b+B.*d;
    M.T21 = C.*a+D.*c;
    M.T22 = C.*b+D.*d;
end

