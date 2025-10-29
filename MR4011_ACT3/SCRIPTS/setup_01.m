function setup_01(nvp)


arguments
   
    % set as default
    nvp.ScenarioFcnName(1,1) {mustBeMember(nvp.ScenarioFcnName, ...
        ["scenario_01",...
         "scenario_02",...
         "scenario_03", ...
         "scenario_final"
         ])} = "scenario_01";
    % Vehicle-to-Vehicle communication Range. Default value set to 30
    nvp.Range(1,1) {mustBeNonnegative(nvp.Range), ...
    mustBeLessThanOrEqual(nvp.Range,1000)} = 60; 
    nvp.TXpower(1,1) {mustBeLessThanOrEqual(nvp.TXpower,40)} = 20; 
end

%% Inputs
% Load the Simulink model
modelName = 'MODEL_PV';
wasModelLoaded = bdIsLoaded(modelName);
if ~wasModelLoaded
    load_system(modelName)
end

scenarioFcnHandle = str2func(nvp.ScenarioFcnName);

[scenario, egoVehicle,trafficLightMode]=scenarioFcnHandle();

% Distance from ego vehicle to the traffic light that triggers traffic
% light state change.
trafficLightStateTriggerThreshold = 50;

% Maximum distance for a track to be selected as a "most important track".
maxMIOLeadDistance = 40;

assignin('base','trafficLightStateTriggerThreshold',trafficLightStateTriggerThreshold);
assignin('base','maxMIOLeadDistance',maxMIOLeadDistance);
% Set traffic light state
blk = [modelName,'/Scenario and Environment/TrafficLightSystem'];
set_param(blk,'TrafficLightSensorModeSelection',trafficLightMode)

%% Scene Origin
sceneOrigin = [42.2995, -83.6990, 0];
assignin('base','sceneOrigin',sceneOrigin);

%% Distance from ego vehicle to the traffic light that triggers traffic

trafficLightPositions = getTrafficLightSensorPositions();
intersectionInfo.tlSensor1Position = trafficLightPositions.tlSensor1Position;
intersectionInfo.tlSensor2Position = trafficLightPositions.tlSensor2Position;
intersectionInfo.tlSensor3Position = trafficLightPositions.tlSensor3Position;
intersectionInfo.tlSensor4Position = trafficLightPositions.tlSensor4Position;

% Update intersection information with intersection center
intersectionInfo.intersectionCenter = [0 0 0];

    function trafficLightPositions = getTrafficLightSensorPositions()

        % TL Sensor 1 position as [x y z].
        % x - x co-ordinate.
        % y - y co-ordinate.
        % z - z co-ordinate.
        trafficLightPositions.tlSensor1Position = [-6.9 -1.9 8];

        % TL Sensor 2 position as [x y z].
        % x - x co-ordinate.
        % y - y co-ordinate.
        % z - z co-ordinate.
        trafficLightPositions.tlSensor2Position = [2 -7 8];

        % TL Sensor 3 position as [x y z].
        % x - x co-ordinate.
        % y - y co-ordinate.
        % z - z co-ordinate.
        trafficLightPositions.tlSensor3Position = [7 2 8];

        % TL Sensor 4 position as [x y z].
        % x - x co-ordinate.
        % y - y co-ordinate.
        % z - z co-ordinate.
        trafficLightPositions.tlSensor4Position = [-2 7 8];

    end
assignin('base','trafficLightStateTriggerThreshold',trafficLightStateTriggerThreshold);
%%
referencePathInfo = EgoRefPathCreator(scenario, 1);

%% Define the region and Intersection names
regionInfo.RegionName = 'Region_1';
regionInfo.Intersections(1).Name = 'TrafficLightGroup_1';
regionInfo.Intersections(1).TrafficSignal(1).Name = 'TrafficLight_1';
regionInfo.Intersections(1).TrafficSignal(2).Name = 'TrafficLight_2';
regionInfo.Intersections(1).TrafficSignal(3).Name = 'TrafficLight_3';
regionInfo.Intersections(1).TrafficSignal(4).Name = 'TrafficLight_4';
assignin('base','regionInfo',regionInfo);
assignin('base','approachingIntersectionName',regionInfo.Intersections(1).Name);
assignin('base','approachingSignalName',regionInfo.Intersections(1).TrafficSignal(1).Name);

%% Scenario parameters
assignin('base','scenario',scenario);
assignin('base','egoVehicle',egoVehicle);
assignin('base', 'egoActorID', egoVehicle.ActorID);
assignin('base','referencePathInfo',referencePathInfo);
assignin('base','intersectionInfo',intersectionInfo);

%% Get the classID for all actors
profiles      = actorProfiles(scenario);
actorsClassID = [[profiles.ActorID]' [profiles.ClassID]' [profiles.Length]' [profiles.Width]'];
assignin('base','actorsClassID',actorsClassID);

%% Vehicle parameters
egoVehDyn = egoVehicleDynamicsParams(egoVehicle);
assignin('base','egoVehDyn',egoVehDyn);

%% General model parameters
assignin('base','Ts',0.1);                   % Algorithm sample time  (s)
assignin('base','v_set', egoVehDyn.VLong0);  % Set velocity           (m/s)

%% Path following controller parameters
assignin('base','tau',               0.05);  % Time constant for longitudinal dynamics 1/s/(tau*s+1)
assignin('base','tau2',              0.07);  % Longitudinal time constant (brake)             (N/A)
assignin('base','time_gap',          0.9);   % Time gap                                       (s)
assignin('base','default_spacing',   10);    % Default spacing                                (m)
assignin('base','max_ac',            2);     % Maximum acceleration                           (m/s^2)
assignin('base','max_dc',            -10);   % Maximum deceleration                           (m/s^2)
assignin('base','min_ac',            -3);    % Minimum acceleration                           (m/s^2)
assignin('base','max_steer',         1.0);   % Maximum steering                               (rad)
assignin('base','min_steer',        -1.0);   % Minimum steering                               (rad)
assignin('base','PredictionHorizon', 5);     % Prediction horizon
assignin('base','ControlHorizon', 2)         % Control horizon
assignin('base','v0_ego', egoVehDyn.VLong0); % Initial longitudinal velocity                  (m/s)

%% Tracking and sensor fusion parameters
assignin('base','assignThresh', 100);       % Tracker assignment threshold          (N/A)
assignin('base','M',            2);        % Tracker M value for M-out-of-N logic  (N/A)
assignin('base','N',            3);        % Tracker N value for M-out-of-N logic  (N/A)
assignin('base','numTracks',    100);      % Maximum number of tracks              (N/A)
assignin('base','numSensors',   1);        % Maximum number of sensors             (N/A)
% Position and Velocity Selector from Tracks
posSelector = [ 1, 0, 0, 0, 0, 0, 0, 0, 0; 0, 0, 0, 1, 0, 0, 0, 0, 0];
velSelector = [ 0, 1, 0, 0, 0, 0, 0, 0, 0; 0, 0, 0, 0, 1, 0, 0, 0, 0 ];
assignin('base','posSelector',posSelector)
assignin('base','velSelector',velSelector)

%% Dynamics modeling parameters
assignin('base','m',  1575);                    % Total mass of vehicle                          (kg)
assignin('base','Iz', 2875);                    % Yaw moment of inertia of vehicle               (m*N*s^2)
assignin('base','Cf', 19000);                   % Cornering stiffness of front tires             (N/rad)
assignin('base','Cr', 33000);                   % Cornering stiffness of rear tires              (N/rad)
assignin('base','lf', egoVehDyn.CGToFrontAxle); % Longitudinal distance from c.g. to front tires (m)
assignin('base','lr', egoVehDyn.CGToRearAxle);  % Longitudinal distance from c.g. to rear tires  (m)

%% Watchdog Braking controller parameters
assignin('base', 'PB1_decel',       2.0);      % 1st stage Partial Braking deceleration (m/s^2)
assignin('base', 'PB2_decel',       4.0);      % 2nd stage Partial Braking deceleration (m/s^2)
assignin('base', 'FB_decel',        9.8);      % Full Braking deceleration              (m/s^2)
assignin('base', 'headwayOffset',   3.7);      % Distance from ego origin to bumper     (m)
assignin('base', 'timeMargin',      0.25);     % time margin                            (sec)
assignin('base', 'timeToReact',     1.25);     % driver reaction time                   (sec)
assignin('base', 'driver_decel',    4.0);      % driver braking deceleration            (m/s^2)
assignin('base','Default_decel', 0);           % Default deceleration (m/s^2)
assignin('base','TimeFactor', 1.2);            % Time factor (sec)
assignin('base','stopVelThreshold', 0.1);      % Velocity threshold for stopping ego vehicle (m/s)
% define the enumeration for watchdog controller
Simulink.defineIntEnumType('BrStatus', ...
                          {'NoBrake', 'PB1Brake', 'PB2Brake','FBrake'}, ...
                          [0;1;2;3], ...
                          'Description', 'Brake Status for watch dog controller', ...
                          'DefaultValue', 'NoBrake', ...
                          'HeaderFile', 'BrStatus.h', ...
	                      'DataScope', 'Exported');

%% V2X Channel Info(95% probability of detection)
if exist("V2XChannelInfo.mat","file")
    snrCurvesData = load("V2XChannelInfo.mat");
    snrCurves = snrCurvesData.snrCurves;
    % Adjust distance to SNR Relation based on range
    maxRange = 1000; % (meters)
    offsetIdx = round(max(1,min(nvp.Range,maxRange))); 
    snrCurves.dist2snr(:,2) = snrCurves.dist2snr(:,2) + snrCurves.snrOffset(offsetIdx);
    assignin('base','channelAttributes',snrCurves);
else
    error('V2XChannelInfo.mat file not found')
end
%% V2X Range
assignin('base','V2XRange', nvp.Range);
%% enum classes
evalin('base','helperCreateV2IEnumData');
evalin('base','helperCreateV2VEnumData');
%% buses
evalin('base','createBuses');
evalin('base','helperCreateV2IBusObjects');
evalin('base','helperCreateV2VBusObjects');
multiObjectTracker.createBus('MODEL_PV/Tracker/Multi Object Tracker/Multi-Object Tracker');
end

% Update the initial vehicle parameters for the vehicle dynamics block.
function egoVehDyn = egoVehicleDynamicsParams(ego)
% Translate to SAE J670E (North-East-Down)
% Adjust sign of y position
egoVehDyn.X0  =  ego.Position(1); % (m)
egoVehDyn.Y0  = -ego.Position(2); % (m)
egoVehDyn.VX0 =  ego.Velocity(1); % (m)
egoVehDyn.VY0 = -ego.Velocity(2); % (m)

% Adjust sign and unit of yaw
egoVehDyn.Yaw0 = -deg2rad(ego.Yaw); % (rad)

% Longitudinal velocity
egoVehDyn.VLong0 = hypot(egoVehDyn.VX0,egoVehDyn.VY0); % (m/sec)

% Distance from center of gravity to axles
egoVehDyn.CGToFrontAxle = ego.Length/2 - ego.FrontOverhang;
egoVehDyn.CGToRearAxle  = ego.Length/2 - ego.RearOverhang;

end