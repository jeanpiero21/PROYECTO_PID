function cajas = leer_anotaciones(archivo, W, H)
%LEER_ANOTACIONES Lee un .txt de CARPK en formato YOLO y devuelve las cajas de autos.
%   Cada línea del archivo: clase xc yc ancho alto (normalizados de 0 a 1).
%   Clase 0 = Car, clase 1 = Person (se ignora).
%   cajas: N x 4 = [xc yc ancho alto] en píxeles, con la convención de
%   MATLAB (el centro del primer píxel es 1).
A = load(archivo, '-ascii');
if isempty(A)
    cajas = zeros(0, 4);
    return
end
A = A(A(:,1) == 0, :);
cajas = [A(:,2)*W + 0.5, A(:,3)*H + 0.5, A(:,4)*W, A(:,5)*H];
end
