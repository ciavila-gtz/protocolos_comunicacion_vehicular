%% Create all necessary bus for Vehicle To Infrastructure Communication

% NOTE: This is a helper file for example purposes and 
% may be removed or modified in the future.

% Copyright 2021 The MathWorks, Inc.

%% Create Signal Phasing and Timing (SPAT) Bus

BusSPAT = Simulink.Bus;
BusSPAT.Description = '';
BusSPAT.DataScope = 'Auto';
BusSPAT.HeaderFile = '';
BusSPAT.Alignment = -1;
saveVarsTmp{1} = Simulink.BusElement;
saveVarsTmp{1}.Name = 'TimeStamp';
saveVarsTmp{1}.Complexity = 'real';
saveVarsTmp{1}.Dimensions = 1;
saveVarsTmp{1}.DataType = 'uint32';
saveVarsTmp{1}.Min = [];
saveVarsTmp{1}.Max = [];
saveVarsTmp{1}.DimensionsMode = 'Fixed';
saveVarsTmp{1}.SamplingMode = 'Sample based';
saveVarsTmp{1}.SampleTime = -1;
saveVarsTmp{1}.DocUnits = '';
saveVarsTmp{1}.Description = '';

saveVarsTmp{1}(2,1) = Simulink.BusElement;
saveVarsTmp{1}(2,1).Name = 'Name';
saveVarsTmp{1}(2,1).Complexity = 'real';
saveVarsTmp{1}(2,1).Dimensions = [1 1];
saveVarsTmp{1}(2,1).DataType = 'string';
saveVarsTmp{1}(2,1).Min = [];
saveVarsTmp{1}(2,1).Max = [];
saveVarsTmp{1}(2,1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(2,1).SamplingMode = 'Sample based';
saveVarsTmp{1}(2,1).SampleTime = -1;
saveVarsTmp{1}(2,1).DocUnits = '';
saveVarsTmp{1}(2,1).Description = '';

saveVarsTmp{1}(3,1) = Simulink.BusElement;
saveVarsTmp{1}(3,1).Name = 'Intersections';
saveVarsTmp{1}(3,1).Complexity = 'real';
saveVarsTmp{1}(3,1).Dimensions = [20 1];
saveVarsTmp{1}(3,1).DataType = 'Bus: BusIntersectionState';
saveVarsTmp{1}(3,1).Min = [];
saveVarsTmp{1}(3,1).Max = [];
saveVarsTmp{1}(3,1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(3,1).SamplingMode = 'Sample based';
saveVarsTmp{1}(3,1).SampleTime = -1;
saveVarsTmp{1}(3,1).DocUnits = '';
saveVarsTmp{1}(3,1).Description = '';

BusSPAT.Elements = saveVarsTmp{1};

clear saveVarsTmp

%%  Create V2I Realted Buses
BusIntersectionState = Simulink.Bus;
BusIntersectionState.Description = '';
BusIntersectionState.DataScope = 'Auto';
BusIntersectionState.HeaderFile = '';
BusIntersectionState.Alignment = -1;
saveVarsTmp{1} = Simulink.BusElement;
saveVarsTmp{1}.Name = 'Name';
saveVarsTmp{1}.Complexity = 'real';
saveVarsTmp{1}.Dimensions = 1;
saveVarsTmp{1}.DataType = 'string';
saveVarsTmp{1}.Min = [];
saveVarsTmp{1}.Max = [];
saveVarsTmp{1}.DimensionsMode = 'Fixed';
saveVarsTmp{1}.SamplingMode = 'Sample based';
saveVarsTmp{1}.SampleTime = -1;
saveVarsTmp{1}.DocUnits = '';
saveVarsTmp{1}.Description = '';

saveVarsTmp{1}(2,1) = Simulink.BusElement;
saveVarsTmp{1}(2,1).Name = 'Id';
saveVarsTmp{1}(2,1).Complexity = 'real';
saveVarsTmp{1}(2,1).Dimensions = 1;
saveVarsTmp{1}(2,1).DataType = 'Bus: BusId';
saveVarsTmp{1}(2,1).Min = [];
saveVarsTmp{1}(2,1).Max = [];
saveVarsTmp{1}(2,1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(2,1).SamplingMode = 'Sample based';
saveVarsTmp{1}(2,1).SampleTime = -1;
saveVarsTmp{1}(2,1).DocUnits = '';
saveVarsTmp{1}(2,1).Description = '';

saveVarsTmp{1}(3,1) = Simulink.BusElement;
saveVarsTmp{1}(3,1).Name = 'Revision';
saveVarsTmp{1}(3,1).Complexity = 'real';
saveVarsTmp{1}(3,1).Dimensions = [1 1];
saveVarsTmp{1}(3,1).DataType = 'int8';
saveVarsTmp{1}(3,1).Min = [];
saveVarsTmp{1}(3,1).Max = [];
saveVarsTmp{1}(3,1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(3,1).SamplingMode = 'Sample based';
saveVarsTmp{1}(3,1).SampleTime = -1;
saveVarsTmp{1}(3,1).DocUnits = '';
saveVarsTmp{1}(3,1).Description = '';

saveVarsTmp{1}(4,1) = Simulink.BusElement;
saveVarsTmp{1}(4,1).Name = 'Status';
saveVarsTmp{1}(4,1).Complexity = 'real';
saveVarsTmp{1}(4,1).Dimensions = 1;
saveVarsTmp{1}(4,1).DataType = 'string';
saveVarsTmp{1}(4,1).Min = [];
saveVarsTmp{1}(4,1).Max = [];
saveVarsTmp{1}(4,1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(4,1).SamplingMode = 'Sample based';
saveVarsTmp{1}(4,1).SampleTime = -1;
saveVarsTmp{1}(4,1).DocUnits = '';
saveVarsTmp{1}(4,1).Description = '';

saveVarsTmp{1}(5,1) = Simulink.BusElement;
saveVarsTmp{1}(5,1).Name = 'Moy';
saveVarsTmp{1}(5,1).Complexity = 'real';
saveVarsTmp{1}(5,1).Dimensions = [1 1];
saveVarsTmp{1}(5,1).DataType = 'uint32';
saveVarsTmp{1}(5,1).Min = [];
saveVarsTmp{1}(5,1).Max = [];
saveVarsTmp{1}(5,1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(5,1).SamplingMode = 'Sample based';
saveVarsTmp{1}(5,1).SampleTime = -1;
saveVarsTmp{1}(5,1).DocUnits = '';
saveVarsTmp{1}(5,1).Description = '';

saveVarsTmp{1}(6,1) = Simulink.BusElement;
saveVarsTmp{1}(6,1).Name = 'TimeStamp';
saveVarsTmp{1}(6,1).Complexity = 'real';
saveVarsTmp{1}(6,1).Dimensions = [1 1];
saveVarsTmp{1}(6,1).DataType = 'uint16';
saveVarsTmp{1}(6,1).Min = [];
saveVarsTmp{1}(6,1).Max = [];
saveVarsTmp{1}(6,1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(6,1).SamplingMode = 'Sample based';
saveVarsTmp{1}(6,1).SampleTime = -1;
saveVarsTmp{1}(6,1).DocUnits = '';
saveVarsTmp{1}(6,1).Description = '';

saveVarsTmp{1}(7,1) = Simulink.BusElement;
saveVarsTmp{1}(7,1).Name = 'States';
saveVarsTmp{1}(7,1).Complexity = 'real';
saveVarsTmp{1}(7,1).Dimensions = [10 1];
saveVarsTmp{1}(7,1).DataType = 'Bus: BusStates';
saveVarsTmp{1}(7,1).Min = [];
saveVarsTmp{1}(7,1).Max = [];
saveVarsTmp{1}(7,1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(7,1).SamplingMode = 'Sample based';
saveVarsTmp{1}(7,1).SampleTime = -1;
saveVarsTmp{1}(7,1).DocUnits = '';
saveVarsTmp{1}(7,1).Description = '';

BusIntersectionState.Elements = saveVarsTmp{1};

clear saveVarsTmp
%%  Create BusID

BusId = Simulink.Bus;
BusId.Description = '';
BusId.DataScope = 'Auto';
BusId.HeaderFile = '';
BusId.Alignment = -1;
saveVarsTmp{1} = Simulink.BusElement;
saveVarsTmp{1}.Name = 'Region';
saveVarsTmp{1}.Complexity = 'real';
saveVarsTmp{1}.Dimensions = [1 1];
saveVarsTmp{1}.DataType = 'uint16';
saveVarsTmp{1}.Min = [];
saveVarsTmp{1}.Max = [];
saveVarsTmp{1}.DimensionsMode = 'Fixed';
saveVarsTmp{1}.SamplingMode = 'Sample based';
saveVarsTmp{1}.SampleTime = -1;
saveVarsTmp{1}.DocUnits = '';
saveVarsTmp{1}.Description = '';

saveVarsTmp{1}(2,1) = Simulink.BusElement;
saveVarsTmp{1}(2,1).Name = 'Id';
saveVarsTmp{1}(2,1).Complexity = 'real';
saveVarsTmp{1}(2,1).Dimensions = [1 1];
saveVarsTmp{1}(2,1).DataType = 'uint16';
saveVarsTmp{1}(2,1).Min = [];
saveVarsTmp{1}(2,1).Max = [];
saveVarsTmp{1}(2,1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(2,1).SamplingMode = 'Sample based';
saveVarsTmp{1}(2,1).SampleTime = -1;
saveVarsTmp{1}(2,1).DocUnits = '';
saveVarsTmp{1}(2,1).Description = '';

BusId.Elements = saveVarsTmp{1};

clear saveVarsTmp
%% Create Bus States
BusStates = Simulink.Bus;
BusStates.Description = '';
BusStates.DataScope = 'Auto';
BusStates.HeaderFile = '';
BusStates.Alignment = -1;
saveVarsTmp{1} = Simulink.BusElement;
saveVarsTmp{1}.Name = 'MovementName';
saveVarsTmp{1}.Complexity = 'real';
saveVarsTmp{1}.Dimensions = 1;
saveVarsTmp{1}.DataType = 'string';
saveVarsTmp{1}.Min = [];
saveVarsTmp{1}.Max = [];
saveVarsTmp{1}.DimensionsMode = 'Fixed';
saveVarsTmp{1}.SamplingMode = 'Sample based';
saveVarsTmp{1}.SampleTime = -1;
saveVarsTmp{1}.DocUnits = '';
saveVarsTmp{1}.Description = '';

saveVarsTmp{1}(2,1) = Simulink.BusElement;
saveVarsTmp{1}(2,1).Name = 'SignalGroup';
saveVarsTmp{1}(2,1).Complexity = 'real';
saveVarsTmp{1}(2,1).Dimensions = [1 1];
saveVarsTmp{1}(2,1).DataType = 'uint8';
saveVarsTmp{1}(2,1).Min = [];
saveVarsTmp{1}(2,1).Max = [];
saveVarsTmp{1}(2,1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(2,1).SamplingMode = 'Sample based';
saveVarsTmp{1}(2,1).SampleTime = -1;
saveVarsTmp{1}(2,1).DocUnits = '';
saveVarsTmp{1}(2,1).Description = '';

saveVarsTmp{1}(3,1) = Simulink.BusElement;
saveVarsTmp{1}(3,1).Name = 'StateTimeSpeed';
saveVarsTmp{1}(3,1).Complexity = 'real';
saveVarsTmp{1}(3,1).Dimensions = 1;
saveVarsTmp{1}(3,1).DataType = 'Bus: BusStateTimeSpeed';
saveVarsTmp{1}(3,1).Min = [];
saveVarsTmp{1}(3,1).Max = [];
saveVarsTmp{1}(3,1).DimensionsMode = 'Fixed';
saveVarsTmp{1}(3,1).SamplingMode = 'Sample based';
saveVarsTmp{1}(3,1).SampleTime = -1;
saveVarsTmp{1}(3,1).DocUnits = '';
saveVarsTmp{1}(3,1).Description = '';

BusStates.Elements = saveVarsTmp{1};

clear saveVarsTmp
%% Create BusStateTimeSpeed

BusStateTimeSpeed = Simulink.Bus;
BusStateTimeSpeed.Description = '';
BusStateTimeSpeed.DataScope = 'Auto';
BusStateTimeSpeed.HeaderFile = '';
BusStateTimeSpeed.Alignment = -1;
saveVarsTmp{1} = Simulink.BusElement;
saveVarsTmp{1}.Name = 'EventState';
saveVarsTmp{1}.Complexity = 'real';
saveVarsTmp{1}.Dimensions = [1 1];
saveVarsTmp{1}.DataType = 'Enum:MovementPhaseState';
saveVarsTmp{1}.Min = [];
saveVarsTmp{1}.Max = [];
saveVarsTmp{1}.DimensionsMode = 'Fixed';
saveVarsTmp{1}.SamplingMode = 'Sample based';
saveVarsTmp{1}.SampleTime = -1;
saveVarsTmp{1}.DocUnits = '';
saveVarsTmp{1}.Description = '';

BusStateTimeSpeed.Elements = saveVarsTmp{1};

clear saveVarsTmp
