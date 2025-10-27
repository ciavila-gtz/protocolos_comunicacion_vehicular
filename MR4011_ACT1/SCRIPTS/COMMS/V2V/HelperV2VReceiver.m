classdef HelperV2VReceiver < matlab.System
    % HelperV2VReceiver Models a V2V receiver. 
    % The V2V Receiver receives the Basic Safety Message transmitted by the
    % target vehicles based on SNR graphs. The SNR data is adjusted based 
    % on the range and loaded during simulation.

    % NOTE: The name of this System Object and its functionality may
    % change without notice in a future release,
    % or the System Object itself may be removed.
    
    % Copyright 2021-2023 The MathWorks, Inc.

    properties(Nontunable)
        % V2V Channel Info
        SnrCurves = struct;
        % Output Struct
        OutputStruct = struct;
       
    end

    % Pre-computed constants
    properties(Access = private)
        % Holds the information of precomputed snr curves
        DistanceToSnrInfo
        SnrToTputInfo
        % Holds the information of snr & distance limits
        MaxVehDist;
        SnrMin;
        SnrMax;
        % Maximum range
        MaxRange = 1000;
        % Output Bus
        BSMOut
        % Minimum Throughput Percentage
        MinTput = 60;

        
    end

    methods(Access = protected)
        function sts = getSampleTimeImpl(obj)
            sts = createSampleTime(obj,'Type','Inherited');
        end
        function setupImpl(obj)
            % Distance to SNR Relation
            obj.DistanceToSnrInfo = obj.SnrCurves.dist2snr;
            % SNR to Throughput Relation
            obj.SnrToTputInfo = obj.SnrCurves.snr2tput;
            % Get the limits for Distance & SNR
            obj.MaxVehDist = obj.DistanceToSnrInfo(end,1);
            obj.SnrMin = obj.SnrToTputInfo(1,1);
            obj.SnrMax = obj.SnrToTputInfo(end,1);
            % Initialize Output Bus
            obj.BSMOut = obj.OutputStruct;
        end

        function bsmOut = stepImpl(obj,bsm,egoPose,sceneOrigin, SF_std)
            numReceivedSignal = 0;
            bsmOut = obj.BSMOut;
            bsmOutIdx = 1;
            for i = 1:bsm.NumOfBSM
                if bsm.BSMCoreData(i).Id > 0
                    % Compute the Ego to Target Vehicle distance
                    vehPos  = [0,0,0];
                    lla = [double(bsm.BSMCoreData(i).Lattitude)*10^-7,double(bsm.BSMCoreData(i).Longitude)*10^-7,double(bsm.BSMCoreData(i).Elevation)*0.1];
                    % Convert geographic coordinates to local Cartesian coordinates
                    [vehPos(1),vehPos(2),vehPos(3)] = latlon2local(lla(1),lla(2),lla(3),sceneOrigin);
                    v2vdist = norm(egoPose.Position - vehPos);                

                    % Find the throughput percentage for the v2vdist using
                    % the precomputed snr curves.
                    if v2vdist<obj.MaxVehDist
                        v2vdist     = max(1,round(v2vdist));
                        snrEstimate = min(max(obj.SnrMin,interp1(obj.DistanceToSnrInfo(:,1),obj.DistanceToSnrInfo(:,2),v2vdist)),obj.SnrMax)+SF_std*randn(1);
                        tput        = interp1(obj.SnrToTputInfo(:,1),obj.SnrToTputInfo(:,2),snrEstimate);
                    else
                        tput = 0;
                    end
                    % Receive the signal based on throughput
                    receivedFlag = randi([obj.MinTput 100]) <= tput;
                    if receivedFlag
                        numReceivedSignal = numReceivedSignal+1;
                        bsmOut.IsValidTime = true;
                        bsmOut.BSMCoreData(bsmOutIdx) = bsm.BSMCoreData(i);
                        bsmOutIdx = bsmOutIdx+1;
                    end
                end
            end
            bsmOut.NumOfBSM = numReceivedSignal;
        end

        function bsmOut  = getOutputSizeImpl(obj) %#ok<MANU>
            % Return size for each output port
            bsmOut = 1;
        end
        
        function bsmOut = getOutputDataTypeImpl(obj) %#ok<MANU>
            % Return data type for each output port
            bsmOut = 'BusBSM';
        end
        
        function bsmOut = isOutputComplexImpl(obj) %#ok<MANU>
            % Return true for each output port with complex data
            bsmOut = false;
        end
        
        function bsmOut = isOutputFixedSizeImpl(obj) %#ok<MANU>
            % Return true for each output port with fixed size
            bsmOut = true;
        end
    end

    methods(Access = protected, Static)
        function flag = showSimulateUsingImpl
            % Return false if simulation mode hidden in System block dialog
            flag = true;
        end
    end
end
