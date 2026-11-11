function [BW, C] = segmentar(Ip, dirImg, P)
%SEGMENTAR Umbralización por cromaticidad en el espacio Lab.
%   En escala de grises un auto negro se confunde con una mancha de humedad
%   y un auto blanco con las líneas pintadas. En Lab se separa la
%   luminancia (L*) del color (a*, b*):
%     - asfalto, manchas, líneas y adoquines son grises neutros -> croma baja
%     - los autos tienen color o un tinte azulado (pintura, vidrios) -> croma alta
%   La vegetación también tiene croma alta, pero su tono es verde: se excluye.
%
%   [BW, C] = segmentar(Ip, dirImg)      usa parametros()
%   [BW, C] = segmentar(Ip, dirImg, P)
if nargin < 3, P = parametros(); end

lab = rgb2lab(Ip);                 % L* en [0,100]; a*, b* aprox. en [-100,100]
a = lab(:,:,2);
b = lab(:,:,3);

C = hypot(a, b);                   % croma: distancia al gris neutro
C = medfilt2(C, [P.tamMediana P.tamMediana], 'symmetric');   % suaviza los bloques 8x8 del JPEG
tono = mod(atan2d(b, a), 360);     % tono en grados

veg = tono > P.tonoVeg(1) & tono < P.tonoVeg(2) & C > P.cromaVegMin;
BW  = C > P.umbralCroma & ~veg;

% Imágenes intermedias
imwrite(ind2rgb(im2uint8(mat2gray(C, [0 15])), parula(256)), fullfile(dirImg, '02_croma.png'));
imwrite(veg, fullfile(dirImg, '03a_vegetacion.png'));
imwrite(BW,  fullfile(dirImg, '03b_umbral.png'));
end
