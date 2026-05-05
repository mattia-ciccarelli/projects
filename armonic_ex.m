%% MULTIPLE ROWS SCRIPT GIUSTO DEFINITIVO

clear; clc;
disp('Select the file .vtk for the mesh reading');
[file, path] = uigetfile('*.vtk', 'Base Mesh');
Basefile = fullfile(path, file);
load('param_o3_4340.mat', 'mappings', 'ndof');
[nPages, nNodes, nComponents] = size(mappings);
TestVTK = fileread(Basefile); % To read all as a unique string
% Finding the point where the velocity component are contained
idxPointData = strfind(TestVTK, 'POINT_DATA');
% Taking the initial geometry
Geometry = TestVTK(1:idxPointData(1)-1);

% 4. Esportazione
% Raggruppa tra parentesi quadre le pagine da sommare dentro le parentesi graffe.
% (Modifica i numeri 6 e 7 in base alle righe reali di Avector che vuoi sommare alla 1)
extractPages = {[5], [4], [1]}; 
names = {'Zero_harmonic', 'Second_harmonic', 'First_harmonic'};

for i = 1:length(extractPages)
    pages = extractPages{i}; % Prende il gruppo di pagine (nota le parentesi graffe)
    name = [names{i}, '.vtk'];
    
    fprintf('File creation: %s...\n', name);
    
    % Squeeze e somma lungo la prima dimensione (la dimensione delle pagine)
    data = squeeze(sum(mappings(pages, :, :), 1));
    
    %writing phase
    fid = fopen(name, 'w');
    fprintf(fid, '%s', Geometry);
    
    % Substitution of the velocity values
    fprintf(fid, 'POINT_DATA %d\n', nNodes);
    fprintf(fid, 'VECTORS Velocity float\n');
    
    for n = 1:nNodes
        % Only the real part for the rapresentation in paraview
        u = real(data(n, 1));
        v = real(data(n, 2));
        fprintf(fid, '%e %e 0.0\n', u, v); %
    end
    
 %CALCULATION OF THE MEAN FLOW????????????????
    fclose(fid);
end


%% MULTIPLE ROWS SCRIPT GIUSTO DEFINITIVO CON SALVATAGGIO IN CARTELLA

clear; clc;
disp('Select the file .vtk for the mesh reading');
[file, path] = uigetfile('*.vtk', 'Base Mesh');
Basefile = fullfile(path, file);

load('param.mat', 'mappings', 'ndof');
[nPages, nNodes, nComponents] = size(mappings);

TestVTK = fileread(Basefile); % To read all as a unique string
% Finding the point where the velocity component are contained
idxPointData = strfind(TestVTK, 'POINT_DATA');
% Taking the initial geometry
Geometry = TestVTK(1:idxPointData(1)-1);

% --- CREAZIONE CARTELLA DI OUTPUT ---
outputFolder = 'Harmonics';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
    fprintf('Cartella "%s" creata con successo.\n', outputFolder);
end
% ------------------------------------

% 4. Esportazione
% Raggruppa tra parentesi quadre le pagine da sommare dentro le parentesi graffe.
% (Modifica i numeri 6 e 7 in base alle righe reali di Avector che vuoi sommare alla 1)
extractPages = {[5,14], [4,12], [1,6,15]}; 
names = {'Zero_harmonic', 'Second_harmonic', 'First_harmonic'};

for i = 1:length(extractPages)
    pages = extractPages{i}; % Prende il gruppo di pagine (nota le parentesi graffe)
    name = [names{i}, '.vtk'];
    
    % Unisce il nome della cartella al nome del file
    outputPath = fullfile(outputFolder, name); 
    
    fprintf('File creation: %s...\n', outputPath);
    
    % Squeeze e somma lungo la prima dimensione (la dimensione delle pagine)
    data = squeeze(sum(mappings(pages, :, :), 1));
    
    %writing phase
    fid = fopen(outputPath, 'w');
    fprintf(fid, '%s', Geometry);
    
    % Substitution of the velocity values
    fprintf(fid, 'POINT_DATA %d\n', nNodes);
    fprintf(fid, 'VECTORS Velocity float\n');
    
    for n = 1:nNodes
        % Only the real part for the rapresentation in paraview
        u = real(data(n, 1));
        v = real(data(n, 2));
        fprintf(fid, '%e %e 0.0\n', u, v); %
    end
    
 %CALCULATION OF THE MEAN FLOW????????????????
    fclose(fid);
end

disp('Esportazione completata! Controlla la cartella Harmonics.');


%%
% SINGLE ROWS ARMONIC REYNOLDS CRITICAL
% SOLO LA ZEROTH HARMONIC NON COMBACIA CON QUELLE DEFINITIVE
clear; clc;

disp('Select the file .vtk for the mesh reading');
[file, path] = uigetfile('*.vtk', 'Base Mesh');
Basefile = fullfile(path, file);

load('param.mat', 'mappings', 'ndof');
[nPages, nNodes, nComponents] = size(mappings);

TestVTK = fileread(Basefile); % To read all as a unique string

% Finding the point where the velocity component are contained
idxPointData = strfind(TestVTK, 'POINT_DATA');

% Taking the initial geometry
Geometry = TestVTK(1:idxPointData(1)-1);

% 4. Esportazione
extractPages = [5,4,1]; %HARMONIC EXTRACTIONS
names = {'Zero_harmonicr', 'Second_harmonicr', 'First_harmonicr'};

for i = 1:length(extractPages)
    page = extractPages(i);
    name = [names{i}, '.vtk']
    
    fprintf('File creation: %s...\n', name);
    data = squeeze(mappings(page, :, :));
    
    %writing phase
    fid = fopen(name, 'w');

    fprintf(fid, '%s', Geometry);
    
    % Substitution of the velocity values
    fprintf(fid, 'POINT_DATA %d\n', nNodes);
    fprintf(fid, 'VECTORS Velocity float\n');
    
    for n = 1:nNodes
        % Only the real part for the rapresentation in paraview
        u = real(data(n, 1));
        v = real(data(n, 2));
        fprintf(fid, '%e %e 0.0\n', u, v); %
    end
    
 %CALCULATION OF THE MEAN FLOW????????????????
    fclose(fid);
end




%% AMPLITUDE*HARMONIC  RISPETTO LE DEFINITIVE CAMBIA SOLO L'AMPLITUDE MA LA FORMA SPAZIALE è LA STESSA

clear; clc; close all;

% --- 1. CARICAMENTO DATI ---
disp('Seleziona il file .vtk per leggere la mesh di base');
[file_vtk, path_vtk] = uigetfile('*.vtk', 'Base Mesh');
if isequal(file_vtk, 0), return; end
Basefile = fullfile(path_vtk, file_vtk);

disp('Seleziona il file param.mat contenente mappings e fdynpol');
[file_mat, path_mat] = uigetfile('*.mat', 'File Parametri');
if isequal(file_mat, 0), return; end
Paramfile = fullfile(path_mat, file_mat);

% Carica dati da Julia
load(Paramfile, 'mappings', 'fdynpol', 'u0');
[nPages, nNodes, nComponents] = size(mappings);

% Lettura Geometria VTK
TestVTK = fileread(Basefile);
idxPointData = strfind(TestVTK, 'POINT_DATA');
Geometry = TestVTK(1:idxPointData(1)-1);

% --- 2. ESTRAZIONE PARAMETRI DPIM E CALCOLO DINAMICO ---
% Suggerisce il Reynolds base dal nome del file (es. param_4500.mat -> 4500)
numb = regexp(file_mat, '\d+', 'match');
if ~isempty(numb), Re_base = str2double(numb{1}); else, Re_base = 4500; end

sigma_0  = fdynpol(1,1);          
lambda_r = fdynpol(6,1);          
mu_r     = -fdynpol(11,1); 

% Correzione Fisica dei segni per i bug del solutore eigs
if lambda_r > 0, lambda_r = -lambda_r; end
if mu_r < 0, mu_r = -mu_r; end

% Richiesta all'utente: A quale Reynolds vuoi vedere il fluido?
prompt = {sprintf('Re di espansione base = %g\nInserisci il Reynolds a cui vuoi visualizzare la scia:', Re_base)};
answer = inputdlg(prompt, 'Reynolds Target', 1, {'4800'});
if isempty(answer), return; end
Re_target = str2double(answer{1});

% Calcolo ε e ampiezza astratta r(Re) tramite Stuart-Landau
epsilon = (100 / Re_target) - (100 / Re_base);
arg = (sigma_0 + lambda_r * epsilon) / mu_r;

if arg <= 0
    warning('A questo numero di Reynolds (Re = %g) il flusso è stabile (r=0). Non ci sono vortici da esportare!', Re_target);
    return;
end

r = sqrt(arg);
fprintf('\n--- CALCOLO FISICO A Re = %g ---\n', Re_target);
fprintf('Distanza ε = %g\n', epsilon);
fprintf('Ampiezza astratta ciclo limite (r) = %g\n', r);

% --- 3. RICOSTRUZIONE FISICA DELLE ARMONICHE ---
% Inizializziamo le matrici dei risultati
U_H0 = zeros(nNodes, nComponents);
U_H1 = zeros(nNodes, nComponents);
U_H2 = zeros(nNodes, nComponents);

% ARMONICA 1 (La Fondamentale) -> Scala con r^1
% Ordini di Taylor: Riga 1 (ε^0), Riga 6 (ε^1), Riga 15 (ε^2)
Forma_H1 = squeeze(mappings(1,:,:)) + ...
           squeeze(mappings(6,:,:)) * epsilon + ...
           squeeze(mappings(15,:,:)) * (epsilon^2);
U_H1 = Forma_H1 * (r^1);

% ARMONICA 0 (La Correzione Media) -> Scala con r^2
% Ordini di Taylor: Riga 5 (ε^0), Riga 14 (ε^1)
Forma_H0 = squeeze(mappings(5,:,:)) + ...
           squeeze(mappings(14,:,:)) * epsilon;
U_H0 = Forma_H0 * (r^2);

% ARMONICA 2 (La Seconda Armonica) -> Scala con r^2
% Ordini di Taylor: Riga 4 (ε^0), Riga 12 (ε^1)
Forma_H2 = squeeze(mappings(4,:,:)) + ...
           squeeze(mappings(12,:,:)) * epsilon;
U_H2 = Forma_H2 * (r^2);

% --- 4. ESPORTAZIONE FILE VTK ---
armoniche_dati = {U_H0, U_H1, U_H2};
nomi_file = {sprintf('Physical_H0_Re%g.vtk', Re_target), ...
             sprintf('Physical_H1_Re%g.vtk', Re_target), ...
             sprintf('Physical_H2_Re%g.vtk', Re_target)};

for i = 1:length(nomi_file)
    name = nomi_file{i};
    data = armoniche_dati{i};
    
    fprintf('Salvataggio di %s...\n', name);
    fid = fopen(name, 'w');
    fprintf(fid, '%s', Geometry);
    fprintf(fid, 'POINT_DATA %d\n', nNodes);
    fprintf(fid, 'VECTORS Velocity float\n');
    
    for n = 1:nNodes
        u = real(data(n, 1));
        v = real(data(n, 2));
        fprintf(fid, '%e %e 0.0\n', u, v);
    end
    fclose(fid);
end

% EXTRA: ESPORTA DIRETTAMENTE IL MEAN FLOW TOTALE (Base + Correzione)
if exist('u0', 'var')
    fprintf('Salvataggio del Mean Flow Reale...\n');
    name_mean = sprintf('Total_MeanFlow_Re%g.vtk', Re_target);
    fid = fopen(name_mean, 'w');
    fprintf(fid, '%s', Geometry);
    fprintf(fid, 'POINT_DATA %d\n', nNodes);
    fprintf(fid, 'VECTORS Velocity float\n');
    for n = 1:nNodes
        % Somma flusso base (u0) e correzione media fisica (U_H0)
        u_mean = real(U_H0(n, 1)) + u0(n, 1);
        v_mean = real(U_H0(n, 2)) + u0(n, 2);
        fprintf(fid, '%e %e 0.0\n', u_mean, v_mean);
    end
    fclose(fid);
end

disp('!!! Esportazione completata con successo !!!');

%% RICOSTRUZIONE FISICA COMPLETA DELLA MAPPA NON-LINEARE (Formula 13a)
% STESSE AMPLITUDE DELLA VERSIONE PRECEDENTE 
clear; clc; close all;

disp('Seleziona il file .vtk per leggere la mesh di base');
[file_vtk, path_vtk] = uigetfile('*.vtk', 'Base Mesh');
if isequal(file_vtk, 0), return; end
Basefile = fullfile(path_vtk, file_vtk);

disp('Seleziona il file param.mat contenente mappings e fdynpol');
[file_mat, path_mat] = uigetfile('*.mat', 'File Parametri');
if isequal(file_mat, 0), return; end
Paramfile = fullfile(path_mat, file_mat);

load(Paramfile, 'mappings', 'fdynpol', 'u0');
[nPages, nNodes, nComponents] = size(mappings);

TestVTK = fileread(Basefile);
idxPointData = strfind(TestVTK, 'POINT_DATA');
Geometry = TestVTK(1:idxPointData(1)-1);

% Estraggo il Reynolds base
numb = regexp(file_mat, '\d+', 'match');
if ~isempty(numb), Re_base = str2double(numb{1}); else, Re_base = 4500; end

sigma_0  = fdynpol(1,1);          
lambda_r = fdynpol(6,1);          
mu_r     = -fdynpol(11,1); 

if lambda_r > 0, lambda_r = -lambda_r; end
if mu_r < 0, mu_r = -mu_r; end

prompt = {sprintf('Re base = %g\nInserisci il Reynolds per la ricostruzione fisica:', Re_base)};
answer = inputdlg(prompt, 'Reynolds Target', 1, {'4800'});
if isempty(answer), return; end
Re_target = str2double(answer{1});

% =========================================================================
% 1. CALCOLO DELLE VARIABILI DINAMICHE (Il vettore Z)
% =========================================================================
epsilon = (100 / Re_target) - (100 / Re_base);
arg = (sigma_0 + lambda_r * epsilon) / mu_r;

if arg <= 0
    error('Flusso stabile a questo Reynolds. r = 0.');
end
r = sqrt(arg);

fprintf('\n--- CALCOLO MONOMI (Z) A Re = %g ---\n', Re_target);
fprintf('Epsilon = %g\n', epsilon);
fprintf('Ampiezza r = %g\n', r);

% =========================================================================
% 2. APPLICAZIONE FORMULA (13a): Somma di (Coefficiente W * Monomio Z)
% =========================================================================

% -- ARMONICA 1 (Fondamentale) --
z_1  = r;
z_6  = r * epsilon;
z_15 = r * (epsilon^2);
Mappa_H1 = squeeze(mappings(1,:,:)) * z_1 + ...
           squeeze(mappings(6,:,:)) * z_6 + ...
           squeeze(mappings(15,:,:)) * z_15;

% -- ARMONICA 0 (Distorsione Media) --
z_5  = r^2;
z_14 = (r^2) * epsilon;
Mappa_H0 = squeeze(mappings(5,:,:)) * z_5 + ...
           squeeze(mappings(14,:,:)) * z_14;

% -- ARMONICA 2 --
z_4  = r^2;
z_12 = (r^2) * epsilon;
Mappa_H2 = squeeze(mappings(4,:,:)) * z_4 + ...
           squeeze(mappings(12,:,:)) * z_12;

% -- SPOSTAMENTO FLUSSO BASE (Lineare con epsilon) --
z_2 = epsilon;
z_8 = epsilon^2;
Mappa_BaseShift = squeeze(mappings(2,:,:)) * z_2 + ...
                  squeeze(mappings(8,:,:)) * z_8;

% =========================================================================
% 3. ESPORTAZIONE
% =========================================================================
armoniche_dati = {Mappa_H0, Mappa_H1, Mappa_H2};
nomi_file = {sprintf('True_Physical_H0_Re%g.vtk', Re_target), ...
             sprintf('True_Physical_H1_Re%g.vtk', Re_target), ...
             sprintf('True_Physical_H2_Re%g.vtk', Re_target)};

for i = 1:length(nomi_file)
    name = nomi_file{i};
    data = armoniche_dati{i};
    fid = fopen(name, 'w');
    fprintf(fid, '%s', Geometry);
    fprintf(fid, 'POINT_DATA %d\n', nNodes);
    fprintf(fid, 'VECTORS Velocity float\n');
    for n = 1:nNodes
        u = real(data(n, 1));
        v = real(data(n, 2));
        fprintf(fid, '%e %e 0.0\n', u, v);
    end
    fclose(fid);
end

% FLUSSO MEDIO TOTALE REALE (u0 + Shift Epsilon + H0)
fprintf('Salvataggio del Mean Flow Totale...\n');
fid = fopen(sprintf('True_Total_MeanFlow_Re%g.vtk', Re_target), 'w');
fprintf(fid, '%s', Geometry);
fprintf(fid, 'POINT_DATA %d\n', nNodes);
fprintf(fid, 'VECTORS Velocity float\n');
for n = 1:nNodes
    u_mean = u0(n, 1) + real(Mappa_BaseShift(n,1)) + real(Mappa_H0(n, 1));
    v_mean = u0(n, 2) + real(Mappa_BaseShift(n,2)) + real(Mappa_H0(n, 2));
    fprintf(fid, '%e %e 0.0\n', u_mean, v_mean);
end
fclose(fid);

disp('Esportazione completata. Ora hai applicato rigorosamente la formula (13a)!');


%% REPLICA FIGURE SIPP & LEBEDEV (Solo Modi Spaziali Puri a Re_c) AMPLITUDE LEGGERMENTE DIVERSE DALLE DEFINITIVE
clear; clc; close all;

disp('Seleziona il file .vtk per leggere la mesh della cavità');
[file_vtk, path_vtk] = uigetfile('*.vtk', 'Base Mesh');
if isequal(file_vtk, 0), return; end
Basefile = fullfile(path_vtk, file_vtk);

disp('Seleziona il file param.mat (es. param_4140.mat) contenente mappings');
[file_mat, path_mat] = uigetfile('*.mat', 'File Parametri');
if isequal(file_mat, 0), return; end
Paramfile = fullfile(path_mat, file_mat);

load(Paramfile, 'mappings');
[nPages, nNodes, nComponents] = size(mappings);

TestVTK = fileread(Basefile);
idxPointData = strfind(TestVTK, 'POINT_DATA');
Geometry = TestVTK(1:idxPointData(1)-1);

% =========================================================================
% ESTRAZIONE DEI MODI PURI (Niente r, niente epsilon)
% =========================================================================

% FIGURA 8(c) - First harmonic Re(v_1^A)
% Nel tuo file mappings, questa è tipicamente la Riga 1
Modo_H1 = squeeze(mappings(1,:,:));

% FIGURA 8(e) - Zeroth (mean flow) harmonic u_2^{|A|^2}
% Nel tuo file mappings, questa è tipicamente la Riga 5
Modo_H0 = squeeze(mappings(5,:,:));

% FIGURA 8(f) - Second harmonic Re(u_2^{A^2})
% Nel tuo file mappings, questa è tipicamente la Riga 4
Modo_H2 = squeeze(mappings(4,:,:));

% =========================================================================
% 3. ESPORTAZIONE
% =========================================================================
armoniche_dati = {Modo_H1, Modo_H0, Modo_H2};
nomi_file = {'Sipp_Fig8c_H1.vtk', 'Sipp_Fig8e_H0.vtk', 'Sipp_Fig8f_H2.vtk'};

for i = 1:length(nomi_file)
    name = nomi_file{i};
    data = armoniche_dati{i};
    fid = fopen(name, 'w');
    fprintf(fid, '%s', Geometry);
    fprintf(fid, 'POINT_DATA %d\n', nNodes);
    fprintf(fid, 'VECTORS Velocity float\n');
    for n = 1:nNodes
        u = real(data(n, 1));
        v = real(data(n, 2));
        fprintf(fid, '%e %e 0.0\n', u, v);
    end
    fclose(fid);
end

disp('Esportazione completata! Ora apri i file su ParaView.');