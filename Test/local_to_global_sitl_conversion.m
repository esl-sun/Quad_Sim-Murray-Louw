function global_pos = local_to_global_sitl_conversion(pos)
% only works for default start position for default SITL
% redo for practical location

    % X direction
    measured.x = [ ... % Local position setpoints measured from log after x steps plan from QGC
        0;
        2.975272894;
        5.9444885254;
        8.4895210266;
        15.27632046
    ];

    measured.lat   = [ ... % Latitude from .plan file from QGC
        47.39775080;
        47.397778289807455;
        47.397802521741795;
        47.39782595757876;
        47.39788638873909    
    ];

    p = polyfit(measured.x, measured.lat, 1); % Fit polynomial to data
%     predict.lat = polyval(p, measured.x); 
    
    global_pos.latitude = polyval(p, pos.x);    
    
%     figure
%     plot(measured.x, measured.lat,'x')
%     hold on
%     plot(measured.x, predict.lat)
%     title('X')
%     hold off
  
end