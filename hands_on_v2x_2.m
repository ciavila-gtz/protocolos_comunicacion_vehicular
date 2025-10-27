clear
% Load data
data = load("G:\My Drive\Colab Notebooks\MNA\MR4011 - Protocolos de Comunicación Vehicular\Actividad 1\ACT1\measurementV2I.mat")

% Access the arrays from the loaded structure
frequency = data.freq_Hz
time = data.time_ms
rx_pow = data.RX_pow

% 2.1 Power Spectrum
% Choose a specific time index to plot 
timeIndex = 100
% Extract the power for the chosen time index
powerAtTime  = rx_pow(timeIndex, :);
% Plot the reception power against frequency on a given time
plot(frequency, powerAtTime);
xlabel('Frecuencia (Hz)');
ylabel('Potencia recibida');
title(['Potencia recibida en tiempo ' num2str(time(timeIndex)) ' ms (Index = ' num2str(timeIndex) ' )' ]);
grid on;

% 2.2 Carrier Frequency
% Find the index of the maximum power value
[maxPower, maxIndex] = max(powerAtTime);
% Get the frequency corresponding to the maximum power
maxFrequency = frequency(maxIndex);
% Display the result
fprintf('La frecuencia con la mayor potencia es (Portadora): %.2f Hz\nPotencia (portadora): %.2f dBm\n', maxFrequency, maxPower);

% Annotate the plot with the maximum frequency and power
hold on; % Keep the current plot
plot(maxFrequency, maxPower, 'ro'); % Mark the highest point with a red circle
text(maxFrequency, maxPower, sprintf('Portadora: %.2f Hz / Potencia: %.2f', maxFrequency, maxPower), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
hold off; % Release the hold

% 2.3 Noise and SNR
% Number of samples to exclude next to the carrier
excludeRange = 10;
% Generate a vector of masking indexes
maskedIndex = true(size(powerAtTime));
% Mask [excludeRange] before and after the carrier
maskedIndex(max(1, maxIndex-excludeRange):min(end, maxIndex+excludeRange)) = false;
% Calculate mean value from the non-masked values
noiseLevel = mean(powerAtTime(maskedIndex));

% Calcular SNR
SNR = maxPower - noiseLevel;

% Mostrar resultados
disp(['Potencia de la señal (pico): ' num2str(maxPower) 'dBm']);
disp(['Nivel promedio de ruido: ' num2str(noiseLevel) 'dBm']);
disp(['Relación Señal-Ruido (SNR): ' num2str(SNR) ' dB']);

% 2.4 Spectrum of frequencies in time

% Get carrier frequency on each given time
[~, maxIdx] = max(rx_pow, [], 2);       % Index of max power per row (time)
carrierTrajectory = frequency(maxIdx);  % Corresponding carrier frequency

% Plot time in X and time in Y
figure;
imagesc(frequency, time, rx_pow);
axis xy;
xlabel('Tiempo (ms)');
ylabel('Frecuencia (Hz)');
title('Potencia recibida con Frecuencia en el eje Y y Tiempo en el eje X');
colorbar;
colormap jet;
hold on;

% Plot in white the carrier frequency across time
plot(carrierTrajectory, time,'w', 'LineWidth', 2);
legend('Frecuencia portadora');