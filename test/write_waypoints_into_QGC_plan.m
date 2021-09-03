%% Write waypoints and waypoints time into .plan file for QGC to upload to PX4

% Using variables already in workspace:
% - waypoints
% - waypoints_time

mission_folder = [getenv('HOME'), '/Masters/QGroundControl/Missions/']
misson_file = 'x_steps_random.plan'
file_ID = fopen([mission_folder, misson_file],'w'); % open file for writing

%% Text for start, each items and end of .plan file:
start_plan = {
'{'
'    "fileType": "Plan",'
'    "geoFence": {'
'        "circles": ['
'        ],'
'        "polygons": ['
'        ],'
'        "version": 2'
'    },'
'    "groundStation": "QGroundControl",'
'    "mission": {'
'        "cruiseSpeed": 15,'
'        "firmwareType": 12,'
'        "globalPlanAltitudeMode": 1,'
'        "hoverSpeed": 5,'
'        "items": ['
};

item_text = {
'                {'
'                "AMSLAltAboveTerrain": null,'
'                "Altitude": %f,'
'                "AltitudeMode": 1,'
'                "autoContinue": true,'
'                "command": 16,'
'                "doJumpId": %d,'
'                "frame": 3,'
'                "params": ['
'                    %f,'
'                    0,'
'                    0,'
'                    0,' 
'                    %f,' 
'                    %f,' 
'                    %f'
'                ],'
'                "type": "SimpleItem"'
'                }'
};

end_plan = {
'        ],'
'        "plannedHomePosition": ['
'            47.39775080,'
'            8.54560730,'
'            488.14855449719175'
'        ],'
'        "vehicleType": 2,'
'        "version": 2'
'    },'
'    "rallyPoints": {'
'        "points": ['
'        ],'
'        "version": 2'
'    },'
'    "version": 1'
'}'
}; 

%% Write start of file
for row = 1:length(start_plan)
    row_string = [start_plan{row}, '\n'];
    fprintf(file_ID, row_string);
end

%% Write waypoint items
home.latitude = 47.39775080;
home.longitude = 8.54560730;

for wp_index = 1:length(waypoints)
    current_waypoint = waypoints(wp_index,:);
    pos.x = current_waypoint(1);
    pos.y = current_waypoint(2);
    pos.z = current_waypoint(3);
    global_pos = local_to_global_sitl_conversion(pos);

    altitude = -pos.z;
    latitude = global_pos.latitude;
    longitude = home.longitude;
    hold_time = waypoints_time(wp_index);


    for row = 1:length(item_text) % Write rows that need a value with %f, otherwise write normally
        switch  row
            case 3
                row_string = [item_text{row}, '\n'];
                fprintf(file_ID, row_string, altitude);
            case 7
                row_string = [item_text{row}, '\n'];
                fprintf(file_ID, row_string, wp_index);
            case 10
                row_string = [item_text{row}, '\n'];
                fprintf(file_ID, row_string, hold_time);
            case 14
                row_string = [item_text{row}, '\n'];
                fprintf(file_ID, row_string, latitude);
            case 15
                row_string = [item_text{row}, '\n'];
                fprintf(file_ID, row_string, longitude);
            case 16
                row_string = [item_text{row}, '\n'];
                fprintf(file_ID, row_string, altitude);
            case 19 % Last line '}'
                if wp_index == length(waypoints) % Don't print a comma after item if it is the last item
                    row_string = [item_text{row}, '\n'];
                    fprintf(file_ID, row_string);
                else
                    row_string = [item_text{row}, ',\n'];
                    fprintf(file_ID, row_string);
                end           
            otherwise % Line without value in
                row_string = [item_text{row}, '\n'];
                fprintf(file_ID, row_string);
        end
    end
    
end
% ??? dont print comma for last item

%% Write end of file
for row = 1:length(end_plan)
    row_string = [end_plan{row}, '\n'];
    fprintf(file_ID, row_string);
end

fclose(file_ID); % Close file

disp('Done.')