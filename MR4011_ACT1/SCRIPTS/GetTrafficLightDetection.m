function trafficLightState = GetTrafficLightDetection(spatOut,approachingIntersectionName,approachingSignalName)
    % Extract traffic light state for the current lane from Signal Phase
    % and Timing (SPaT)
    
    % NOTE: This is a helper function for example purposes and may be removed or
    % modified in the future.

    % Copyright 2021 The MathWorks, Inc.
    trafficLightState = -1;
    intersectionNames = [spatOut.Intersections(:).Name];
    % Check if message from approaching intersection exists
    idx = find(intersectionNames == approachingIntersectionName);
    if ~isempty(idx)
        intersectionSignalStatus = bin2dec(spatOut.Intersections(idx).Status);
        % Check if the signal in the intersection is in working state
        if intersectionSignalStatus == 0 || intersectionSignalStatus == 1 || intersectionSignalStatus == 5 || intersectionSignalStatus == 6
            % Find the signal state for the approaching signal
            signalNames = [spatOut.Intersections(idx).States(:).MovementName];
            sigIdx = find(signalNames == approachingSignalName);
            if spatOut.Intersections(idx).States(sigIdx).StateTimeSpeed.EventState == MovementPhaseState.PermissiveMovementAllowed
                trafficLightState = 2;
            elseif spatOut.Intersections(idx).States(sigIdx).StateTimeSpeed.EventState == MovementPhaseState.PermissiveClearance
                trafficLightState = 1;
            elseif spatOut.Intersections(idx).States(sigIdx).StateTimeSpeed.EventState == MovementPhaseState.StopAndRemain
                trafficLightState = 0;
            elseif spatOut.Intersections(idx).States(sigIdx).StateTimeSpeed.EventState == MovementPhaseState.Unavailable
                trafficLightState = -1;
            end
        end
    end
end