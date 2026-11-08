%% PROYECTO PID - Ocupacion de estacionamientos con drones
% Grupo 1: Barboza, Fuentes, Gutierrez
clc; clear; close all;
addpath('src');

carpetaIn  = fullfile('data','originales');
carpetaOut = 'resultados';
archivos = [dir(fullfile(carpetaIn,'*.jpg')); dir(fullfile(carpetaIn,'*.png'))];

for k = 1:numel(archivos)
    [~, nombre] = fileparts(archivos(k).name);
    I = imread(fullfile(carpetaIn, archivos(k).name));

    % Carpeta propia por imagen: resultados/<nombre>/00_original.png, 01_..., 02_...
    dirImg = fullfile(carpetaOut, nombre);
    if ~exist(dirImg, 'dir'), mkdir(dirImg); end
    imwrite(I, fullfile(dirImg, '00_original.png'));

    % --- Bloque 2: preprocesamiento ---
    % Ip = preprocesar(I, dirImg);

    % --- Bloque 3: segmentacion ---
    % BW = segmentar(Ip, dirImg);

    % --- Bloque 4: morfologia ---
    % BWm = morfologia(BW, dirImg);

    % --- Bloque 5: conteo y ocupacion ---
    % [nAutos, stats] = contar_autos(BWm, I, dirImg);

    fprintf('%s procesada\n', nombre);
end
