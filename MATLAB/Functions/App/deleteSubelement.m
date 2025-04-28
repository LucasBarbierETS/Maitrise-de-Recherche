function deleteSubelement(app,current_position)
    fnames = fieldnames(app.SubelementDatas);
    
    issubelementdeleted = false;
    for i = 1:length(fnames)
        % make sure the subelement called exists because some are deleted in the loop
        if isfield(app.SubelementDatas,fnames{i}) && not(issubelementdeleted)
            subelement = getfield(app.SubelementDatas,fnames{i});
            coordinates =  subelement.Position;
            if all(coordinates == current_position)
                issubelementdeleted = true;%the selected subelementdeleted is going to be deleted
                if subelement.Name ~= "None"% Make sure no + can be deleted
                    app.SubelementDatas = rmfield(app.SubelementDatas,fnames{i});% Delete the selected subelement
                    new_fnames = fieldnames(app.SubelementDatas);
    
                    go_to_other_case = true;
                    if coordinates(1) == 1%if a single-subelement element is deleted, delete the subelement, and both the + around. then create a +
                        % make sure the case is the right one
    
                        for j = 1 : length(new_fnames)
                            other_subelements = getfield(app.SubelementDatas,new_fnames{j});
                            if all(other_subelements.Position ==[coordinates(1)+1 coordinates(2)]) && other_subelements.Name=="None" && go_to_other_case% delete the entire line if deleted subelement is alone on the line
                                app.SubelementDatas = rmfield(app.SubelementDatas,new_fnames{j});
                                data_names  = fieldnames(app.SubelementDatas);
                                for k = 1:length(data_names) %if the line is deleted, all the lines below go 1 line up
                                    if app.SubelementDatas.(data_names{k}).Position(2) < coordinates(2)
                                        app.SubelementDatas.(data_names{k}).Position(2) = app.SubelementDatas.(data_names{k}).Position(2) + 1;
                                    end
                                
                                end
                                
                                go_to_other_case = false;
                            end
    
                        end                         
                    end
                    new_fnames = fieldnames(app.SubelementDatas);
                    if coordinates(1) ~= 1 || go_to_other_case % if not the only one on the line
                        for j = 1 : length(new_fnames)
                            if app.SubelementDatas.(new_fnames{j}).Position(1) > coordinates(1) % all the subelements on the right go 1 to the left
                                app.SubelementDatas.(new_fnames{j}).Position(1) = app.SubelementDatas.(new_fnames{j}).Position(1) - 1;
                            end
                        end
                    end
                    
                end
            end
    
        end
    end
    
    % Reset axis
    xmax = 0;
    ymax = 0;
    fnames = fieldnames(app.SubelementDatas);
    for i = 1:length(fnames)
        if i==1
            hold(app.UIAxes,'off')
        elseif i==2
            hold(app.UIAxes,'on')
        end
        coordinates = getfield(app.SubelementDatas,fnames{i}).Position;
        marker = getfield(app.SubelementDatas,fnames{i}).Marker;
        color = getfield(app.SubelementDatas,fnames{i}).Color;
        plot(app.UIAxes,coordinates(1),coordinates(2),'k','marker',marker,'MarkerSize',15,'LineWidth',2,'Color',color)
        xmax = max(xmax,coordinates(1));
        ymax = min(ymax,coordinates(2));
    end
    % resize the axis
    set(app.UIAxes,'XLim',[0.7 xmax+0.3])
    set(app.UIAxes,'YLim',[ymax-0.3 -0.7])
    
    %If no element yet (only a +)
    if length(fnames)==1
        app.InputSurfaceAreasMenu.Enable = "off";
        app.SublementtypeDropDown.Enable = "off";
    else
        app.InputSurfaceAreasMenu.Enable = "on";
        app.SublementtypeDropDown.Enable = "on";
    end


end

