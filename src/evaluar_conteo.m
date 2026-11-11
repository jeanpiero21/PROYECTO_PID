function ev = evaluar_conteo(stats, cajas, I, dirImg)
%EVALUAR_CONTEO Compara los autos detectados con las cajas de CARPK.
%   Un auto detectado es verdadero positivo (TP) si su centroide cae dentro
%   de una caja que aún no fue asignada (se asigna primero el par más
%   cercano al centro de la caja). Lo que sobra son falsos positivos (FP) y
%   las cajas sin detección son falsos negativos (FN).
%
%   ev = evaluar_conteo(stats, cajas, I, dirImg)
nG = size(cajas, 1);
if isempty(stats)
    cen = zeros(0, 2);
else
    cen = cat(1, stats.Centroid);
end
nD = size(cen, 1);

pares = zeros(0, 3);                       % [distancia, detección, caja]
for i = 1:nD
    dentro = abs(cen(i,1) - cajas(:,1)) <= cajas(:,3)/2 & ...
             abs(cen(i,2) - cajas(:,2)) <= cajas(:,4)/2;
    for j = find(dentro)'
        pares(end+1, :) = [hypot(cen(i,1) - cajas(j,1), cen(i,2) - cajas(j,2)), i, j]; %#ok<AGROW>
    end
end
pares = sortrows(pares, 1);

okD = false(nD, 1);
okG = false(nG, 1);
for p = 1:size(pares, 1)
    i = pares(p, 2); j = pares(p, 3);
    if ~okD(i) && ~okG(j)
        okD(i) = true; okG(j) = true;
    end
end

ev.reales     = nG;
ev.detectados = nD;
ev.error      = nD - nG;
ev.TP = nnz(okD);
ev.FP = nD - ev.TP;
ev.FN = nG - ev.TP;
ev.precision = ev.TP / max(nD, 1);
ev.recall    = ev.TP / max(nG, 1);

% Figura: cajas reales (amarillo = encontrada, magenta = no encontrada),
% detecciones (verde = correcta, rojo = falso positivo)
fig = figure('Visible', 'off');
imshow(I); hold on
for j = 1:nG
    r = [cajas(j,1) - cajas(j,3)/2, cajas(j,2) - cajas(j,4)/2, cajas(j,3), cajas(j,4)];
    if okG(j)
        rectangle('Position', r, 'EdgeColor', 'y', 'LineWidth', 0.75);
    else
        rectangle('Position', r, 'EdgeColor', 'm', 'LineWidth', 2.5);
    end
end
if nD > 0
    plot(cen(okD,1),  cen(okD,2),  'g.', 'MarkerSize', 18);
    plot(cen(~okD,1), cen(~okD,2), 'r.', 'MarkerSize', 18);
end
title(sprintf('Reales %d | detectados %d | TP %d  FP %d  FN %d', nG, nD, ev.TP, ev.FP, ev.FN));
guardar_figura(fig, fullfile(dirImg, '08_evaluacion.png'));
end
