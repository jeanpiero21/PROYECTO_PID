%% PROYECTO PID - Ocupacion de estacionamientos con drones (pipeline completo)
% Grupo 1: Barboza, Fuentes, Gutierrez
% Es main.m con los bloques activados, más:
%   - evaluación contra las cajas de CARPK (data/anotaciones/<nombre>.txt)
%   - ocupación, si existe data/espacios/<nombre>.csv (se crea con marcar_filas)
%   - tabla resumen en resultados/resumen.csv
clc; clear; close all;
addpath('src');
P = parametros();

carpetaIn  = fullfile('data', 'originales');
carpetaOut = 'resultados';
archivos = [dir(fullfile(carpetaIn, '*.jpg')); dir(fullfile(carpetaIn, '*.png'))];
nImg = numel(archivos);

imagen = strings(nImg, 1);
[autosReales, autosDetectados, TP, FP, FN, espacios, ocupados, ...
 ocupacionPct, ocupadosReales, espaciosBien] = deal(nan(nImg, 1));

for k = 1:nImg
    [~, nombre] = fileparts(archivos(k).name);
    imagen(k) = nombre;
    I = imread(fullfile(carpetaIn, archivos(k).name));

    % Carpeta propia por imagen: resultados/<nombre>/00_original.png, 01_..., 02_...
    dirImg = fullfile(carpetaOut, nombre);
    if ~exist(dirImg, 'dir'), mkdir(dirImg); end
    imwrite(I, fullfile(dirImg, '00_original.png'));

    % --- Bloque 2: preprocesamiento ---
    Ip = preprocesar(I, dirImg, P);

    % --- Bloque 3: segmentacion ---
    BW = segmentar(Ip, dirImg, P);

    % --- Bloque 4: morfologia ---
    BWm = morfologia(BW, dirImg, P);

    % --- Bloque 5: conteo ---
    [nAutos, stats] = contar_autos(BWm, I, dirImg, P);
    autosDetectados(k) = nAutos;

    % --- Evaluacion contra CARPK ---
    cajas = zeros(0, 4);
    archivoGT = fullfile('data', 'anotaciones', [nombre '.txt']);
    if isfile(archivoGT)
        cajas = leer_anotaciones(archivoGT, size(I, 2), size(I, 1));
        ev = evaluar_conteo(stats, cajas, I, dirImg);
        autosReales(k) = ev.reales;
        TP(k) = ev.TP;  FP(k) = ev.FP;  FN(k) = ev.FN;
    end

    % --- Bloque 6: ocupacion (solo si se marcaron las filas de espacios) ---
    archivoFilas = fullfile('data', 'espacios', [nombre '.csv']);
    if isfile(archivoFilas)
        oc = ocupacion(BWm, I, archivoFilas, cajas, dirImg, P);
        espacios(k) = oc.espacios;
        ocupados(k) = oc.ocupados;
        ocupacionPct(k) = oc.porcentaje;
        ocupadosReales(k) = oc.ocupadosReales;
        espaciosBien(k) = oc.aciertos;
    end

    fprintf('%-8s autos: %3d detectados / %3d reales', nombre, nAutos, autosReales(k));
    if ~isnan(espacios(k))
        fprintf('  | ocupacion: %d de %d espacios (%.1f %%)', ocupados(k), espacios(k), ocupacionPct(k));
    end
    fprintf('\n');
end

errorConteo = autosDetectados - autosReales;
precision = TP ./ (TP + FP);
recall    = TP ./ (TP + FN);
resumen = table(imagen, autosReales, autosDetectados, errorConteo, TP, FP, FN, precision, recall, ...
                espacios, ocupados, ocupacionPct, ocupadosReales, espaciosBien);
writetable(resumen, fullfile(carpetaOut, 'resumen.csv'));
disp(resumen)

% Metricas por grupo: calibracion (gf2_*) y generalizacion (gen_*)
conGT = ~isnan(autosReales);
esGen = startsWith(imagen, "gen");
grupos = {conGT & ~esGen, 'Calibracion'; conGT & esGen, 'Generalizacion'};
for g = 1:size(grupos, 1)
    s = grupos{g, 1};
    if ~any(s), continue; end
    fprintf('%s (%d imagenes): error absoluto medio = %.1f autos/imagen, precision = %.2f, recall = %.2f\n', ...
        grupos{g, 2}, nnz(s), mean(abs(errorConteo(s))), ...
        sum(TP(s)) / sum(TP(s) + FP(s)), sum(TP(s)) / sum(TP(s) + FN(s)));
end
