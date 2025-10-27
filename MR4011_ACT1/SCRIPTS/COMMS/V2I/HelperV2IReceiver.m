classdef HelperV2IReceiver < matlab.System
    % HelperV2IReceiver Models a V2I Receiver.
    % This receives the Signal Phase and Timing(SPaT) transmitted by the 
    % target vehicles based on SNR graphs. The SNR data is loaded and
    % adjusted during simulation based on the range specified.

    % NOTE: The name of this System Object and its functionality may
    % change without notice in a future release,
    % or the System Object itself may be removed.
    
    % Copyright 2021 The MathWorks, Inc.

    properties(Nontunable)
        % V2I Channel Info
        SnrCurves = struct;
        % Output Struct
        OutputStruct = struct;
    end

    properties(Access = private)
        % Holds the information of precomputed snr curves 
        DistanceToSnrInfo
        SnrToTputInfo
        % Holds the information of snr & distance limits
        MaxDist;
        SnrMin;
        SnrMax;
        MaxRange = 1000;
        % Output Bus
        SPATOut
        % Minimum Throughput Percentage
        MinTput = 60;
    end

    methods(Access = protected)
        function setupImpl(obj)
            % Distance to SNR Relation
            obj.DistanceToSnrInfo = obj.SnrCurves.dist2snr;
            % SNR to Throughput Relation
            obj.SnrToTputInfo = obj.SnrCurves.snr2tput;
            % Get the limits for Distance & SNR
            obj.MaxDist = obj.DistanceToSnrInfo(end,1);
            obj.SnrMin = obj.SnrToTputInfo(1,1);
            obj.SnrMax = obj.SnrToTputInfo(end,1);
            % Intialise Output Bus
            obj.SPATOut = obj.OutputStruct;
        end

        function spatOut = stepImpl(obj,spat,distanceToTrafficLight, SF_std)
            spatOut = obj.SPATOut;
            % Find the throughput percentage for the traffic light to ego
            % distance using the precomputed snr curves.
            if distanceToTrafficLight<obj.MaxDist
                v2idist = max(1,round(distanceToTrafficLight));
                snrEstimate = min(max(obj.SnrMin,interp1(obj.DistanceToSnrInfo(:,1),obj.DistanceToSnrInfo(:,2),v2idist)),obj.SnrMax)+SF_std*randn(1);
                tput        = interp1(obj.SnrToTputInfo(:,1),obj.SnrToTputInfo(:,2),snrEstimate);
            else
                tput = 0;
            end
            % Receive signal based on throughput percentage
            receivedFlag = randi([obj.MinTput 100]) <= tput;
            if receivedFlag
                spatOut = spat;
            end
        end
        
        function SPATOut = getOutputSizeImpl(obj) %#ok<MANU>
            % Return size for each output port
            SPATOut = 1;
        end
        
        function SPATOut = getOutputDataTypeImpl(obj) %#ok<MANU>
            % Return data type for each output port
            SPATOut = 'BusSPAT';
        end
        
        function SPATOut = isOutputComplexImpl(obj) %#ok<MANU>
            % Return true for each output port with complex data
             SPATOut = false;
        end
        
        function SPATOut = isOutputFixedSizeImpl(obj) %#ok<MANU>
            % Return true for each output port with fixed size
            SPATOut = true;
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
