%% Activity 1
% Esta simulación muestra un ejemplo de las aplicaciones V2X (vehículo a todo). 
% Este ejemplo, basado en MATLAB Simulink, presenta interacciones del vehículo con
% una infraestructura (V2I), en este caso un semáforo, así como con otros vehículos (V2V), 
% para tomar decisiones durante su trayectoria. La información obtenida a través de las
% comunicaciones V2I y V2V permite que el vehículo tenga una percepción precisa de su 
% entorno y pueda actuar en correspondencia, optimizando su movimiento y mejorando la 
% seguridad vial mediante la toma de decisiones inteligentes en tiempo real.

% Primero agreguemos todos los archivos utilizados al Path de Matlab

folder = fileparts(which('activity_1.m')); 
addpath(genpath(folder));

%% Primero, abramos el modelo de Simulink para visualizar la estructura del sistema.
% Este modelo incluye los bloques necesarios para simular las interacciones V2X
modelName = 'MODEL_PV';
open_system(modelName);


%% El simulador está conformado principalmente por cuatro subsistemas: 
% Sensores y ambiente, que capturan y representan el entorno del vehículo; 
% Comunicaciones, encargado de gestionar las interacciones V2X (V2I y V2V); 
% el Subsistema de lógica, que procesa la información recibida y toma decisiones;
% y el Subsistema de control del vehículo, responsable de ejecutar las maniobras 
% de conducción basadas en las decisiones tomadas. Además de estos subsistemas, 
% se incluye una función de visualización.

% El subsistema de Sensores y ambiente contiene información clave del escenario, 
% incluyendo las constantes y la configuración del semáforo. 
% Este subsistema proporciona los datos necesarios para simular el entorno del vehículo. 
% Puedes comprobar sus componentes aquí:

open_system("MODEL_PV/Scenario and Environment");


%% El simulador V2V representa la comunicación entre vehículos mediante mensajes BSM, 
% que contienen información sobre su estado (posición, velocidad, dirección, etc.). 
% El transmisor V2V genera estos mensajes usando datos del vehículo, y el receptor V2V los
% convierte en señales para el vehículo principal, considerando las características del canal
% de comunicación.
% Un BSM (Basic Safety Message) generado contiene los siguientes atributos para cada vehículo:
%
% - MsgCount: Número de secuencia para una serie de mensajes.
% - TemporaryId: Identificador aleatorio del dispositivo.
% - DSecond: Tiempo en el que se determinó la posición.
% - Latitude: Latitud geográfica del vehículo.
% - Longitude: Longitud geográfica del vehículo.
% - Elevation: Posición geográfica del vehículo por encima o por debajo del elipsoide de referencia.
% - PositionalAccuracy: Precisión de la determinación de la posición.
% - TransmissionState: Estado actual de la transmisión del vehículo.
% - Speed: Velocidad del vehículo.
% - Heading: Dirección actual del vehículo, en grados respecto al norte.
% - SteeringWheelAngle: Ángulo del volante del vehículo.
% - AccelerationSet4Way: Aceleración del vehículo en tres direcciones y la tasa de rotación de guiñada.
% - BrakeSystemStatus: Estado actual del sistema de frenos y control.
% - VehicleSize: Longitud y ancho del vehículo.

% Por su parte el simulador V2I maneja la comunicación entre el vehículo y la infraestructura,
% en este caso un semáforo, que envía mensajes (Signal Phase and Timing) SPAT con el estado de las intersecciones. 
% El receptor V2I recibe estos mensajes si la calidad del canal es suficiente según la distancia
% entre transmisor y receptor.

% Un SPAT (Signal Phase and Timing) generado contiene los siguientes atributos:

% - TimeStamp: Minuto del año.
% - Name: Nombre de la región.
% - Intersection: Información del semáforo para cada intersección en una región.

open_system("MODEL_PV/COMMS");

%% El subsistema de Lógica gestiona las interacciones entre el vehículo principal, 
% un vehículo cruzando o en frente, y el semáforo. El modelo calcula la velocidad relativa 
% y la distancia relativa con respecto al MIO (objeto más importante). 
% El bloque Find MIO de MATLAB identifica al MIO que puede ser un vehículo líder en el 
% mismo carril o un vehículo que cruza y podría colisionar con el vehículo principal. 
% El bloque proporciona la distancia y velocidad relativas del vehículo principal
% en relación con el MIO. 

open_system("MODEL_PV/Logic");

%% Por último, el subsistema de control es responsable del manejo y la dinámica del vehículo. 
% Este subsistema procesa las decisiones tomadas por la lógica de control y las convierte en
% acciones de conducción, como la aceleración, frenado y dirección, asegurando que el vehículo 
% siga la trayectoria planificada de manera segura y eficiente.

open_system("MODEL_PV/Vehicle Control");

%% Con el modelo abierto, podemos observar una representación del escenario que utilizaremos 
% en las próximas actividades del curso. Este está compuesto por una intersección controlada 
% por semáforo y una zona de estacionamiento de vehículos. Ver la figura,
% ejecuta:
plot(scenario)
%% Ahora ejecutaremos un escenario en el que un vehículo de grandes dimensiones se encuentra al
% frente y otro vehículo cruzará el semáforo en rojo. El parámetro Range nos permite establecer
% el rango de comunicación "garantizada" del vehículo; al configurar el rango en 0, se indica que 
% no habrá comunicación vehicular. Realiza la primera configuración con un rango de 0.

setup_01(ScenarioFcnName="scenario_01", Range=0);

%% Ejecuta la simulación por sin control del paso de ejecución.
modelName = 'MODEL_PV';
set_param(modelName,"EnablePacing","off")
mpcverbosity("off");
out=sim(modelName);

%% Puedes graficar alguno de los resultados de la simulacion con la siguiente funcion:
% El gráfico de Estado del semáforo muestra los estados del semáforo detectados 
% por el sensor TL 1.
% El gráfico de Número de detecciones V2V muestra los vehículos detectados mediante comunicación V2V.
% El gráfico de MIO muestra el tipo de MIO en cada instante de tiempo, vehículo líder o de cruce.
% El gráfico de Aceleración del vehículo ego muestra el perfil de aceleración controlado. 
% El gráfico de Ángulo Yaw muestra el perfil del ángulo del vehiculo. 

logsout=out.logsout;
helperTLNWithV2XResults(logsout)

% Toma nota de los resultados para cada uno de estos casos teniendo en
% cuenta la trayectoria del vehiculo, si se detectan o no mensajes V2V, 
% respeto a las señales del semáforo y la ocurrencia o no de accidentes.
% Luego regresa al setup del escenario 1 (linea 99) y prueba bajo un rango
% de comunicaciones de 40 metros. Grafica los nuevos resultados y observa
% en comparacion al anterior los resultados obtenidos.
%% En dependencia de la PC en que se ejecute el paso de la simulación puede ir más rápido 
% o lento. Un método de control del paso (para más lenta ejecución) se puede realizar
% ejecutando el siguiente código (de 0 a 1 siendo no control), empléelo si lo necesita:  

modelName = 'MODEL_PV';
set_param(modelName,"EnablePacing","off")
set_param(modelName,"PacingRate",0.5)
set_param(modelName, 'StopTime', '25')   % tambien se puede controlar el tiempo de ejecución

out=sim(modelName);

%% Este segundo escenario nos muestra que la existencia de comunicaciones vehiculares no 
% está garantizada, y que la cobertura efectiva juega un papel clave en un entorno dinámico, 
% donde el tiempo de reacción ante un evento es crucial. En este escenario, el vehículo 
% principal realiza un giro a la izquierda en el semáforo, mientras que un infractor se 
% pasa en rojo, lo que obliga al vehículo a reaccionar, teniendo en cuenta la dinámica 
% del cuerpo en movimiento. Prueba este escenario con rangos de 10, 20 y 40 metros 
% y observa cuál es la distancia que mejor permite una reacción a tiempo.

setup_01(ScenarioFcnName="scenario_02", Range=20);
%% Ejecutar

modelName = 'MODEL_PV';
set_param(modelName,"EnablePacing","off")
out=sim(modelName);

%% Puedes graficar resultados
logsout=out.logsout;
helperTLNWithV2XResults(logsout)

%% Otro parámetro importante en un enlace vehicular inalámbrico, como veremos más adelante
% en el curso, es el Shadow Fading, que provoca fluctuaciones en el rango de cobertura respecto 
% a su valor nominal, afectando ocasionalmente la calidad de la señal recibida. 
% Ejecuta el siguiente escenario, donde se evidencian los efectos de la comunicación 
% bajo estas condiciones. Ejecuta el código de grafica anterior y observa
% la cantidad de mensajes V2V recibidos.

setup_01(ScenarioFcnName="scenario_02", Range=20);
modelName = 'MODEL_PV';
set_param(modelName,"EnablePacing","off")
out=sim(modelName);

%% Puedes graficar resultados
logsout=out.logsout;
helperTLNWithV2XResults(logsout)
SF_std=6;

%% Por último, trataremos de generar una trayectoria que guíe a nuestro vehículo hacia 
% el área de parqueo. Para ello, puedes apoyarte en la documentación sobre cómo generar 
% trayectorias de un actor en MATLAB y establecer sus velocidades, disponible en 
% [matlab.com](https://www.mathworks.com/help/driving/ug/create-actor-and-vehicle-trajectories.html).
% Además, podemos crear el escenario que se muestra a continuación y abrirlo en el diseñador de
% escenarios. Desde allí, es posible generar waypoints y establecer las velocidades del vehículo,
% exportando luego el código para obtener estos parámetros.

% Realiza varias pruebas, ajustando la trayectoria y las velocidades, y asegúrate de que el
% vehículo entre al parqueo con una velocidad terminal de 2 m/s.

setup_01(ScenarioFcnName="scenario_03", Range=20);
drivingScenarioDesigner(scenario)   % el scenario designer no muestra parqueos 
% solo garatiza una trayectoria hasta que el vehículo este dentro
% culminando en la posición -57.5 en el eje y es suficiente
%% Una vez que hayas exportado el escenario modificado a código, podrás visualizar la trayectoria
% y las velocidades que generaste. Copia esos valores en las posiciones correspondientes del 
% escenario y ejecuta el modelo. Repite este proceso ajustando los waypoints y las velocidades 
% hasta que logres una trayectoria y velocidades satisfactorias, asegurando que el vehículo 
% entre al parqueo correctamente y con la velocidad terminal deseada de 2 m/s.

% copia los nuevo waypoints aquí y justo debajo las velocidades
matlab.desktop.editor.openAndGoToLine(which('scenario_03.m'), 88); 

%% Ejecutar y guarda la trayectoria y velocidades finales para proximas asignaciones.

modelName = 'MODEL_PV';
set_param(modelName,"EnablePacing","off")
out=sim(modelName);

%% Al finalizar la actividad regresa la habilitacion de los mensajes del MPC de nuevo.
mpcverbosity("on");