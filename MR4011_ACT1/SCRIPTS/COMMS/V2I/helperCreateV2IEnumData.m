%% Enum Classes Used in V2I Simulator

% NOTE: This is a helper file for example purposes
% and may be removed or modified in the future.

% Copyright 2021 The MathWorks, Inc.

% Define MovementPhaseState
Simulink.defineIntEnumType('MovementPhaseState',{'Unavailable','Dark','StopThenProceed','StopAndRemain','PreMovement','PermissiveMovementAllowed','ProtectedMovementAllowed','PermissiveClearance','ProtectedClearance','CautionConflictingTraffic'},[0;1;2;3;4;5;6;7;8;9],'Description', 'Movement Phase State','DefaultValue', 'Unavailable')