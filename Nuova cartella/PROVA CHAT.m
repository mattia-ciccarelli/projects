% === SCRIPT PULITO PER RIPLOTTARE I DATI MATCONT ===
clear; clc; close all;

% Definisco la tua cartella esatta (presa dallo screenshot)
cartella_dati = 'C:\Users\Mattia\Desktop\documenti double degree\esami dd\stages\ensta\MatCont7p6\Systems\Uchannel\diagram\';

% =========================================================
% 1. CARICAMENTO E PLOT DELL'EQUILIBRIO (EP_EP)
% =========================================================
% Carica il file dell'equilibrio
load(fullfile(cartella_dati, 'EP_EP(1).mat'));

% Estrazione: x(end,:) è il parametro, x(1,:) è a1
Re_eq = x(end, :); 
a1_eq = x(1, :);   

figure(1);
hold on; % Questo comando unisce i grafici!
% Traccio l'equilibrio (linea tratteggiata nera)
plot(Re_eq, a1_eq, 'k--', 'LineWidth', 2, 'DisplayName', 'Equilibrio Laminare (EP\_EP)');

% =========================================================
% 2. CARICAMENTO E PLOT DEL CICLO LIMITE (H_LC)
% =========================================================
% Carica il file del ciclo limite
load(fullfile(cartella_dati, 'H_LC(1).mat'));

ndim = 2; % Numero di variabili del sistema

% Estrazione: x(end,:) è il parametro. 
Re_lc = x(end, :); 

% MatCont salva tutta l'onda. Prendo il valore MASSIMO di a1 per ogni step
a1_lc_max = max(x(1:ndim:end-2, :));

% Traccio il ciclo limite (linea blu continua)
plot(Re_lc, a1_lc_max, 'b-', 'LineWidth', 2.5, 'DisplayName', 'Ciclo Limite (H\_LC)');

% =========================================================
% 3. TRUCCHI ESTETICI
% =========================================================
grid on;
xlabel('Parametro a_3 (Reynolds)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Ampiezza a_1', 'FontSize', 12, 'FontWeight', 'bold');
title('Diagramma di Biforcazione (a_1 vs Re)', 'FontSize', 14);
legend('Location', 'northwest');
box on;