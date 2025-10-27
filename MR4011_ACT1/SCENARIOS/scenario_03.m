function [scenario, egoVehicle,trafficLightMode] = scenario_03()


%% Construct a drivingScenario object.
scenario = drivingScenario();
scenario.SampleTime = 0.1;
scenario.StopTime = 40;    % Stop time in seconds
trafficLightMode = "Cycle";  % Possible are: Cycle, SteadyGreen, SteadyRed
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
waypoints = [-57 -1.75 0;
    -9.9 -1.9 0;
    10.2 -1.9 0;
    29.5 -5.4 0;
    39.3 -5.6 0;
    52.4 -5.4 0;
    57.9 -5.9 0;
    62.1 -9.7 0;
    62.1 -14.9 0;
    61.6 -30 0;
    61.6 -56.1 0;
    59.4 -61.6 0;
    53.1 -62.1 0;
    42.8 -61.9 0;
    34.3 -61.9 0;
    30.8 -58.6 0;
    30.8 -55.4 0];
speed = [9;9;3;9;9;9;9;2;9;9;9;9;9;9;2;2;2];
trajectory(egoVehicle, waypoints, speed);

% Add the non-ego actors
vehicle(scenario, ...
    'ClassID', 1, ...
    'Length', 4.7, ...
    'Position', [-13.0383495799169 61.4902555927951 0], ...
    'Pitch', -0.00535372687209605, ...
    'RearOverhang', 1, ...
    'FrontOverhang', 0.9, ...
    'Mesh', driving.scenario.carMesh, ...
    'PlotColor', [183 70 255] / 255, ...
    'Name', 'Car');

% actor(scenario, ...
%     'ClassID', 8, ...
%     'Length', 40, ...
%     'Width', 50, ...
%     'Height', 20, ...
%     'Position', [-28.5 33.9 0], ...
%     'PlotColor', [0 0.447 0.741], ...
%     'Name', 'Building');
% 
% actor(scenario, ...
%     'ClassID', 8, ...
%     'Length', 25, ...
%     'Width', 50, ...
%     'Height', 20, ...
%     'Position', [-20.9 -33.5 0], ...
%     'PlotColor', [0.929 0.694 0.125], ...
%     'Name', 'Building2');
% 
% actor(scenario, ...
%     'ClassID', 8, ...
%     'Length', 50, ...
%     'Width', 25, ...
%     'Height', 20, ...
%     'Position', [33.9 47.3 0], ...
%     'PlotColor', [0.494 0.184 0.556], ...
%     'Name', 'Building3');
% 
% actor(scenario, ...
%     'ClassID', 8, ...
%     'Length', 50, ...
%     'Width', 25, ...
%     'Height', 20, ...
%     'Position', [33.6 21.1 0], ...
%     'PlotColor', [0.466 0.674 0.188], ...
%     'Name', 'Building4');
% 
% actor(scenario, ...
%     'ClassID', 8, ...
%     'Length', 25, ...
%     'Width', 50, ...
%     'Height', 20, ...
%     'Position', [-48.4333333333333 -34 0], ...
%     'PlotColor', [162 20 47] / 255, ...
%     'Name', 'Building7');


SF_std=0;
assignin('base','SF_std',SF_std);

end


