function options = perso_propagate(TM, options)

    if isfield(options, 'pt_in') && ~perso_isnan(options.pt_in) && isfield(options, 'u_in') && ~perso_isnan(options.u_in)
        pt_in = options.pt_in; u_in = options.u_in;
        pt_out = TM.T11 .* pt_in + TM.T12 .* u_in;
        u_out = TM.T21 .* pt_in + TM.T22 .* u_in;
        options.pt_in = pt_out; options.u_in = u_out;
    end
end