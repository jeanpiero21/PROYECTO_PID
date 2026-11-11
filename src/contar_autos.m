function [nAutos, stats, Lautos, escala] = contar_autos(BWm, I, dirImg, P)
%CONTAR_AUTOS Cuenta los autos de la máscara, incluidos los que quedaron pegados.
%   Autos estacionados uno al lado del otro suelen quedar unidos en una sola
%   región. Se resuelve en tres pasos:
%   1) Transformada de distancia (bwdist): cada píxel guarda su distancia al
%      fondo. Su máximo en un auto aislado es medio ancho del auto.
%   2) Núcleos: los píxeles con distancia > alfa * semiancho. Los puentes
%      delgados entre autos desaparecen, así que una región con un solo
%      núcleo es un auto aislado. Con esas regiones se estima, en cada
%      imagen, el área y el largo de un auto (se adapta a la altura del dron).
%   3) Cada región cuenta como round(área / área de un auto) autos, y sus
%      píxeles se reparten en partes iguales a lo largo de su eje mayor
%      (PCA) para ubicar cada auto. Se descartan regiones muy chicas
%      (personas, motos) y muy gruesas (vegetación, murales: no son filas de autos).
%
%   [nAutos, stats] = contar_autos(BWm, I, dirImg)      usa parametros()
%   [nAutos, stats, Lautos, escala] = contar_autos(BWm, I, dirImg, P)
%   stats(i).Centroid = [x y] del auto i;  Lautos = una etiqueta por auto.
if nargin < 4, P = parametros(); end

[H, W] = size(BWm);
Lautos = zeros(H, W);
stats  = struct('Centroid', {}, 'Area', {}, 'Region', {});
escala = struct('semiancho', NaN, 'areaAuto', NaN, 'largoAuto', NaN);

D = bwdist(~BWm);
L = bwlabel(BWm, 8);
R = regionprops(L, D, 'Area', 'MaxIntensity', 'MajorAxisLength', ...
                'MinorAxisLength', 'PixelIdxList', 'PixelList');
nucleos = false(H, W);

if ~isempty(R)
    areas   = [R.Area];
    grandes = areas > P.areaRegionMin;
    if ~any(grandes), grandes = true(size(areas)); end

    % 1) Escala: medio ancho típico de un auto
    escala.semiancho = median([R(grandes).MaxIntensity]);

    % 2) Núcleos y regiones con un solo auto
    nucleos = D > P.alfa * escala.semiancho;
    Ln = bwlabel(nucleos, 8);
    nNucleos = zeros(1, numel(R));
    for k = 1:numel(R)
        nNucleos(k) = nnz(unique(Ln(R(k).PixelIdxList)));
    end
    solos = nNucleos == 1 & grandes;
    if nnz(solos) < 3, solos = grandes; end
    escala.areaAuto  = median(areas(solos));
    escala.largoAuto = median([R(solos).MajorAxisLength]);

    % 3) Conteo por área y ubicación de cada auto
    for k = 1:numel(R)
        if R(k).Area < P.fraccionMin * escala.areaAuto, continue; end
        if R(k).MinorAxisLength > P.grosorMax * escala.largoAuto, continue; end

        n  = max(1, round(R(k).Area / escala.areaAuto));
        xy = R(k).PixelList;                    % [x y] de cada píxel de la región
        c  = mean(xy, 1);
        [V, E] = eig(cov(xy));                  % PCA: dirección del eje mayor
        [~, iMax] = max(diag(E));
        t = (xy - c) * V(:, iMax);              % posición de cada píxel sobre ese eje
        [~, orden] = sort(t);
        cortes = round(linspace(0, numel(t), n + 1));
        for g = 1:n
            idx = orden(cortes(g)+1 : cortes(g+1));
            id  = numel(stats) + 1;
            Lautos(R(k).PixelIdxList(idx)) = id;
            stats(id).Centroid = mean(xy(idx, :), 1);
            stats(id).Area     = numel(idx);
            stats(id).Region   = k;
        end
    end
end
nAutos = numel(stats);

% Imágenes intermedias y final
imwrite(mat2gray(D), fullfile(dirImg, '05_distancia.png'));
imwrite(nucleos,     fullfile(dirImg, '06_nucleos.png'));

colores = jet(max(nAutos, 1));
colores = colores([1:2:end, 2:2:end], :);      % autos vecinos con colores distintos
fig = figure('Visible', 'off');
imshow(labeloverlay(I, Lautos, 'Colormap', colores, 'Transparency', 0.5));
hold on
if nAutos > 0
    cen = cat(1, stats.Centroid);
    plot(cen(:,1), cen(:,2), 'w.', 'MarkerSize', 14);
end
title(sprintf('Autos detectados: %d', nAutos));
guardar_figura(fig, fullfile(dirImg, '07_autos.png'));
end
