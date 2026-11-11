function oc = ocupacion(BWm, I, archivoFilas, cajas, dirImg, P)
%OCUPACION Porcentaje de ocupación con las filas de espacios marcadas a mano.
%   Cada espacio está ocupado si la máscara de autos cubre más de
%   P.coberturaOcupado de su área. Un espacio vacío es asfalto (croma baja),
%   así que su cobertura queda cerca de 0 aunque tenga manchas o sombras.
%   Si se pasan las cajas de CARPK, también se calcula la ocupación real
%   (un espacio está ocupado si contiene el centro de alguna caja).
%
%   oc = ocupacion(BWm, I, archivoFilas, cajas, dirImg)      usa parametros()
%   oc = ocupacion(BWm, I, archivoFilas, cajas, dirImg, P)
%   archivoFilas: CSV de marcar_filas.m (fila, 8 coordenadas de esquinas, n_espacios).
if nargin < 6, P = parametros(); end

F   = readmatrix(archivoFilas);
esp = espacios_desde_filas(F(:, 2:10));
[H, W] = size(BWm);
nE = numel(esp);

cobertura = zeros(nE, 1);
ocupado   = false(nE, 1);
esReal    = nan(nE, 1);          % ocupación según las cajas de CARPK
zonaRoja  = false(H, W);
zonaVerde = false(H, W);
for e = 1:nE
    q = esp{e};
    m = poly2mask(q(:,1), q(:,2), H, W);
    cobertura(e) = nnz(BWm & m) / max(nnz(m), 1);
    ocupado(e)   = cobertura(e) > P.coberturaOcupado;
    if ocupado(e)
        zonaRoja = zonaRoja | m;
    else
        zonaVerde = zonaVerde | m;
    end
    if ~isempty(cajas)
        esReal(e) = any(inpolygon(cajas(:,1), cajas(:,2), q(:,1), q(:,2)));
    end
end
zonaVerde = zonaVerde & ~zonaRoja;

oc.espacios   = nE;
oc.ocupados   = nnz(ocupado);
oc.libres     = nE - oc.ocupados;
oc.porcentaje = 100 * oc.ocupados / max(nE, 1);
oc.cobertura  = cobertura;
oc.ocupado    = ocupado;
if isempty(cajas)
    oc.ocupadosReales = NaN;
    oc.aciertos       = NaN;
else
    oc.ocupadosReales = nnz(esReal == 1);
    oc.aciertos       = nnz(ocupado == (esReal == 1));
end

% Máscara de espacios vacíos (entregable del enunciado)
imwrite(zonaVerde, fullfile(dirImg, '10_espacios_vacios.png'));

% Figura: espacios ocupados en rojo y libres en verde
J = im2double(I);
rojo  = cat(3, 0.90, 0.20, 0.20);
verde = cat(3, 0.20, 0.80, 0.20);
J = J .* ~(zonaRoja | zonaVerde) + (0.55*J + 0.45*rojo) .* zonaRoja + (0.55*J + 0.45*verde) .* zonaVerde;
fig = figure('Visible', 'off');
imshow(J); hold on
for e = 1:nE
    q = esp{e};
    if ocupado(e), col = [0.9 0.2 0.2]; else, col = [0.2 0.8 0.2]; end
    plot(q([1:4 1], 1), q([1:4 1], 2), '-', 'Color', col, 'LineWidth', 1.5);
end
title(sprintf('Ocupados %d de %d espacios (%.1f %%)', oc.ocupados, nE, oc.porcentaje));
guardar_figura(fig, fullfile(dirImg, '09_ocupacion.png'));
end
