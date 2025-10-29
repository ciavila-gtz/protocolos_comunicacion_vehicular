classdef HelperV2VTransmitter < matlab.System
% HelperV2VTransmitter Models a V2V Transmitter.
% This system object generates the Basic Safety Message(BSM) for all target
% vehicles using the the actors information from the scenario reader.INS
% sensor is used to apply noise to the input data.

% NOTE: The name of this System Object and its functionality may
% change without notice in a future release,
% or the System Object itself may be removed.

% Copyright 2021-2023 The MathWorks, Inc.

properties(Nontunable)
    % Sample Time
    SampleTime(1,1) double {mustBePositive, mustBeReal} = 0.1;
    % Output Struct
    OutputStruct = struct;
end

properties(Access = private)
    % INS Sensors
    INS 
    % Maximum Number of Vehicles
    MaxNumVehicles = 20;
     % Maximum Number of Actors
    MaxNumActors = 50;
    % Output Bus
    BSM
    % Message Count of all Vehicles
    MessageCount;
    % INS Input
    InsInput
end

methods(Access = protected)

    function sts = getSampleTimeImpl(obj)
        sts = createSampleTime(obj,'Type','Discrete','SampleTime',obj.SampleTime);
    end

    function setupImpl(obj)
        % Setup INS Sensor
        obj.INS = insSensor("MountingLocation",[0 0 0], ...
            'RollAccuracy',0.2,'PitchAccuracy',0.2,'YawAccuracy',1, ...
            'PositionAccuracy',1,'VelocityAccuracy',0.05, ...
            'AccelerationAccuracy',0,'AngularVelocityAccuracy',0, ...
            'RandomStream','mt19937ar with seed','Seed',72);
        % Initialize INS input struct
        obj.InsInput = struct('Position',[0 0 0],'Velocity',[0 0 0], ...
                                  'Orientation',[0 0 0],'Acceleration',[0 0 0], ...
                                  'AngularVelocity',[0 0 0]);
        % Initialize Output Bus
        obj.BSM = obj.OutputStruct;
        % Initialise Message Count for all Vehicles
        obj.MessageCount = zeros(obj.MaxNumActors,1);
    end

    function bsm = stepImpl(obj,actorsInfo,sceneOrigin)
        % Collect all inputs for INS.
        allClassID = vertcat(actorsInfo.Actors.ClassID);
        allPos = vertcat(actorsInfo.Actors.Position);
        allVel = vertcat(actorsInfo.Actors.Velocity);
        allRoll = vertcat(actorsInfo.Actors.Roll);
        allPitch = vertcat(actorsInfo.Actors.Pitch);
        allYaw = vertcat(actorsInfo.Actors.Yaw);
        allOrient = [allRoll, allPitch, allYaw];
        allAcc = vertcat(actorsInfo.Actors.Acceleration);
        allAngVel = vertcat(actorsInfo.Actors.AngularVelocity);

        % Get only vehicles by checking class IDs.
        isVeh = (allClassID == 1) | (allClassID == 2);
        numVeh = nnz(isVeh);

        % Check if number of vehicles less than maximum limit
        if numVeh > obj.MaxNumVehicles
            error("Number of vehicles in scenario must be " + ...
                "less than or equal %d",obj.MaxNumVehicles);
        end

        % Create INS input with motion quantities from vehicles.
        insInput = obj.InsInput;
        insInput.Position = allPos(isVeh,:);
        insInput.Velocity = allVel(isVeh,:);
        insInput.Orientation = allOrient(isVeh,:);
        insInput.Acceleration = allAcc(isVeh,:);
        insInput.AngularVelocity = allAngVel(isVeh,:);

        insMeasurement = obj.INS(insInput);
        insPos = insMeasurement.Position;
        insVel = insMeasurement.Velocity;
        insOrient = insMeasurement.Orientation;
        insAcc = insMeasurement.Acceleration;
        insAngVel = insMeasurement.AngularVelocity;
        insMeasIdx = 1;

        obj.BSM.NumOfBSM = 0;
        BSMIdx = 0;
        for i = 1:actorsInfo.NumActors
            if actorsInfo.Actors(i).ClassID == 1 || actorsInfo.Actors(i).ClassID == 2
                BSMIdx = BSMIdx+1;
                obj.BSM.NumOfBSM = obj.BSM.NumOfBSM+1;
                actorId = actorsInfo.Actors(i).ActorID;
                
                pos = insPos(insMeasIdx,:);
                vel = insVel(insMeasIdx,:);
                ori = insOrient(insMeasIdx,:);
                acc = insAcc(insMeasIdx,:);
                angvel = insAngVel(insMeasIdx,:);
                insMeasIdx = insMeasIdx + 1;
                
                % Calculate the Message Count
                obj.MessageCount(actorId) = obj.MessageCount(actorId) + 1;
                if obj.MessageCount(actorId)>127
                    obj.MessageCount(actorId) = 0;
                end
                obj.BSM.BSMCoreData(BSMIdx).MsgCnt  = int8(obj.MessageCount(actorId));
                obj.BSM.BSMCoreData(BSMIdx).Id      = uint32(actorsInfo.Actors(i).ActorID);
                obj.BSM.BSMCoreData(BSMIdx).SecMark = uint16(actorsInfo.Time/1e-3);
                
                % Convert local Cartesian coordinates to geographic coordinates
                [lat,lon,elev]  = local2latlon(pos(1),pos(2),pos(3),sceneOrigin);

                %% Convert raw data to the format specified in the SAE Standards

                % The geographic Lattitude & Longitude of an object,
                % expressed in 1/10th integer microdegrees(LSB = 1/10 micro
                % degree)
                obj.BSM.BSMCoreData(BSMIdx).Lattitude = int32(lat/(10^-7));           
                obj.BSM.BSMCoreData(BSMIdx).Longitude = int32(lon/(10^-7)); 

                % Elevation expressed in units of 10 cm steps above or
                % below the reference ellipsoid(LSB = 10cm or 0.1m)
                obj.BSM.BSMCoreData(BSMIdx).Elevation = int32(round(elev/0.1));       
                
                % SemiMajor accuracy which can be expected from a GNSS
                % system in 5cm steps (LSB = 0.05m)
                obj.BSM.BSMCoreData(BSMIdx).Accuracy.SemiMajor   = uint8(255);    % Set to unavailable

                % SemiMinor accuracy which can be expected from a GNSS
                % system in 5cm steps (LSB = 0.05m)
                obj.BSM.BSMCoreData(BSMIdx).Accuracy.SemiMinor   = uint8(255);    % Set to unavailable

                % Orientation of semi-major axis relative to true north 
                % (LSB units of 360/65535 deg = 0.0054932479)
                obj.BSM.BSMCoreData(BSMIdx).Accuracy.Orientation = uint16(65535); % Set to unavailable

                % Current Transmission State of vehicle as enumerated data
                obj.BSM.BSMCoreData(BSMIdx).Transmission = TransmissionState.TransmissionStateUnavailable; % Set to unavailable

                %  Vehicle speed expressed in unsigned units of 0.02 meters per second
                obj.BSM.BSMCoreData(BSMIdx).Speed   = uint16(round(norm(vel)/0.02));

                % Heading Angle of a vehicle expressed in unsigned units
                % of 0.0125 degrees from North
                obj.BSM.BSMCoreData(BSMIdx).Heading = uint16(round(rem((450-rem(360+ori(3),360)),360)/0.0125)); 

                % The angle of the driver’s steering wheel, expressed in a
                % signed (to the right being positive) value with 
                % LSB units of 1.5 degrees. 
                obj.BSM.BSMCoreData(BSMIdx).Angle   = int8(127); % Set to unavailable

                % LongAcc & LatAcc are signed acceleration of the 
                % vehicle along some known axis in units of 0.01 m/s^2
                obj.BSM.BSMCoreData(BSMIdx).AccelSet.LongAcc = int16(round(acc(1)/0.01));    
                obj.BSM.BSMCoreData(BSMIdx).AccelSet.LatAcc  = int16(round(acc(2)/0.01));

                % Vertical acceleration of the vehicle along the vertical 
                % axis in units of 0.02 G
                obj.BSM.BSMCoreData(BSMIdx).AccelSet.VertAcc = int8(-127); % Set to unavailable

                % The Yaw Rate of the vehicle, a signed value 
                % (to the right being positive) expressed in 0.01 degrees per second
                obj.BSM.BSMCoreData(BSMIdx).AccelSet.YawRate = int16(round(angvel(3)/0.01));

                % Information about the current brake and system control 
                % activity of the vehicle as enumerated data.
                % All are set to unavailable
                obj.BSM.BSMCoreData(BSMIdx).Brakes.WheelBrakes = BrakeAppliedStatus.BrakeAppliedStatusUnavailable;
                obj.BSM.BSMCoreData(BSMIdx).Brakes.Traction    = TractionControlStatus.TractionControlUnavailable;
                obj.BSM.BSMCoreData(BSMIdx).Brakes.Albs        = AntiLockBrakeStatus.ABSUnavailable;
                obj.BSM.BSMCoreData(BSMIdx).Brakes.Scs         = StabilityControlStatus.StabilityControlUnavailable;
                obj.BSM.BSMCoreData(BSMIdx).Brakes.BrakeBoost  = BrakeBoostApplied.BrakeBoostUnavailable;
                obj.BSM.BSMCoreData(BSMIdx).Brakes.AuxBrakes   = AuxiliaryBrakeStatus.AuxBrakesUnavailable;

                % Vehicle dimension with LSB units of 1 cm
                obj.BSM.BSMCoreData(BSMIdx).Size.Width  = uint16(actorsInfo.Actors(i).Width*100); 
                obj.BSM.BSMCoreData(BSMIdx).Size.Length = uint16(actorsInfo.Actors(i).Length*100); 
            end
        end
        bsm = obj.BSM;
    end
    
    function bsm = getOutputSizeImpl(obj) %#ok<MANU>
        % Return size for each output port
        bsm = 1;
    end
    
    function bsm = getOutputDataTypeImpl(obj) %#ok<MANU>
        % Return data type for each output port
        bsm = 'BusBSM';
    end
    
    function bsm = isOutputComplexImpl(obj) %#ok<MANU>
        % Return true for each output port with complex data
        bsm = false;
    end
    
    function bsm = isOutputFixedSizeImpl(obj) %#ok<MANU>
        % Return true for each output port with fixed size
        bsm = true;
    end
end

methods(Access = protected, Static)
    function flag = showSimulateUsingImpl
        % Return false if simulation mode hidden in System block dialog
        flag = true;
    end
end
end
