function [scenario, egoVehicle,trafficLightMode] = scenario_02()


%% Construct a drivingScenario object.
scenario = drivingScenario();
scenario.SampleTime = 0.1;
scenario.StopTime = 25;    % Stop time in seconds
trafficLightMode = "SteadyGreen";  % Possible are: Cycle, SteadyGreen, SteadyRed
%% Add all road segments
roadCenters = [74.55 0 0;
    -60 0 0];
marking = [laneMarking('Solid')
    laneMarking('Dashed')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36])
    laneMarking('Dashed')
    laneMarking('Solid')];
laneSpecification = lanespec(4, 'Marking', marking);
road(scenario, roadCenters, 'Lanes', laneSpecification);

roadCenters = [0 67.3 0;
    0 -67.3 0];
marking = [laneMarking('Solid')
    laneMarking('Dashed')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36])
    laneMarking('Dashed')
    laneMarking('Solid')];
laneSpecification = lanespec(4, 'Marking', marking);
road(scenario, roadCenters, 'Lanes', laneSpecification);

roadCenters = [67.3 74.55 0;
    67.3 -74.55 0];
marking = [laneMarking('Solid')
    laneMarking('Dashed')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36])
    laneMarking('Dashed')
    laneMarking('Solid')];
laneSpecification = lanespec(4, 'Marking', marking);
road(scenario, roadCenters, 'Lanes', laneSpecification);

roadCenters = [67.3 -67.3 0;
    -60 -67.3 0];
marking = [laneMarking('Solid')
    laneMarking('Dashed')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36])
    laneMarking('Dashed')
    laneMarking('Solid')];
laneSpecification = lanespec(4, 'Marking', marking);
road(scenario, roadCenters, 'Lanes', laneSpecification);

roadCenters = [67.3 67.3 0;
    -60 67.3 0];
marking = [laneMarking('Solid')
    laneMarking('Dashed')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36])
    laneMarking('Dashed')
    laneMarking('Solid')];
laneSpecification = lanespec(4, 'Marking', marking);
road(scenario, roadCenters, 'Lanes', laneSpecification);

%% parking lot
roadCenters = [30 -67.3;
               30 -55];
road(scenario,roadCenters,Name="Road1");
lot = parkingLot(scenario,[59 -8; 8 -8; 8 -59; 59 -59]);
% Create the parking spaces.
cars = parkingSpace(Width=3.3);
accessible = parkingSpace(Type="Accessible");
accessibleLane = parkingSpace(Type="NoParking",MarkingColor=[1 1 1],Width=1.5);
fireLane = parkingSpace(Type="NoParking",Length=2,Width=45);

% Insert the parking spaces.
insertParkingSpaces(lot,cars, 13 ,Edge=2, Offset=2); % Top edge
insertParkingSpaces(lot,cars,13, Edge=4, Offset=4); % Bottom edge
insertParkingSpaces(lot, [cars accessibleLane accessible accessibleLane accessible], ...
    [5 1 1 1 1],Rows=2,Position=[33 -18]);

insertParkingSpaces(lot,fireLane,1,Edge=1,Offset=3); % Left edge

%% Add Actors
% Add the ego vehicle
egoVehicle = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position',[29.5 -67.8 0], ...
    'FrontOverhang', 0.9, ...
    'Wheelbase', 2.8, ...
    'Mesh', driving.scenario.carMesh, ...
    'Name', 'Car');
waypoints =  [-57.0000   -1.7500         0
              -10.6298   -1.7500         0
               -9.9216   -1.7488         0
               -9.2134   -1.7412         0
               -8.5055   -1.7211         0
               -7.7984   -1.6824         0
               -7.0931   -1.6190         0
               -6.3912   -1.5251         0
               -5.6952   -1.3947         0
               -5.0084   -1.2224         0
               -4.3352   -1.0029         0
               -3.6809   -0.7325         0
               -3.0499   -0.4114         0
               -2.4460   -0.0417         0
               -1.8731    0.3743         0
               -1.3346    0.8340         0
               -0.8340    1.3346         0
               -0.3743    1.8731         0
                0.0417    2.4460         0
                0.4114    3.0499         0
                0.7325    3.6809         0
                1.0029    4.3352         0
                1.2224    5.0084         0
                1.3947    5.6952         0
                1.5251    6.3912         0
                1.6190    7.0931         0
                1.6824    7.7984         0
                1.7211    8.5055         0
                1.7412    9.2134         0
                1.7488    9.9216         0
                1.7500   10.6298         0
                1.7500   55.0000         0];
speed = 9;
trajectory(egoVehicle, waypoints, speed);

car = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [-1.63834957991688 57.2902555927951 0], ...
    'FrontOverhang', 0.9, ...
    'Wheelbase', 2.8, ...
    'Mesh', driving.scenario.carMesh, ...
    'PlotColor', [183 70 255] / 255, ...
    'Name', 'Car');
waypoints = [-1.63834957991688 57.2902555927951 0;
    -1.79 -49.73 0.01];
speed = [9;5];
trajectory(car, waypoints, speed);


% truck = vehicle(scenario, ...
%     'ClassID', 2, ...
%     'Length', 8.2, ...
%     'Width', 2.5, ...
%     'Height', 3.5, ...
%     'Position', [-41 -1.8 0.01], ...
%     'FrontOverhang', 4.4, ...
%     'Mesh', driving.scenario.truckMesh, ...
%     'PlotColor', [183 70 255] / 255, ...
%     'Name', 'Car');
% waypoints = [-41 -1.8 0.01;
%     0     -1.8  0.01; 
%     52.16 -2.18 0.01];
% speed = [9;9;1];
% yaw =  [-0.0892553533591567;-0.0893506333390383;-0.0893506333390383];
% trajectory(truck, waypoints, speed, 'Yaw', yaw);


actor(scenario, ...
    'ClassID', 8, ...
    'Length', 40, ...
    'Width', 50, ...
    'Height', 20, ...
    'Position', [-28.5 33.9 0], ...
    'PlotColor', [0 0.447 0.741], ...
    'Name', 'Building');

actor(scenario, ...
    'ClassID', 8, ...
    'Length', 25, ...
    'Width', 50, ...
    'Height', 20, ...
    'Position', [-20.9 -33.5 0], ...
    'PlotColor', [0.929 0.694 0.125], ...
    'Name', 'Building2');

actor(scenario, ...
    'ClassID', 8, ...
    'Length', 50, ...
    'Width', 25, ...
    'Height', 20, ...
    'Position', [33.9 47.3 0], ...
    'PlotColor', [0.494 0.184 0.556], ...
    'Name', 'Building3');

actor(scenario, ...
    'ClassID', 8, ...
    'Length', 50, ...
    'Width', 25, ...
    'Height', 20, ...
    'Position', [33.6 21.1 0], ...
    'PlotColor', [0.466 0.674 0.188], ...
    'Name', 'Building4');

actor(scenario, ...
    'ClassID', 8, ...
    'Length', 25, ...
    'Width', 50, ...
    'Height', 20, ...
    'Position', [-48.4333333333333 -34 0], ...
    'PlotColor', [162 20 47] / 255, ...
    'Name', 'Building7');


SF_std=0;
assignin('base','SF_std',SF_std);

end


