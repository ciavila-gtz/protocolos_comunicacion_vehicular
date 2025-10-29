%% Enum Classes Used in V2V Simulator

% NOTE: This is a helper file for example purposes
% and may be removed or modified in the future.

% Copyright 2021 The MathWorks, Inc.

% Define AuxiliaryBrakeStatus
Simulink.defineIntEnumType('AuxiliaryBrakeStatus',{'AuxBrakesUnavailable','AuxBrakesOff','AuxBrakesOn','AuxBrakesReserved'},[0;1;2;3],'Description', 'Auxiliary Brake Status','DefaultValue', 'AuxBrakesUnavailable')

% Define StabilityControlStatus
Simulink.defineIntEnumType('StabilityControlStatus',{'StabilityControlUnavailable','StabilityControlOff','StabilityControlOn','StabilityControlEngaged'},[0;1;2;3],'Description', 'Stability Control Status','DefaultValue', 'StabilityControlUnavailable')

% Define AntiLockBrakeStatus
Simulink.defineIntEnumType('AntiLockBrakeStatus',{'ABSUnavailable','ABSOff','ABSOn','ABSEngaged'},[0;1;2;3],'Description', 'Anti Lock Brake Status','DefaultValue', 'ABSUnavailable')

% Define BrakeAppliedStatus
Simulink.defineIntEnumType('BrakeAppliedStatus',{'BrakeAppliedStatusUnavailable','LeftFront','LeftRear','RightFront','RightRear'},[0;1;2;3;4],'Description', 'Brake Applied Status','DefaultValue', 'BrakeAppliedStatusUnavailable')

% Define TransmissionState
Simulink.defineIntEnumType('TransmissionState',{'Neutral','Park','ForwardGears','ReverseGears','Reserved1','Reserved2','Reserved3','TransmissionStateUnavailable'},[0;1;2;3;4;5;6;7],'Description', 'Transmission State','DefaultValue', 'TransmissionStateUnavailable')

% Define BrakeBoostApplied
Simulink.defineIntEnumType('BrakeBoostApplied',{'BrakeBoostUnavailable','BrakeBoostOff','BrakeBoostOn'},[0;1;2],'Description', 'Brake Boost Applied','DefaultValue', 'BrakeBoostUnavailable')

% Define TractionControlStatus
Simulink.defineIntEnumType('TractionControlStatus',{'TractionControlUnavailable','TractionControlOff','TractionControlOn','TractionControlEngaged'},[0;1;2;3],'Description', 'Traction Control Status','DefaultValue', 'TractionControlUnavailable')