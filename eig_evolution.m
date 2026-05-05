% Leggi il file come testo
fid = fopen('eigenfrequencies.txt', 'r');
data = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

lines = data{1};

% Preallocazione
z = zeros(length(lines),1);

% Conversione stringa -> numero complesso
for k = 1:length(lines)
    % sostituisci 'im' con 'i'
    str = strrep(lines{k}, 'im', 'i');
    
    % converti in numero complesso
    z(k) = str2num(str); %#ok<ST2NM>
end

% Estrai parte reale e immaginaria
x = real(z);
y = imag(z);

% Plot
figure;
plot(x, y, 'o')
xlabel('Re(\lambda)')
ylabel('Im(\lambda)')
title('Eigenvalues')
grid on

%%

clear; clc; close all;

load(['reconstructed_series2.mat']); 

eigv= time_series; 


% 2. Prepara la figura
figure('Name', 'Root Locus ', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; 
grid on;
plot(real(eigv.'), imag(eigv.'), 'o', 'MarkerSize', 6,'MarkerFaceColor', 'auto','LineWidth', 1.5);


% xline(0, 'r--', 'LineWidth', 2);
% text(0.002, mean(ylim), 'Instabile \rightarrow', 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold');
% text(-0.002, mean(ylim), '\leftarrow Stabile', 'Color', 'b', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');

% 5. Formattazione e Label
xlabel('Growth rate, \mu ', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency, \omega ', 'FontSize', 12, 'FontWeight', 'bold');
title('Eigenvalue trajectory (Re 4000-4500) shift=0+7.5i', 'FontSize', 14);

hold off;

%% SECONDA ALTERNATIVA

clear; clc; close all;
load('reconstructed_series2.mat'); 
eigv = time_series; 

% 2. Prepara la figura
figure('Name', 'Root Locus', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; 
grid on;

% LA MODIFICA È QUI: ho aggiunto '-' prima di 'o' per tracciare la linea
plot(real(eigv.'), imag(eigv.'), '-o', 'MarkerSize', 5, 'LineWidth', 1.5);

% Aggiungo la linea dello zero (asse immaginario) per capire la stabilità
xline(0, 'k--', 'LineWidth', 1.5);

% 5. Formattazione e Label
xlabel('Growth rate, \mu', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency, \omega', 'FontSize', 12, 'FontWeight', 'bold');
title('Eigenvalue trajectory (Re 4000-5000)', 'FontSize', 14);
hold off;

%% TERZA ALTERNATIVA 
clear; clc; close all;
load('reconstructed_series2.mat'); 
eigv = time_series; 

% Estraggo le dimensioni per il ciclo
[num_eig, num_Re] = size(eigv);

% Creo un vettore fittizio per i colori (da Re 4000 a 5000 in base al numero di step)
Re_values = linspace(4000, 5000, num_Re);

% 2. Prepara la figura
figure('Name', 'Root Locus Colormap', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; 
grid on;

% LA MODIFICA È QUI: Un ciclo per disegnare ogni traiettoria
for i = 1:num_eig
    % 1. Disegna una linea grigia sottile sotto per mostrare la traiettoria
    plot(real(eigv(i,:)), imag(eigv(i,:)), '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 1);
    
    % 2. Disegna i pallini sopra, colorandoli in base al Reynolds
    scatter(real(eigv(i,:)), imag(eigv(i,:)), 40, Re_values, 'filled');
end

% Aggiungo la barra dei colori
colormap(jet); % Usa la mappa di colori stile arcobaleno (da blu a rosso)
c = colorbar;
c.Label.String = 'Reynolds Number';
c.Label.FontSize = 12;
c.Label.FontWeight = 'bold';

% Aggiungo la linea dello zero
xline(0, 'k--', 'LineWidth', 2);

% 5. Formattazione e Label
xlabel('Growth rate, \mu', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency, \omega', 'FontSize', 12, 'FontWeight', 'bold');
title('Eigenvalue trajectory (Re 4000-5000)', 'FontSize', 14);
hold off;

%% QUARTA ALTERNATIVA

clear; clc; close all;
load('reconstructed_series2.mat'); 
eigv = time_series; 

[num_eig, num_Re] = size(eigv);

% 2. Prepara la figura
figure('Name', 'Root Locus - Highlight Crossing', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; 
grid on;

% Prelevo una palette di colori forti per gli autovalori che incrociano
highlight_colors = lines(num_eig); 
color_idx = 1; % Contatore per usare colori diversi solo per quelli evidenziati

for i = 1:num_eig
    real_parts = real(eigv(i,:));
    
    % TEST: L'autovalore incrocia l'asse immaginario? (Da stabile a instabile)
    if min(real_parts) <= 0 && max(real_parts) > 0
        % SE INCROCIA: Colore unico, linea continua spessa
        plot(real(eigv(i,:)), imag(eigv(i,:)), '-o', ...
            'Color', highlight_colors(color_idx, :), ...
            'MarkerFaceColor', highlight_colors(color_idx, :), ...
            'LineWidth', 2, 'MarkerSize', 6);
        color_idx = color_idx + 1; % Cambio colore per il prossimo instabile
    else
        % SE RESTA STABILE: Grigio chiaro, linea sottile
        plot(real(eigv(i,:)), imag(eigv(i,:)), '-o', ...
            'Color', [0.75 0.75 0.75], ...
            'MarkerFaceColor', [0.75 0.75 0.75], ...
            'LineWidth', 1, 'MarkerSize', 4);
    end
end

xline(0, 'k--', 'LineWidth', 2); % Asse Immaginario

% 5. Formattazione e Label
xlabel('Growth rate, \mu ', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency, \omega ', 'FontSize', 12, 'FontWeight', 'bold');
title('Eigenvalue trajectory: Highlight Instability', 'FontSize', 14);
hold off;

%% QUINTA ALTERNATIVA
clear; clc; close all;
load('reconstructed_series2.mat'); 
eigv = time_series; 

[num_eig, num_Re] = size(eigv);

% 2. Prepara la figura
figure('Name', 'Root Locus - Unique Colors', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; 
grid on;

% GENERO 25 COLORI DISTINTI (La mappa 'turbo' è ottima per distinguere linee)
my_colors = turbo(num_eig); 

for i = 1:num_eig
    % Traccio linea tratteggiata (--), pallino (o), e forzo il colore i-esimo
    plot(real(eigv(i,:)), imag(eigv(i,:)), '--o', ...
        'Color', my_colors(i, :), ...
        'MarkerEdgeColor', my_colors(i, :), ...
        'MarkerFaceColor', my_colors(i, :), ...
        'LineWidth', 1.5, 'MarkerSize', 5);
end

xline(0, 'k--', 'LineWidth', 2); % Asse Immaginario

% 5. Formattazione e Label
ylim([0,10])
xlabel('Growth rate, \mu ', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency, \omega ', 'FontSize', 12, 'FontWeight', 'bold');
title('Eigenvalue trajectory (Re 4000-5000)', 'FontSize', 14);
hold off;

%% SESTA ALTERNATIVA
clear; clc; close all;

load('reconstructed_series2.mat'); 
eigv = time_series; 
[num_eig, num_Re] = size(eigv);

% --- OPZIONALE: Sfoltimento degli step ---
% Se hai 100 step, il grafico sarà un groviglio. Cambia 'step_salto' a 2 o 5 
% per plottare solo uno step ogni tot, rendendo il grafico molto più leggibile.
step_salto = 1; 
step_da_plottare = 1:step_salto:num_Re;
num_Re_plot = length(step_da_plottare);

% 1. Prepara la figura
figure('Name', 'Root Locus - High Contrast Colors', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; grid on;

% Definizione stili
line_color = [0.75 0.75 0.75]; % Grigio per le traiettorie di base
line_style = '--';
marker_style = 'o';
marker_size = 36; % Equivalente a size^2 in scatter

% 2. GENERO COLORI ALTAMENTE DISTINGUIBILI
% 'lines' genera i colori primari e secondari di massimo contrasto.
% Alternative valide: 'colorcube(num_Re_plot)' o 'prism(num_Re_plot)'
step_colors = lines(num_Re_plot);

% 3. Primo ciclo: Traccia tutte le linee di connessione per gli autovalori
for r = 1:num_eig
    gr = real(eigv(r, step_da_plottare));
    fr = imag(eigv(r, step_da_plottare));
    plot(gr, fr, line_style, 'Color', line_color, 'LineWidth', 0.8);
end

% 4. Secondo ciclo: Traccia i punti con colori netti
counter = 1;
for c = step_da_plottare
    gr_step = real(eigv(:, c));
    fr_step = imag(eigv(:, c));
    
    current_color = step_colors(counter, :);
    
    % MarkerEdgeColor nero ('k') aiuta a staccare i punti dallo sfondo e dalle linee
    scatter(gr_step, fr_step, marker_size, current_color, 'filled', 'MarkerEdgeColor', 'k');
    
    counter = counter + 1;
end

% 5. Formattazione assi
xlabel('Growth rate, \mu', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency, \omega', 'FontSize', 12, 'FontWeight', 'bold');
title('Eigenvalue Trajectories (High Contrast Steps)', 'FontSize', 14);
xline(0, '--k', 'LabelVerticalAlignment', 'bottom', 'FontSize', 10, 'LineWidth', 1.5);

% 6. Colorbar discreta (adattata per mostrare gli step)
cb = colorbar;
ylabel(cb, 'Re', 'FontSize', 11);
colormap(step_colors);
caxis([4000 5000]);

% Sistemiamo i tick della colorbar in modo che abbiano senso
if num_Re_plot > 10
    ticks = round(linspace(1, num_Re_plot, 10));
else
    ticks = 1:num_Re_plot;
end
cb.Ticks = ticks;
cb.TickLabels = arrayfun(@(t) sprintf('Step %d', step_da_plottare(t)), ticks, 'UniformOutput', false);

disp('Diagramma generato con colori ad alto contrasto!');

%% SETTIMA ALTERNATIVA
clear; clc; close all;
load('reconstructed_series2.mat'); 
eigv = time_series; 
[num_eig, num_steps] = size(eigv);

% --- IMPOSTAZIONI REYNOLDS (Modifica questi valori) ---
Re_min = 4000;
Re_max = 5000;
% Crea un vettore lineare di Reynolds per ogni step
Re_values = linspace(Re_min, Re_max, num_steps);

step_salto = 1; 
step_da_plottare = 1:step_salto:num_steps;

% 1. Prepara la figura
figure('Name', 'Eigenvalue trajectory', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; grid on;

line_color = [0.75 0.75 0.75];
marker_size = 36; 

% Imposta una colormap graduale (es. 'turbo', 'jet', o 'parula')
colormap('turbo'); 

% 2. Traccia le linee di connessione per gli autovalori
% for r = 1:num_eig
%     gr = real(eigv(r, step_da_plottare));
%     fr = imag(eigv(r, step_da_plottare));
%     plot(gr, fr, '--', 'Color', line_color, 'LineWidth', 0.8);
% end

% 3. Traccia i punti assegnando a ciascuno il suo valore di Reynolds
for c = step_da_plottare
    gr_step = real(eigv(:, c));
    fr_step = imag(eigv(:, c));
    
    % Recupera il Reynolds corrente
    Re_current = Re_values(c);
    
    % Lo scatter plot mappa automaticamente il colore se passiamo Re_current
    scatter(gr_step, fr_step, marker_size, repmat(Re_current, num_eig, 1), 'filled', 'MarkerEdgeColor', 'k');
end

% 4. Formattazione assi
xlabel('Growth rate', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency', 'FontSize', 12, 'FontWeight', 'bold');
title('Eigenvalue Trajectories', 'FontSize', 14);
xline(0, '--k', 'LabelVerticalAlignment', 'bottom', 'FontSize', 10, 'LineWidth', 1.5);

% 5. Colorbar continua
cb = colorbar;
ylabel(cb, 'Re', 'FontSize', 12, 'FontWeight', 'bold');
% Fissa i limiti della colorbar ai valori di Reynolds scelti
caxis([Re_min, Re_max]); % Nota: se usi MATLAB R2022a o successivi, puoi usare clim([Re_min, Re_max])

%% OTTAVA ALTERNATIVA
clear; clc; close all;
load('reconstructed_series2.mat');

Rei=4000;
Ref=5000;
Reint=linspace(Rei,Ref,4);

eigv = time_series; 
[num_eig, num_steps] = size(eigv);

% 1. Prepara la figura per l'animazione
figure('Name', 'Root Locus - Animation', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; grid on;

% Trova i limiti massimi e minimi per mantenere gli assi fissi durante l'animazione
min_gr = min(real(eigv(:))); max_gr = max(real(eigv(:)));
min_fr = min(imag(eigv(:))); max_fr = max(imag(eigv(:)));
% Aggiungo un piccolo margine (padding) del 10%
pad_gr = (max_gr - min_gr) * 0.1; if pad_gr == 0, pad_gr = 1; end
pad_fr = (max_fr - min_fr) * 0.1; if pad_fr == 0, pad_fr = 1; end
xlim([min_gr - pad_gr, max_gr + pad_gr]);
ylim([min_fr - pad_fr, max_fr + pad_fr]);

% Formattazione di base
xlabel('Growth rate, \mu', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency, \omega', 'FontSize', 12, 'FontWeight', 'bold');
xline(0, '--k', 'LabelVerticalAlignment', 'bottom', 'FontSize', 10, 'LineWidth', 1.5);

% Genero i colori in base al numero totale di step (es. mappa parula o turbo)
anim_colors = turbo(num_steps);
marker_size = 60; % Leggermente più grande per l'animazione

% Creo un oggetto scatter vuoto che aggiornerò nel ciclo
h_scatter = scatter(NaN, NaN, marker_size, 'filled', 'MarkerEdgeColor', 'k');

% 2. Ciclo di Animazione
disp('Inizio animazione...');
for c = 1:num_steps
    % Aggiorna il titolo per mostrare lo step corrente
    title(sprintf('Eigenvalue Evolution - Step %d Re %d', c, Reint(c)), 'FontSize', 14);
    
    % Estrai i dati dello step corrente
    gr_step = real(eigv(:, c));
    fr_step = imag(eigv(:, c));
    
    % Disegna le "scie" (traiettorie) lasciate dai punti
    % if c > 1
    %     for r = 1:num_eig
    %         plot([real(eigv(r, c-1)), real(eigv(r, c))], ...
    %              [imag(eigv(r, c-1)), imag(eigv(r, c))], ...
    %              '--', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
    %     end
    % end
    
    % Aggiorna le coordinate e i colori dello scatter plot
    set(h_scatter, 'XData', gr_step, 'YData', fr_step, 'CData', anim_colors(c,:));
    
    % Forza MATLAB a renderizzare subito il frame
    drawnow;
    
    % Pausa per regolare la velocità dell'animazione (in secondi)
    pause(1); 
end
disp('Animazione completata!');

%% NONA ALTERNATIVA
clear; clc; close all;
load('reconstructed_series2.mat'); 
eigv = time_series; 
[num_eig, num_steps] = size(eigv);

% --- IMPOSTAZIONI ESPORTAZIONE VIDEO ---
video_filename = 'Evoluzione_Autovalori.mp4'; % Nome del file in uscita
v = VideoWriter(video_filename, 'MPEG-4');    % Imposta il formato (MPEG-4 = .mp4)
v.FrameRate = 0.2;                             % Imposta i fotogrammi per secondo (FPS)
open(v);                                      % Apre il file per iniziare a scrivere

% 1. Prepara la figura per l'animazione
% È importante assegnare la figura a una variabile ('fig') per catturarla meglio
fig = figure('Name', 'Root Locus - Video Export', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; grid on;

% Trova i limiti massimi e minimi per mantenere gli assi fissi durante l'animazione
min_gr = min(real(eigv(:))); max_gr = max(real(eigv(:)));
min_fr = min(imag(eigv(:))); max_fr = max(imag(eigv(:)));
pad_gr = (max_gr - min_gr) * 0.1; if pad_gr == 0, pad_gr = 1; end
pad_fr = (max_fr - min_fr) * 0.1; if pad_fr == 0, pad_fr = 1; end
xlim([min_gr - pad_gr, max_gr + pad_gr]);
ylim([min_fr - pad_fr, max_fr + pad_fr]);

% Formattazione di base
xlabel('Growth rate, \mu', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency, \omega', 'FontSize', 12, 'FontWeight', 'bold');
xline(0, '--k', 'LabelVerticalAlignment', 'bottom', 'FontSize', 10, 'LineWidth', 1.5);

% Genero i colori in base al numero totale di step
anim_colors = turbo(num_steps);
marker_size = 60; 

% Creo un oggetto scatter vuoto che aggiornerò nel ciclo
h_scatter = scatter(NaN, NaN, marker_size, 'filled', 'MarkerEdgeColor', 'k');

% 2. Ciclo di Animazione e Salvataggio
disp(['Inizio generazione ed esportazione del video: ', video_filename, ' ...']);

for c = 1:num_steps
    % Aggiorna il titolo
    title(sprintf('Eigenvalue Evolution - Step %d di %d', c, num_steps), 'FontSize', 14);
    
    % Estrai i dati dello step corrente
    gr_step = real(eigv(:, c));
    fr_step = imag(eigv(:, c));
    
    % Disegna le "scie"
    % if c > 1
    %     for r = 1:num_eig
    %         plot([real(eigv(r, c-1)), real(eigv(r, c))], ...
    %              [imag(eigv(r, c-1)), imag(eigv(r, c))], ...
    %              '--', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
    %     end
    % end
    
    % Aggiorna le coordinate e i colori dello scatter plot
    set(h_scatter, 'XData', gr_step, 'YData', fr_step, 'CData', anim_colors(c,:));
    
    % Forza MATLAB a renderizzare subito il frame a schermo
    drawnow;
    
    % --- CATTURA E SCRITTURA DEL FOTOGRAMMA ---
    % Nota: ho rimosso la funzione 'pause' perché la velocità del video 
    % finale dipende solo dal v.FrameRate impostato all'inizio.
    frame = getframe(fig); % Cattura la schermata della figura 'fig'
    writeVideo(v, frame);  % Scrive il frame all'interno del file video
end

% 3. Chiusura del file
close(v); % FONDAMENTALE: se non chiudi l'oggetto, il file mp4 sarà corrotto

% Mostra il percorso esatto in cui è stato salvato il file
percorso_completo = fullfile(pwd, video_filename);
disp(['Esportazione completata! Il video è stato salvato in: ', percorso_completo]);

%% DECIMA ALTERNATIVA

clear; clc; close all;
load('reconstructed_series2.mat'); 

Rei=3000;
Ref=6000;
Reint=linspace(Rei,Ref,5);

eigv = time_series; 
[num_eig, num_steps] = size(eigv);

% --- IMPOSTAZIONI ESPORTAZIONE VIDEO ---
video_filename = 'Evoluzione_Autovalori.mp4'; % Nome del file in uscita
v = VideoWriter(video_filename, 'MPEG-4');    % Imposta il formato (MPEG-4 = .mp4)

% Impostazioni per rallentare il video mantenendo un frame rate standard
v.FrameRate = 30;                            % Imposta un FrameRate fluido e standard (es. 30 FPS)
durata_step = 1;                             % Secondi di durata desiderati per ogni singolo step
ripetizioni = v.FrameRate * durata_step;     % Calcola quante volte ripetere lo stesso frame

open(v);                                      % Apre il file per iniziare a scrivere

% 1. Prepara la figura per l'animazione
fig = figure('Name', 'Root Locus - Video Export', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; grid on;

% Trova i limiti massimi e minimi per mantenere gli assi fissi durante l'animazione
min_gr = min(real(eigv(:))); max_gr = max(real(eigv(:)));
min_fr = min(imag(eigv(:))); max_fr = max(imag(eigv(:)));

pad_gr = (max_gr - min_gr) * 0.1; if pad_gr == 0, pad_gr = 1; end
pad_fr = (max_fr - min_fr) * 0.1; if pad_fr == 0, pad_fr = 1; end
xlim([min_gr - pad_gr, max_gr + pad_gr]);
ylim([min_fr - pad_fr, max_fr + pad_fr]);

% Formattazione di base
xlabel('Growth rate, \mu', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency, \omega', 'FontSize', 12, 'FontWeight', 'bold');
xline(0, '--k', 'LabelVerticalAlignment', 'bottom', 'FontSize', 10, 'LineWidth', 1.5);

% Genero i colori in base al numero totale di step
anim_colors = turbo(num_steps);
marker_size = 60; 

% Creo un oggetto scatter vuoto che aggiornerò nel ciclo
h_scatter = scatter(NaN, NaN, marker_size, 'filled', 'MarkerEdgeColor', 'k');

% 2. Ciclo di Animazione e Salvataggio
disp(['Inizio generazione ed esportazione del video: ', video_filename, ' ...']);
for c = 1:num_steps
    % Aggiorna il titolo
    title(sprintf('Eigenvalue Evolution - Step %d Re %d', c, Reint(c)), 'FontSize', 14);
    
    % Estrai i dati dello step corrente
    gr_step = real(eigv(:, c));
    fr_step = imag(eigv(:, c));
    
    % Aggiorna le coordinate e i colori dello scatter plot
    set(h_scatter, 'XData', gr_step, 'YData', fr_step, 'CData', anim_colors(c,:));
    
    % Forza MATLAB a renderizzare subito il frame a schermo
    drawnow;
    
    % --- CATTURA E SCRITTURA DEL FOTOGRAMMA ---
    frame = getframe(fig); % Cattura la schermata della figura 'fig'
    
    % Scrive lo stesso frame ripetutamente per rallentare l'animazione
    for i = 1:ripetizioni
        writeVideo(v, frame); 
    end
end

% 3. Chiusura del file
close(v); % FONDAMENTALE: se non chiudi l'oggetto, il file mp4 sarà corrotto

% Mostra il percorso esatto in cui è stato salvato il file
percorso_completo = fullfile(pwd, video_filename);
disp(['Esportazione completata! Il video è stato salvato in: ', percorso_completo]);

%%  TOTAL PLOT DIFFERENT SHIFT (4 SHIFT + RIMOZIONE SOVRAPPOSIZIONI)
clear; clc; close all;

% --- 1. SELEZIONE DEI FILE ---
disp('Seleziona i file .mat contenenti i diversi shift...');
[files, path] = uigetfile('*.mat', 'Seleziona le serie', 'MultiSelect', 'on');
if isequal(files, 0), return; end
if ischar(files), files = {files}; end

% --- IMPOSTAZIONI REYNOLDS (Modifica questi valori se serve) ---
Re_min = 4000;
Re_max = 5000;
step_salto = 1; 

% Inizializzo i vettori "calderone"
all_Re = [];
all_eigs = [];

% --- 2. CARICAMENTO E UNIONE DATI ---
disp('Estrazione dati dai file...');
for i = 1:length(files)
    full_path = fullfile(path, files{i});
    dati = load(full_path);
    
    % Controllo nome variabile (aggiusta se nel tuo file si chiama diversamente)
    if isfield(dati, 'time_series')
        eigv = dati.time_series;
    elseif isfield(dati, 'eigens_in_time')
        eigv = dati.eigens_in_time;
    else
        error('Variabile autovalori non trovata nel file %s', files{i});
    end
    
    [num_eig, num_steps] = size(eigv);
    
    % Crea un vettore lineare di Reynolds per ogni step di questo file
    Re_values = linspace(Re_min, Re_max, num_steps);
    
    % Srotoliamo la matrice (applicando già lo step_salto)
    for c = 1:step_salto:num_steps
        all_Re = [all_Re; repmat(Re_values(c), num_eig, 1)];
        all_eigs = [all_eigs; eigv(:, c)];
    end
end

% --- 3. RIMOZIONE SOVRAPPOSIZIONI (Tolleranza numerica) ---
disp('Eliminazione sovrapposizioni numeriche in corso...');
tolleranza = 1e-5;
clean_Re = [];
clean_eigs = [];

unique_Re = unique(all_Re);

for i = 1:length(unique_Re)
    current_Re = unique_Re(i);
    idx = find(all_Re == current_Re);
    eigs_at_Re = all_eigs(idx);
    
    punti_complessi = [real(eigs_at_Re), imag(eigs_at_Re)];
    [~, indici_unici] = uniquetol(punti_complessi, tolleranza, 'ByRows', true, 'DataScale', 1);
    
    autovalori_puliti = eigs_at_Re(indici_unici);
    
    clean_Re = [clean_Re; repmat(current_Re, length(autovalori_puliti), 1)];
    clean_eigs = [clean_eigs; autovalori_puliti];
end

% --- 4. PREPARAZIONE DELLA FIGURA ---
figure('Name', 'Eigenvalue trajectory', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; grid on;
marker_size = 36; 

colormap('turbo'); 

% --- 5. PLOT VETTORIZZATO (Molto più veloce del ciclo for) ---
% scatter prende: asse X, asse Y, dimensione, vettore Colore (il Reynolds!)
scatter(real(clean_eigs), imag(clean_eigs), marker_size, clean_Re, 'filled', 'MarkerEdgeColor', 'k');

% --- 6. FORMATTAZIONE ASSI ---
xlabel('Growth rate', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency', 'FontSize', 12, 'FontWeight', 'bold');
title('Eigenvalue Trajectories (Merged Shifts)', 'FontSize', 14);

% Linea zero (Asse immaginario per la stabilità)
xline(0, '--k', 'LabelVerticalAlignment', 'bottom', 'FontSize', 10, 'LineWidth', 1.5);

% Colorbar continua
cb = colorbar;
ylabel(cb, 'Re', 'FontSize', 12, 'FontWeight', 'bold');

% Fissa i limiti della colorbar ai valori di Reynolds scelti
try
    clim([Re_min, Re_max]); %xlim([min(clean_Re), max(clean_Re)]);
catch
    caxis([Re_min, Re_max]); % Fallback per versioni più vecchie di MATLAB
end

disp('Plot completato con successo!');

%% 11 ALTERNATIVA
clear; clc; close all;
load('reconstructed_series2.mat'); 
eigv = time_series; 
[num_eig, num_steps] = size(eigv);
% --- IMPOSTAZIONI REYNOLDS (Modifica questi valori) ---
Re_min = 3000;
Re_max = 6000;
% Crea un vettore lineare di Reynolds per ogni step
Re_values = linspace(Re_min, Re_max, num_steps);
step_salto = 1; 
step_da_plottare = 1:step_salto:num_steps;
% 1. Prepara la figura
figure('Name', 'Eigenvalue trajectory', 'Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; grid on;
line_color = [0.75 0.75 0.75];
marker_size = 36; 

% ---> UNICA MODIFICA: Utilizzo di 'parula' per il massimo contrasto di luminosità <---
colormap('parula'); 

% 2. Traccia le linee di connessione per gli autovalori
% for r = 1:num_eig
%     gr = real(eigv(r, step_da_plottare));
%     fr = imag(eigv(r, step_da_plottare));
%     plot(gr, fr, '--', 'Color', line_color, 'LineWidth', 0.8);
% end
% 3. Traccia i punti assegnando a ciascuno il suo valore di Reynolds
for c = step_da_plottare
    gr_step = real(eigv(:, c));
    fr_step = imag(eigv(:, c));
    
    % Recupera il Reynolds corrente
    Re_current = Re_values(c);
    
    % Lo scatter plot mappa automaticamente il colore se passiamo Re_current
    scatter(gr_step, fr_step, marker_size, repmat(Re_current, num_eig, 1), 'filled', 'MarkerEdgeColor', 'k');
end
% 4. Formattazione assi
xlabel('Growth rate', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency', 'FontSize', 12, 'FontWeight', 'bold');
title('Eigenvalue Trajectories', 'FontSize', 14);
xline(0, '--k', 'LabelVerticalAlignment', 'bottom', 'FontSize', 10, 'LineWidth', 1.5);
% 5. Colorbar continua
cb = colorbar;
ylabel(cb, 'Re', 'FontSize', 12, 'FontWeight', 'bold');
% Fissa i limiti della colorbar ai valori di Reynolds scelti
caxis([Re_min, Re_max]); % Nota: se usi MATLAB R2022a o successivi, puoi usare clim([Re_min, Re_max])