function BWm = morfologia(BW, dirImg, P)
%MORFOLOGIA Limpieza de la máscara de autos.
%   1) Apertura con un disco: borra puntos de ruido y lo que es más delgado
%      que el disco (líneas pintadas, rayado amarillo, bordes de color).
%   2) Relleno de huecos: completa autos con zonas sin color (techos).
%   3) bwareaopen: descarta regiones demasiado chicas para ser un auto.
%
%   BWm = morfologia(BW, dirImg)      usa parametros()
%   BWm = morfologia(BW, dirImg, P)
if nargin < 3, P = parametros(); end

BWm = imopen(BW, strel('disk', P.radioApertura, 0));
BWm = imfill(BWm, 'holes');
BWm = bwareaopen(BWm, P.areaMinima);

imwrite(BWm, fullfile(dirImg, '04_morfologia.png'));
end
