% =========================================================================
% CALCOLO ANALITICO DELLA TURBULENT KINETIC ENERGY (TKE) DAL ROM
% =========================================================================
clear; clc;

load('param_o7_4500.mat', 'mappings_r', 'Avector');
% Load matcont parameterd
load('Uchannel1.mat', 'xlcc', 'ncol', 'ntst'); % Usa il tuo out_name!


LU = 1;
coeffnorm = 100;
nu0 = coeffnorm * LU / 4500; % Re_0 = 4500
order_trunc = [7]; 

[nPages, nNodes, nComponents] = size(mappings_r);
nred = size(Avector, 2) - 1; % Number of variables

% Filtering the term based on the order used
condition1 = sum(Avector(:, 1:nred+1), 2) <= order_trunc(1);
term2use = condition1;

% Orbits inside xlcc
po_all = xlcc;   %2D MATRIX COLUMN=RE, ROWS=LPO,W,NU
npo = size(po_all, 2); % Number of Re, number of points of the curve
lpo = size(po_all, 1);
lpo = (lpo - 2) / nred; % Temporal step for each orbit lpo= a1(1)...a1(n),a2(1)...a2(n), w, nu 

% Vettori per salvare i risultati finali
Re_list = zeros(1, npo);
TKE_mean = zeros(1, npo);

fprintf('Calcolo della TKE in corso per %d valori di Reynolds...\n', npo);

% 3. Ciclo su tutti i numeri di Reynolds trovati dalla continuazione
for i = 1:npo
    nu = po_all(end, i);
    Re_list(i) = coeffnorm * LU / (nu0 + nu);
    
    vars = zeros(nred+1, 1);
    vars(nred+1) = nu;
    
    % Dimension: [Step_T x Nodes x 3(U,V,P)]
    U_fluct_time = zeros(lpo, nNodes, nComponents);
    
    % For on the periodor
    for j = 1:lpo
        for k = 1:nred
            vars(k) = po_all(k + (j-1)*nred, i); % Taking the amplitude a1(t) e a2(t)
        end
        
        %monomials
        zprod_all = prod((vars)'.^Avector, 2);
        zprod_all_3D = reshape(zprod_all .* term2use, [nPages, 1, 1]);
        
        % Total flow field
        U_fluct_time(j, :, :) = sum(mappings_r .* zprod_all_3D, 1);
    end
    
    % To take the flactuation it is needed to substitue the mean flow from
    % the total flow field

    U_mean = squeeze(mean(U_fluct_time, 1));  %mean flow on a single period
    
    TKE_time = zeros(1, lpo);
    
    % Spatial integration
    for j = 1:lpo

        u_turb = squeeze(U_fluct_time(j, :, :)) - U_mean;

        TKE_time(j) = 0.5 * sum(u_turb(:, 1).^2 + u_turb(:, 2).^2); 
    end
    
    % Time average 
    TKE_mean(i) = mean(TKE_time);
    
    if mod(i, 50) == 0
        fprintf('   Completato: %d / %d\n', i, npo);
    end
end

% =========================================================================
% 4. PLOT DEL DIAGRAMMA DI BIFORCAZIONE DELLA TKE
% =========================================================================
figure('Name', 'Bifurcation Diagram - TKE', 'Color', 'w');
plot(Re_list, TKE_mean, '-b', 'LineWidth', 2);
grid on;

% Estetica simile al paper
xlabel('$Re$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('$\langle TKE \rangle$', 'Interpreter', 'latex', 'FontSize', 14);
title(sprintf('Turbulent Kinetic Energy (ROM Order %d)', order_trunc(1)), 'FontSize', 12);
xlim([4000,6000]);



%% TKE WITH MASS

% =========================================================================
% CALCOLO ANALITICO DELLA TURBULENT KINETIC ENERGY (TKE) DAL ROM
% =========================================================================
clear; clc;


tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% 2. Aggiunge al radar la cartella MatCont (che si trova due livelli più su)
addpath(genpath('../../MatCont7p6')) 

load('../param2/param_M_o7_5000', 'mappings_r', 'Avector','M');
% Load matcont parameterd
load('Uchannel1.mat', 'xlcc', 'ncol', 'ntst'); % Usa il tuo out_name!


LU = 1;
coeffnorm = 100;
nu0 = coeffnorm * LU / 5000; % Re_0 = 4500
order_trunc = [7]; 

[nPages, nNodes, nComponents] = size(mappings_r);
nred = size(Avector, 2) - 1; % Number of variables

% Filtering the term based on the order used
condition1 = sum(Avector(:, 1:nred+1), 2) <= order_trunc(1);
term2use = condition1;

% Orbits inside xlcc
po_all = xlcc;   %2D MATRIX COLUMN=RE, ROWS=LPO,W,NU
npo = size(po_all, 2); % Number of Re, number of points of the curve
lpo = size(po_all, 1);
lpo = (lpo - 2) / nred; % Temporal step for each orbit lpo= a1(1)...a1(n),a2(1)...a2(n), w, nu 

% Vettori per salvare i risultati finali
Re_list = zeros(1, npo);
TKE_mean = zeros(1, npo);

fprintf('Calcolo della TKE in corso per %d valori di Reynolds...\n', npo);

M_scalar = M(1:nNodes, 1:nNodes);

% 3. Ciclo su tutti i numeri di Reynolds trovati dalla continuazione
for i = 1:npo
    nu = po_all(end, i);
    Re_list(i) = coeffnorm * LU / (nu0 + nu);
    
    vars = zeros(nred+1, 1);
    vars(nred+1) = nu;
    
    % Dimension: [Step_T x Nodes x 3(U,V,P)]
    U_fluct_time = zeros(lpo, nNodes, nComponents);
    
    % For on the periodor
    for j = 1:lpo
        for k = 1:nred
            vars(k) = po_all(k + (j-1)*nred, i); % Taking the amplitude a1(t) e a2(t)
        end
        
        %monomials
        zprod_all = prod((vars)'.^Avector, 2);
        zprod_all_3D = reshape(zprod_all .* term2use, [nPages, 1, 1]);
        
        % Total flow field
        U_fluct_time(j, :, :) = sum(mappings_r .* zprod_all_3D, 1);
    end
    
    % To take the flactuation it is needed to substitue the mean flow from
    % the total flow field

    U_mean = squeeze(mean(U_fluct_time, 1));  %mean flow on a single period
    
    TKE_time = zeros(1, lpo);
    
   
    % Spatial integration CHANGE WITH RESPECT THE UPPER CODE,
    % MULTIPLICATION BY M
    
    for j = 1:lpo
        % Calcolo della fluttuazione (Velocità Totale - Flusso Medio)
        u_turb = squeeze(U_fluct_time(j, :, :)) - U_mean;
        
        % Estrazione dei vettori colonna (21669 x 1)
        u_comp = u_turb(:, 1); 
        v_comp = u_turb(:, 2); 
        
        % Integrale spaziale pesato con la Matrice di Massa
        % TKE = 1/2 * (u^T * M * u + v^T * M * v)
        TKE_time(j) = 0.5 * (u_comp' * M_scalar * u_comp + v_comp' * M_scalar * v_comp); 
    end
    
    % Time average 
    TKE_mean(i) = mean(TKE_time);
    
    if mod(i, 50) == 0
        fprintf('   Completato: %d / %d\n', i, npo);
    end
end

% =========================================================================
% 4. PLOT DEL DIAGRAMMA DI BIFORCAZIONE DELLA TKE
% =========================================================================
figure('Name', 'Bifurcation Diagram - TKE', 'Color', 'w');
plot(Re_list, TKE_mean, '-b', 'LineWidth', 2);
grid on;

% Estetica simile al paper
xlabel('$Re$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('$\langle TKE \rangle$', 'Interpreter', 'latex', 'FontSize', 14);
title(sprintf('Turbulent Kinetic Energy (ROM Order %d)', order_trunc(1)), 'FontSize', 12);
xlim([4000,6000]);