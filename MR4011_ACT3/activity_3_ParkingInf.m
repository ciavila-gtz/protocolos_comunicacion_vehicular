%% Activity 2 Parking Infrastructure
% El objetivo de esta actividad es desarrollar un sistema integral que
% incorpore V2X y un sistema automatizado de parqueo. Para ello, la
% actividad se desglosa en diferentes aspectos.

% Primero agreguemos todos los archivos utilizados al Path de Matlab
folder = fileparts(which('activity_3_ParkingInf.m')); 
addpath(genpath(folder));


%%  Primero, debemos generar la información que la infraestructura 
% compartirá con el vehículo usuario. Para ello, necesitamos crear un 
% mapa de costos del estacionamiento, lo cual podemos lograr extrayendo
% una sección del gráfico del escenario donde se ubica el parqueo.
scenario=scenario_final();
plot(scenario)
%% Pero solo necesitamos la región local del parqueo, utiliza la descripción
% del código que genera el parqueo para conocer los límites
matlab.desktop.editor.openAndGoToLine(which('scenario_final.m'), 64); 

%% sustituye los limites que determines en las lines a continuación

yWorldLimits = [-75 7.275];  % sustituye por los valores
xWorldLimits = [-7.275 75];  % sustituye por los valores

scenario=scenario_final();
plot(scenario)
axis off;
xlim(xWorldLimits);
ylim(yWorldLimits);

frame=getframe(gca);
imwrite(frame.cdata, 'PLOTS/parkingV2I.png')


%% Generaremos la imagen v2i con posiciones relativas
% Este será nuestro sistema de coordenadas locales, por lo que hay que ser
% conscientes cuando llevamos de posiciones globales al local. 
% Específicamente, ten en cuenta que el eje Y e X están intercambiados
% para el escenario de simulación. Puedes hacer plot(scenario) para que
% compruebes.

newyWorldLimits = [0 51];   %ancho del mapa (ajusta si usaste otras)
newxWorldLimits = [0 51];   %ancho del mapa (ajusta si usaste otras)

A=imread('PLOTS/parkingV2I.png');
RA = imref2d(size(A),newxWorldLimits,newyWorldLimits);
imshow(A,RA);

%% Ahora generaremos el mapa de costos (costmap). Para ello, utilizaremos 
% una función auxiliar (helperCreateCostmapFromImage) que crea el mapa
% de ocupancia a partir de una imagen RGB. Puedes obtener más detalles 
% sobre esta función examinando su código.

sceneImageBinary = helperCreateCostmapFromImage(A);

% Locación
mapLocation = [newxWorldLimits(1) newyWorldLimits(1)]; % [meters meters]

% Resolución del mapa
mapWidth = newyWorldLimits(2) - newyWorldLimits(1); % meters
cellSize = mapWidth/size(sceneImageBinary,2);

% Crear el costmap
costmap = vehicleCostmap(im2single(sceneImageBinary),CellSize=cellSize,MapLocation=mapLocation);

figure
plot(costmap,Inflation='off')
legend off


%% Ya tenemos nuestro mapa de costos en la variable costmap. Ahora
% crearemos nuestra ruta global y probaremos el enrutador con los 
% parámetros que seleccionemos en un pequeño simulador 2D. Ten en cuenta
% que el resultado final puede variar en la simulación 3D de Simulink, 
% ya que el simulador 2D no considera parámetros dinámicos ni la posición
% y velocidad reales del vehículo al entrar al estacionamiento. Se deja una
% trayectoria de prueba para la primera ejecución, luego se debe generar la
% propia.

% Variables del enrutador y planeador local
maxLocalPlanDistance = 2; % es la distancia en metros a partir de la cual se 
% calcula la continuacion de la ruta. Mas pequeño mas tarde espera a
% recalcular y funciona mas rápido el codigo, mas grande con mas antelación
% prepara la nueva ruta

minTurningRadius=4;    % es el mínimo radio en metros permitido a describir
% en las maniobras por el enrutador, mas pequeño mas fácil se mueve en el
% ambiente pero mas inestabilidad al timón, mas grande y el manejo es mas
% suave pero tal vez no encuente una ruta entre los obstaculos con ese
% radio de maniobra.

RRTConnectionDistance=2;  %  distancia en metros entre una conexión 
% de ruta y la otra. Mas grande y la trayectoria tiene transiciones
% menos bruscas pero con menos precisión. Mas pequeño la precisión de la
% ruta aumenta pero la ejecución es menos eficiente.

ConstantVel=2;    % para esta prueba usaremos una velocidad constante,
% y debe ser la misma con la que el vehiculo llega al parque en la ruta 
% encontrada en la actividad 1.


approxSeparation = 0.1; % parámetro para suavizar la trayectoria final 
% (en metros). Puede cambiarlo para ver los efectos.

% cargamos el modelo para acceder a las variables
modelName = 'MODEL_PV';
setup_01(ScenarioFcnName="scenario_final", Range=10);

% Objeto vehicleDimensions, para el enrutador y detector de colisiones.
vehicleDims = vehicleDimensions( ...
    egoVehicle.Length, ...
    egoVehicle.Width, ...
    egoVehicle.Height, ...
    'Wheelbase',          egoVehicle.Wheelbase, ...
    'RearOverhang',       egoVehicle.RearOverhang);

ccConfig = inflationCollisionChecker(vehicleDims, 5);
costmap.CollisionChecker = ccConfig;


% Planeador local, utilizando RRT de matlab
motionPlanner = pathPlannerRRT(costmap, ...
        'ConnectionDistance', RRTConnectionDistance, ...
        'MinIterations',      1000, ...
        'GoalTolerance',      [0.5 0.5 10], ...
        'MinTurningRadius',   minTurningRadius);

%% Primero cargaremos los datos de PV2I.mat, donde se encuentran el costmap
% y la ruta global (planRoute en formato de tabla) de prueba. 
% Abre esta tabla y observa que tiene tres campos: StartPose, EndPose
% y Attributes. Aquí es donde se generará la ruta global determinada. 
% En la primera fila de StartPose debe estar la posición final de la ruta
% del vehículo al entrar al parqueo, ya que de aquí será tomado por el 
% sistema automático. La columna de Attributes no la usaremos en este
% ejemplo pero cuando generes tu ruta puedes copiarla y pegarla para no
% dejar este campo vacio y genere un error. Carga las variables con este
% código y observa bien la tabla routePlan.

load('SCRIPTS/PARKING_INF/PV2I.mat')

% === Actualización de la Tabla routePlan (2 Segmentos) ===
% Es crucial que la tabla tenga exactamente 2 filas y que routePlan{1, "EndPose"}
% y routePlan{2, "StartPose"} coincidan.

% Segmento 1
routePlan{1, "StartPose"} = [47.89, 25.94, 180];
routePlan{1, "EndPose"}   = [15.0, 40.0, 210];

% Segmento 2
routePlan{2, "StartPose"} = [15.0, 40.0, 210];
routePlan{2, "EndPose"}   = [16.42, 5.18, 270];

% Segmento 3
%routePlan{3, "StartPose"} = [40.0, 15.0, 210];
%routePlan{3, "EndPose"}   = [16.42, 5.18, 270];
% Pbserva que tanto en los datos de Start pose y EndPose lo componen los
% siguientes datos [posX posY Theta_grados], en el mapa local, comprueba
% los angulos para entiendas la orientación cuando ejecutes el plan mas abajo.

%% Ahora cargada la ruta global de prueba y ejecutaremos el planificador 
% para cada una de las secciones Utiliza la variable segment y el número 
% de fila en la tabla routePlan para probar cada segmento y verificar que
% el planificador encuentre una trayectoria posible.

segment=1;  % segmento a calcular (fila)

startPose = routePlan{segment, "StartPose"}; % pose inicial [meters, meters, degrees]
goalPose  = routePlan{segment, "EndPose"};  % pose final

% realiza el plan local con RRT y muestra los resultados
refPath   = plan(motionPlanner, startPose, goalPose);
plot(motionPlanner)
hold on
[refPoses,refDirections] = interpolate(refPath);
numSmoothPoses = round(refPath.Length / approxSeparation);
[poses,directions] = smoothPathSpline(refPoses,refDirections,numSmoothPoses);
plot(poses(:,1),poses(:,2),'r--','LineWidth',2,'DisplayName','Smooth path')
hold off

%% Observa el plan global completo con cada una de sus etapas.

startPose = routePlan{1, "StartPose"}; % [meters, meters, degrees]
plot(costmap)

% Posición inicial
hold on
helperPlotVehicle(startPose, vehicleDims, DisplayName="Current Pose")
legend(Location="northwest")

for n = 1 : height(routePlan)
    % Resto del plan
    vehiclePose = routePlan{n, "EndPose"};
    
    % Graficar
    legendEntry = "Goal " + n;
    helperPlotVehicle(vehiclePose, vehicleDims, DisplayName=legendEntry);
end
hold off

%% Ahora ejecutaremos una simulación en 2D para comprobar lo generado. 
% En esta simulación se utilizan varias funciones de apoyo, por lo que 
% puedes revisar qué hace cada una dentro de sus respectivos archivos. 
% Sin embargo, las principales funciones a tener en cuenta, ya que 
% serán empleadas en el sistema de parqueo automatizado en Simulink, son:

% - HelperBehavioralPlanner: Se encarga de la capa de comportamiento. 
% Utilizando la ruta global, permite determinar cuál es la siguiente 
% maniobra en el trayecto.
% - HelperPathAnalyzer: Calcula la posición y velocidad de referencia 
% del vehículo, dado una trayectoria generada por el planificador local.

%Puedes encontrar más información sobre estas funciones revisando su 
% implementación.


sampleTime=0.1; % tiempo discreto de muestra (igual al Simulink)
controlRate = HelperFixedRate(1/sampleTime); % in Hertz
lonController = HelperLongitudinalController(SampleTime=sampleTime);

% HelperPathAnalyzer
pathAnalyzer = HelperPathAnalyzer(Wheelbase=vehicleDims.Wheelbase);

% HelperBehavioralPlanner (en este ejemplo no usamos el maxSteeringAngle 
% así que el valor es sin consecuencias)
maxSteeringAngle=35;
behavioralPlanner = HelperBehavioralPlanner(routePlan, maxSteeringAngle);


% pose inicial
currentPose = routePlan{1, "StartPose"}; % [meters, meters, degrees]

% Simulador 2D
vehicleSim = HelperVehicleSimulator(costmap, vehicleDims);

% Configure the simulator to show the trajectory.
vehicleSim.showTrajectory(true);
vehicleSim.showLegend(true);

% Set the vehicle pose and velocity.
vehicleSim.setVehiclePose(currentPose);
currentVel = 2;
vehicleSim.setVehicleVelocity(currentVel);

isGoalReached = false;
% Initialize variables to store vehicle path.
refPath = [];
localPath = [];


% Setup pathAnalyzer to trigger update of local path every 1 second.
localPlanningFrequency = 1; % 1/seconds
pathAnalyzer.PlanningPeriod = 1/localPlanningFrequency/sampleTime; % timesteps

showFigure(vehicleSim);

while ~isGoalReached

    % Planifica el siguiente segmento si se encuentra a la distancia
    % empleada para el replan local.
    if planNextSegment(behavioralPlanner, currentPose, 2*maxLocalPlanDistance)
        % Request next maneuver from behavioral layer.
        [nextGoal, plannerConfig, speedConfig] = requestManeuver(behavioralPlanner, ...
            currentPose, currentVel);
        
        if isempty(refPath)
            nextStart =currentPose;
        else
            nextStart = refPath(end,:);
        end

       newPath   = plan(motionPlanner, nextStart, nextGoal);
       [refPoses,refDirections] = interpolate(newPath);
       numSmoothPoses = round(newPath.Length / approxSeparation);
       [poses,directions] = smoothPathSpline(refPoses,refDirections,numSmoothPoses);
       % Append to refPath
       refPath = [refPath; poses];
       vehicleSim.plotReferencePath(refPath); % Plot reference path

      

    end

     % Configure path analyzer.
     pathAnalyzer.RefPoses     = poses;
     pathAnalyzer.Directions   = directions;
     pathAnalyzer.VelocityProfile = ConstantVel*ones(length(directions),1);

    % Find the reference pose on the path and the corresponding
    % velocity.
    [refPose, refVel, direction] = pathAnalyzer(currentPose, currentVel);
    
    % Update driving direction for the simulator.
    updateDrivingDirection(vehicleSim, direction);
    
    % Compute steering command.
    steeringAngle = lateralControllerStanley(refPose, currentPose, currentVel, ...
        Direction=direction, Wheelbase=vehicleDims.Wheelbase, PositionGain=4);
    
    % Compute acceleration and deceleration commands.
    lonController.Direction = direction;
    [accelCmd, decelCmd] = lonController(refVel, currentVel);
    
    % Simulate the vehicle using the controller outputs.
    drive(vehicleSim, accelCmd, decelCmd, steeringAngle);

    % Get current pose and velocity of the vehicle.
    currentPose  = getVehiclePose(vehicleSim);
    currentVel   = getVehicleVelocity(vehicleSim);
    
    % Check if the vehicle reaches the goal.
    isGoalReached = helperGoalChecker(nextGoal, currentPose, currentVel, ConstantVel, direction);
    
    % Wait for fixed-rate execution.
    waitfor(controlRate);
end


% Como se puede observar, existen diferencias entre la trayectoria de
% referencia y la trayectoria real que describe el vehículo, esto
% relacionado con el "kinematics" del vehiculo.

%% Llegados a este punto, ya podemos generar nuestro plan global para una
% nueva posición de parqueo y probarlo en el simulador 2D. Revisa las 
% ejecuciones anteriores y modifica la tabla routePlan para que se ajuste
% a tu plan global. Recuerda que la posición inicial debe coincidir con el
% final de tu trayectoria hacia el parqueo. Ten en cuenta la conversión
% de coordenadas de posición global a local y el ángulo de orientación.
% Una vez que hayas terminado, ejecuta el siguiente código para guardar 
% tu plan y mapa final.

save('SCRIPTS/PARKING_INF/PV2I.mat',"routePlan","costmap");


%% Copia esos valores en las posiciones correspondientes de la trayectoria hacia
% el parqueo. Repite este proceso ajustando los waypoints y las velocidades 
% hasta que logres una trayectoria y velocidades satisfactorias, asegurando que el vehículo 
% entre al parqueo correctamente y con la velocidad terminal deseada de 2 m/s.

% copia los nuevo waypoints aquí y justo debajo las velocidades
matlab.desktop.editor.openAndGoToLine(which('scenario_final.m'), 88); 

%% Abrimos el modelo Simulink

modelName = 'MODEL_PV';
open_system(modelName);

%% Lo nuevo en el modelo es el sistema de parqueo automático, y aquí puedes
% ver las partes que lo componen. Incluyen el activador del sistema, que 
% se activa una vez dentro del parqueo, y el script que controla el vehículo 
% en su ruta hacia el espacio de estacionamiento.

open_system("MODEL_PV/Vehicle Control/Parking System");

%% El script para el parqueo automatizado se encuentra en la función 
% de MATLAB "Parking Script", puedes acceder al código dando clic en el 
% ícono en forma de flecha en la parte inferior izquierda de la caja de la 
% funcion. Hay algunos cambios respecto a la ejecución en el 
% simulador 2D, principalmente relacionados con la arquitectura de 
% ejecución de funciones en Simulink. El código que se presenta a 
% continuación es solo una de las muchas formas de resolver este problema;
% puede ser modificado o adaptado según lo consideres. Sin embargo, 
% los parámetros de las variables deben modificarse obligatoriamente, 
% de acuerdo con lo determinado en la simulación 2D y el plan a seguir. 
% Incluye el código final en un archivo al entregar tu reporte, 
% junto con las variables que determinaste o las modificaciones que 
% realizaste.

%% Una vez finalizado, podemos ejecutar la simulación completa con el 
% siguiente código. Recuerda establecer el rango de comunicación y la 
% desviación estándar del Shadow Fading que calculaste al inicio de la actividad.

load('SCRIPTS/PARKING_INF/PV2I.mat')
modelName = 'MODEL_PV';
setup_01(ScenarioFcnName="scenario_final", Range=10);  % Range= rango 
SF_std=6;         % desviación estándar del Shadow Fading
mpcverbosity("off");
out=sim(modelName);


%% Por último, podemos visualizar una gráfica que muestra la velocidad de
% referencia y la velocidad real del vehículo a lo largo de la trayectoria.
% Estas difieren más cuando hay menos control sobre la trayectoria.
% También se grafica el ángulo de dirección.

scope = 'MODEL_PV/Vehicle Control/Parking System/Scope';
open_system(scope);
%% Cerramos el scope y activamos los mensajes
close_system(scope);
mpcverbosity("on");
