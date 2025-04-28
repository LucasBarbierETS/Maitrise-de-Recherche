function error(type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TYPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0 : no error
% 1 : Undefined subelements remain
% 2 : Too thick
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if type == 0
    elseif type == 1
        msgbox("One or several subelements are undefined","Error","error")
    elseif type == 2
        msgbox()
    end
end

% On oublie c'est trop au cas par cas
