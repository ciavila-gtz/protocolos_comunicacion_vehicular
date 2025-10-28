clear
% Load data
data = load("G:\My Drive\Colab Notebooks\MNA\MR4011 - Protocolos de Comunicación Vehicular\Actividad 1\ACT1\measurementV2I.mat")

% Access the arrays from the loaded structure
%frequency = data.freq_Hz
time = data.time_ms
rx_pow = data.RX_pow

% 1 Maximum instantaneous power received
% Define the distance as v = d / t, d = v * t
v = 8.33                % constant speed of 8.33 m/s
time_s = time / 1000    % Convert from ms to s
distance_m = time_s * v % Calculate distance in m

% Extract the maximum power for each time instance (dBm)
Pr_max = max(rx_pow, [], 2);

% Extract the max Power across the instanteanous power vector
[max_power, idx_maxPr] = max(Pr_max);      % global maximum and index
max_distance = distance_m(idx_maxPr);      % distance at which it occurs

figure;
plot(distance_m, Pr_max, '-o','LineWidth',1.2,'MarkerSize',4);
hold on;

% Add the maximum point to the same plot
plot(max_distance, max_power, 'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 10); % red pentagon marker
text(max_distance, max_power + 2, sprintf('Max: %.2f dBm at %.2f m', max_power, max_distance), ...
    'Color', 'r', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

xlabel('Distance traveled (m)');
ylabel('Received power (dBm)');
title('Instantaneous received power vs distance');
grid on;

% 2 Path Loss
TX_POW = 57.0;                  % 57 dbm
v = 30000 / (60*60);            % 30,000 m / (60 min / hr)(60 sec / min) = 8.33 m/s
perpendicular_dist_m = 13;      % Perpendicular distance from Rx to Vehicle in meters
Pr_max = max(rx_pow, [], 2);    % Get Maximum Power across the time
time_s = time / 1000;   % Convert from ms to s
distance_m = time_s * v;

% Find the index with the maximum power (and max Rx power)
[max_power, idx_maxPr] = max(Pr_max);

% Calculate the distance from 1 to the idx the maximum power
distance_segment = distance_m(1:idx_maxPr);
% Get the radial distance as
% sqtr((X0 - Xmax_pow)^2 + 13^2)
radial_distance = sqrt((distance_segment - distance_m(idx_maxPr)).^2 + perpendicular_dist_m^2);

% Extract the Power from 1 to the idx with maximum poer
Pr_segment = Pr_max(1:idx_maxPr);

% === Calcular Path Loss ===
PathLoss = TX_POW - Pr_segment;

[min_r, idx_min_r] = min(radial_distance);  % Get the smallest radial distance
Pr_at_min_r = Pr_segment(idx_min_r);        % Get the power at the smallest radial distance

figure;
plot(radial_distance, PathLoss, 'LineWidth', 1.5);
hold on;
plot(min_r, TX_POW - Pr_at_min_r, 'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 10); % red pentagon marker
text(min_r + 1, TX_POW - Pr_at_min_r, ...
     sprintf('Min dist = %.2f m\nP_r = %.2f dBm', min_r, TX_POW - Pr_at_min_r), ...
     'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold');

xlabel('Radial Distance (m)');
ylabel('Path Loss (dB)');
title('Path Loss vs Distance (first segment up to perpendicular position)');
grid on;

% Close-In Model
f = 28e9; % Frequency of the carrier
c = 3e8;  % velocidad de la luz (m/s)
FSPL_1m = 20*log10(4*pi*f/c);  % dB

% Get radial distance and Path Loss vectors with valid ranges to inject
% into the log10
d = radial_distance(:);
PL = PathLoss(:);
valid = isfinite(d) & isfinite(PL) & (d>0);  % descartar d<=0 por log10
d = d(valid);
PL = PL(valid);

% Define X and Y
x = 10*log10(d);              % 10 log10(d_i)
y = PL - FSPL_1m;             % y_i = PL_i - FSPL(f,1m)

% Estimator without the interceptor
n_hat = sum(x .* y) / sum(x.^2);

% Residuales y sigma SF
residuals = y - n_hat * x;
N = length(residuals);
sigma_SF = sqrt(sum(residuals.^2) / (N - 1));

% R^2 for regression (no interceptor)
SS_res = sum(residuals.^2);
SS_tot = sum(y.^2);
R2_no_intercept = 1 - SS_res / SS_tot;

% Alternative regression with interceptor (comparison purpose)
p = polyfit(x, y, 1);  % p(1) = slope (n_with_intercept), p(2)=intercept a
n_with_intercept = p(1);
a_est = p(2);
res_intercept = y - (n_with_intercept * x + a_est);
sigma_SF_intercept = sqrt(sum(res_intercept.^2) / (N - 2)); % DOF N-2

% Print results
fprintf('FSPL(1m) = %.3f dB\n', FSPL_1m);
fprintf('Estimated PLE (n) [CI anchor, no intercept] = %.4f\n', n_hat);
fprintf('Estimated sigma_SF = %.3f dB (N = %d)\n', sigma_SF, N);
fprintf('R^2 (no-intercept) = %.4f\n\n', R2_no_intercept);

fprintf('Comparison -- regression with intercept:\n');
fprintf('PLE (slope) = %.4f, intercept a = %.4f dB\n', n_with_intercept, a_est);
fprintf('sigma_SF (with intercept, dof N-2) = %.4f dB\n', sigma_SF_intercept);

% Plots
figure;
subplot(2,1,1);
scatter(x, y, 30, 'filled'); hold on;
xx = linspace(min(x), max(x), 100);
plot(xx, n_hat*xx, 'r-', 'LineWidth', 1.8); % CI no-intercept fit
plot(xx, n_with_intercept*xx + a_est, 'g--', 'LineWidth', 1.2); % with intercept
legend('Datos (y vs x)','Fit CI (no intercept)','Fit con intercepto','Location','best');
xlabel('10 log_{10}(d)'); ylabel('PL - FSPL(1m) (dB)');
title('Ajuste del modelo CI: y = 10 n log10(d)');

subplot(2,1,2);
histogram(residuals, 20);
xlabel('Residuales r_i (dB)'); ylabel('Frecuencia');
title(sprintf('Residuales (sigma = %.3f dB)', sigma_SF));
grid on;

% Shadow fading
% --- Get mean and standard deviation ---
mu_res = mean(residuals);
sigma_res = std(residuals);

fprintf('Media de residuales (μ) = %.3f dB\n', mu_res);
fprintf('Desviación estándar (σ_SF) = %.3f dB\n', sigma_res);

% --- Plot histogram and gaussian curve 
figure('Name','Shadow Fading Histogram','NumberTitle','off');
histogram(residuals, 20, 'Normalization','pdf','FaceAlpha',0.6);
hold on;

% Adjust and plot gaussian curve
x_fit = linspace(min(residuals), max(residuals), 200);
pdf_fit = normpdf(x_fit, mu_res, sigma_res);
plot(x_fit, pdf_fit, 'r-', 'LineWidth', 1.8);
xlabel('Residuals (dB)');
ylabel('Probability Density');
title('Shadow Fading (Histogram + Gaussian Fit)');
legend('Datos experimentales','Ajuste Gaussiano','Location','best');
grid on;

% --- Validate with QQ-Plot ---
figure('Name','QQ-plot Residuales','NumberTitle','off');
qqplot(residuals);
title('QQ-Plot de Residuales vs Distribución Normal');
grid on;


% Viable range of communications
Pt = 20;    % dBm
FSPL_1m;    % dB
n = n_hat;  % PLE
sigma_SF;   % dB

fprintf('\n\n------- Rango Viable de Comunicacion -------\n\n')
fprintf('Potencia de Transmision (Pt) = %.3f dBm\nFSPL(1m) = %.3f dB\n', Pt, FSPL_1m);
fprintf('PLE (n) = %.3f\nSigma SF (σ_SF) = %.3f dB\n', n_hat, sigma_SF);

% Distance vector from 1m to 1km 
d = linspace(1,1000,2000);   % From 1 m to 1000 m using 2000 samples

% Average received power (CI model)
Pr_mean = Pt - (FSPL_1m + 10 * n * log10(d));

% Bands +/- sigma
Pr_upper = Pr_mean + sigma_SF;
Pr_lower = Pr_mean - sigma_SF;

% Values of interest
d_points = [1, 10, 100, 200, 1000];
Pr_points = Pt - (FSPL_1m + 10 * n * log10(d_points));
Pr_points_upper = Pr_points + sigma_SF;
Pr_points_lower = Pr_points - sigma_SF;

% Show table in commandl ine
fprintf(' d (m)   Pr_mean (dBm)   Pr+sigma (dBm)   Pr-sigma (dBm)\n');
for k = 1:length(d_points)
    fprintf('%5d   %10.3f       %10.3f       %10.3f\n', d_points(k), ...
        Pr_points(k), Pr_points_upper(k), Pr_points_lower(k));
end

% Get Plot
figure('Name','Pr(d) - Modelo CI');
plot(d, Pr_mean, 'b-', 'LineWidth', 1.8); hold on;
plot(d, Pr_upper, 'r--', 'LineWidth', 1);
plot(d, Pr_lower, 'r--', 'LineWidth', 1);
% Get the value at 200 m
xline(200, 'k:', 'LineWidth', 1.4, 'Label', '200 m', 'LabelHorizontalAlignment','left');
% Get Received Power at 200m Pr(200)
text(210, Pt - (FSPL_1m + 10*n*log10(200)), sprintf('Pr(200)= %.3f dBm', Pt - (FSPL_1m + 10*n*log10(200))),'FontWeight', 'bold');
xlabel('Distancia d (m)');
ylabel('Potencia recibida P_r (dBm)');
title('P_r(d) (media) y bandas \pm\sigma_{SF} (modelo CI)');
legend('P_r media','P_r + \sigma','P_r - \sigma','Location','best');
grid on;
set(gca,'FontSize',11);

% ------ Noise level ------------------
Noise_dbm = -105.332 % dBm
distance_at_noise = 10^((Pt - FSPL_1m - Noise_dbm) / (10 * n));
fprintf('distance_at_noise = %.3f', distance_at_noise)

% Get Plot (combining both P(200m) and distance at Noise)
figure('Name','Pr(d) - Modelo CI');
plot(d, Pr_mean, 'b-', 'LineWidth', 1.8); hold on;
plot(d, Pr_upper, 'r--', 'LineWidth', 1);
plot(d, Pr_lower, 'r--', 'LineWidth', 1);
% Get the value at 200 m
xline(200, 'k:', 'LineWidth', 1.4, 'Label', '200 m', 'LabelHorizontalAlignment','left');
% Get Received Power at 200m Pr(200)
text(210, Pt - (FSPL_1m + 10*n*log10(200)), sprintf('Pr(200)= %.3f dBm', Pt - (FSPL_1m + 10*n*log10(200))),'FontWeight', 'bold');
% Get Distance below the Noise level
xline(distance_at_noise, 'k:', 'LineWidth', 1.4, 'Label', 'Distance below Noise', 'LabelHorizontalAlignment','left');
text(distance_at_noise + 10, -115, sprintf('d(noise)= %.3f m', distance_at_noise),'FontWeight', 'bold');
yline(Noise_dbm, 'k--', 'LineWidth', 1.4, 'Label', 'Noise value', 'LabelVerticalAlignment','top');
text(10, Noise_dbm - 1, sprintf('Pr(noise)= %.3f m', Noise_dbm),'FontWeight', 'bold');
xlabel('Distancia d (m)');
ylabel('Potencia recibida P_r (dBm)');
title('P_r(d) (media) y bandas \pm\sigma_{SF} (modelo CI)');
legend('P_r media','P_r + \sigma','P_r - \sigma','Location','best');
grid on;
set(gca,'FontSize',11);

% Plot for distance below the noise only
%figure('Name','Pr(d) - Modelo CI');
%plot(d, Pr_mean, 'b-', 'LineWidth', 1.8); hold on;
% Get Distance below the Noise level
%xline(distance_at_noise, 'k:', 'LineWidth', 1.4, 'Label', 'Distance below Noise', 'LabelHorizontalAlignment','left');
%text(distance_at_noise + 10, -115, sprintf('d(noise)= %.3f m', distance_at_noise),'FontWeight', 'bold');
%yline(Noise_dbm, 'k--', 'LineWidth', 1.4, 'Label', 'Noise value', 'LabelVerticalAlignment','top');
%text(10, Noise_dbm - 1, sprintf('Pr(noise)= %.3f m', Noise_dbm),'FontWeight', 'bold');
%xlabel('Distancia d (m)');
%ylabel('Potencia recibida P_r (dBm)');
%title('P_r(d) (media) (modelo CI)');
%legend('P_r media','Location','best');
%grid on;
%set(gca,'FontSize',11);

