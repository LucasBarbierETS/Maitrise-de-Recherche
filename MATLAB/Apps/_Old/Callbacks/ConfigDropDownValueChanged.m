function ConfigDropDownValueChanged(app,event)
%CONFIGDROPDOWNVALUECHANGED Summary of this function goes here
%   Detailed explanation goes here
    param_names = fieldnames(app.UIComponents);
    for i = 1:length(param_names)
        if app.UIComponents.(param_names{i}).ParametersPanel.Visible == "on"
            value = app.UIComponents.(param_names{i}).ConfigDropDown.Value;
            config = fieldnames(app.UIComponents.(param_names{i}).Configurations);
            for j = 1:length(config)
                if strcmp(app.UIComponents.(param_names{i}).Configurations.(config{j}).Name , value)
                    for k = 1:length(app.UIComponents.(param_names{i}).ParameterEditField)
                        app.UIComponents.(param_names{i}).ParameterEditField{k}.Value = app.UIComponents.(param_names{i}).Configurations.(config{j}).Value(k);
                    end
                end
            end
        end
    end
end

