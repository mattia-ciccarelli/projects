% --- SCRIPT UNIVERSALE PER DIAGRAMMA DI BIFORCAZIONE MATCONT ---

% 1. Estrazione dei dati dalla matrice
dati_curva = exported.x;

% Il parametro di continuazione (asse X) è sempre l'ultima riga
parametro = dati_curva(end, :);

% Scegliamo la variabile di stato da plottare (asse Y). 
% Qui usiamo la prima riga (prima variabile di stato). 
% Cambia l'1 con 2, 3, ecc. se vuoi osservare le altre variabili.
variabile_stato = dati_curva(1, :);

% 2. Creazione della figura
figure('Name', 'Diagramma di Biforcazione', 'Color', 'w');
hold on;

% Plot della curva principale
plot(parametro, variabile_stato, 'b-', 'LineWidth', 1.5);

% 3. Estrazione e plot dei punti speciali (Biforcazioni)
% MatCont usa la struttura 's' per salvare i punti notevoli
if isprop(exported, 's') && ~isempty(exported.s)
    % Cicliamo sui punti speciali (ignoriamo il primo e l'ultimo che sono inizio/fine)
    for i = 2:(length(exported.s) - 1)
        
        idx = exported.s(i).index;   % Indice della colonna in cui si trova la biforcazione
        label = exported.s(i).label; % Tipo di biforcazione (es. 'HB', 'LP')
        
        % Plot del marker (pallino rosso)
        plot(parametro(idx), variabile_stato(idx), 'ro', ...
            'MarkerFaceColor', 'r', 'MarkerSize', 6);
            
        % Aggiunta dell'etichetta di testo vicino al punto
        text(parametro(idx), variabile_stato(idx), ['  ' label], ...
            'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
    end
end

% 4. Estetica del grafico
xlabel('Parametro di Continuazione', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Variabile di Stato 1', 'FontSize', 12, 'FontWeight', 'bold');
title('Diagramma di Biforcazione', 'FontSize', 14);
% Imposta i limiti degli assi per replicare la visuale di MatCont
xlim([4000, 5200]);
ylim([0, 1]);

% Opzionale: rinomina le etichette per essere fedele a MatCont
xlabel('Re', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('a1', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
box on;
hold off;