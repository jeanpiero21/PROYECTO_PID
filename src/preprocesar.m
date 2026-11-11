function Ip = preprocesar(I, dirImg, P)
%PREPROCESAR Filtro de mediana por canal.
%   Quita el ruido del sensor y los artefactos de compresión JPEG sin
%   borronear los bordes de los autos (la mediana conserva bordes mejor que
%   un filtro promedio o gaussiano).
%
%   Ip = preprocesar(I, dirImg)      usa parametros()
%   Ip = preprocesar(I, dirImg, P)
if nargin < 3, P = parametros(); end
if size(I, 3) ~= 3
    error('preprocesar: se espera una imagen RGB.');
end

Ip = I;
for c = 1:3
    Ip(:,:,c) = medfilt2(I(:,:,c), [P.tamMediana P.tamMediana], 'symmetric');
end

imwrite(Ip, fullfile(dirImg, '01_mediana.png'));
end
