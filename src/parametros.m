function P = parametros()
%PARAMETROS Todos los parámetros del pipeline en un solo lugar.
%   Valores calibrados con las 8 imágenes gf2_* (vuelo 20161030_GF2).
%   gen_ntu y gen_tpz NO se usaron para ajustar nada: solo para evaluar.

% --- Bloque 2: preprocesamiento ---
P.tamMediana = 5;          % ventana del filtro de mediana (px)

% --- Bloque 3: segmentación por cromaticidad ---
% Croma = sqrt(a*^2 + b*^2) en Lab. El asfalto y las manchas de humedad son
% grises neutros (croma ~2-3); los autos tienen color o un tinte azulado de
% pintura y vidrios (croma > 5), incluso los negros y los blancos.
P.umbralCroma = 5.5;       % croma mínima para considerar un píxel "auto"
P.tonoVeg     = [100 200]; % rango de tono (grados en el plano a*b*) de la vegetación
P.cromaVegMin = 4;         % croma mínima para marcar vegetación

% --- Bloque 4: morfología ---
P.radioApertura = 3;       % disco de la apertura: borra ruido y líneas pintadas finas
P.areaMinima    = 300;     % bwareaopen: regiones más chicas se descartan (px)

% --- Bloque 5: conteo ---
P.areaRegionMin = 800;     % regiones más grandes que esto sirven para estimar la escala
P.alfa          = 0.4;     % núcleo = distancia > alfa * semiancho típico de un auto
P.fraccionMin   = 0.4;     % región < fraccionMin * área de un auto -> no es auto
P.grosorMax     = 1.6;     % región más gruesa que grosorMax * largo de un auto -> no es fila de autos

% --- Bloque 6: ocupación ---
P.coberturaOcupado = 0.12; % fracción del espacio cubierta por la máscara para decir "ocupado"
end
