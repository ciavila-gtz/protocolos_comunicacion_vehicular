classdef V2ITransmitter < matlab.System
    % HelperV2ITransmitter Models a V2I Transmitter. 
    % This generates the Signal Phase and Timing(SPaT) message using the 
    % traffic signal states obtained from the traffic light sensor.

    % NOTE: The name of this System Object and its functionality may
    % change without notice in a future release,
    % or the System Object itself may be removed.
    
    % Copyright 2021 The MathWorks, Inc.

    properties(Nontunable)
        RegionInfo   = struct;
        % Ouput Struct
        OutputStruct = struct;
    end

    properties(Access = private)
        % Output Bus
        SPAT
        % Names of Region & Traffic signals
        % Number of intersection in the current region
        NumOfIntersection
        % Number of traffic signals in the appraching intersection
        NumofSignals
        % Date & Time at the start if year
        StartTime
    end

    methods(Access = protected)
        function setupImpl(obj)
            % Initialise the Output Bus 
            obj.SPAT = obj.OutputStruct;

            obj.NumOfIntersection = numel(obj.RegionInfo.Intersections);
            for intersectionNum = 1:obj.NumOfIntersection
                obj.NumofSignals(intersectionNum) = numel(obj.RegionInfo.Intersections(intersectionNum).TrafficSignal);
            end

            % Based on current year set the start date and time
            obj.StartTime   = datetime(year(datetime),1,1,0,0,0);
            % Minute of the year 
            moy = hours(datetime- obj.StartTime)*60;

            obj.SPAT.TimeStamp = uint32(moy); 
            obj.SPAT.Name      = obj.RegionInfo.RegionName;

            for intersectionNum = 1:obj.NumOfIntersection
                obj.SPAT.Intersections(intersectionNum).Name       = obj.RegionInfo.Intersections(intersectionNum).Name;
                obj.SPAT.Intersections(intersectionNum).Id.Region  = uint16(0);
                obj.SPAT.Intersections(intersectionNum).Id.Id      = uint16(intersectionNum);
                obj.SPAT.Intersections(intersectionNum).Revision   = int8(0);
                obj.SPAT.Intersections(intersectionNum).Status     = dec2bin(6,4);   % trafficDependentOperation 
                obj.SPAT.Intersections(intersectionNum).Moy        = uint32(moy); 
                obj.SPAT.Intersections(intersectionNum).TimeStamp  = uint16(65535);  % Set to unavailable
                % Initialise signal name & states
                for signalNum = 1:obj.NumofSignals(intersectionNum)
                    obj.SPAT.Intersections(intersectionNum).States(signalNum).MovementName   = obj.RegionInfo.Intersections(intersectionNum).TrafficSignal(signalNum).Name;
                    obj.SPAT.Intersections(intersectionNum).States(signalNum).SignalGroup    = uint8(signalNum);
                    obj.SPAT.Intersections(intersectionNum).States(signalNum).StateTimeSpeed.EventState = MovementPhaseState.Unavailable; 
                end

            end
        end

        function spat = stepImpl(obj,trafficLightStates)
            % Get current date and time
            currentTime = datetime;
            % Minute of the year 
            moy = hours(currentTime- obj.StartTime)*60;
            obj.SPAT.TimeStamp = uint32(moy);

            % Set the current traffic signal state
            for i = 1:obj.NumOfIntersection
                obj.SPAT.Intersections(i).Moy = uint32(moy);
                for j = 1:obj.NumofSignals(i)
                    if trafficLightStates(j) == 2      % Signal is Green
                        obj.SPAT.Intersections(i).States(j).StateTimeSpeed.EventState  = MovementPhaseState.PermissiveMovementAllowed;
                    elseif trafficLightStates(j) == 1  % Signal is Yellow
                        obj.SPAT.Intersections(i).States(j).StateTimeSpeed.EventState  = MovementPhaseState.PermissiveClearance;
                    elseif trafficLightStates(j) == 0  % % Signal is Red
                        obj.SPAT.Intersections(i).States(j).StateTimeSpeed.EventState  = MovementPhaseState.StopAndRemain;
                    else
                        obj.SPAT.Intersections(i).States(j).StateTimeSpeed.EventState  = MovementPhaseState.Unavailable;
                    end

                end
            end
            spat = obj.SPAT;
        end

        function spat = getOutputSizeImpl(obj) %#ok<MANU>
            % Return size for each output port
            spat = 1;
        end
        
        function spat = getOutputDataTypeImpl(obj) %#ok<MANU>
            % Return data type for each output port
            spat = 'BusSPAT';
        end
        
        function spat = isOutputComplexImpl(obj) %#ok<MANU>
            % Return true for each output port with complex data
             spat = false;
        end
        
        function spat = isOutputFixedSizeImpl(obj) %#ok<MANU>
            % Return true for each output port with fixed size
            spat = true;
        end
    end

    methods(Access = protected, Static)
        function simMode = getSimulateUsingImpl
            % Return only allowed simulation mode in System block dialog
            simMode = "Interpreted execution";
        end

        function flag = showSimulateUsingImpl
            % Return false if simulation mode hidden in System block dialog
            flag = false;
        end
    end
end
