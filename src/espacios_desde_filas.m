function esp = espacios_desde_filas(F)
%ESPACIOS_DESDE_FILAS Divide cada fila de estacionamiento en n espacios iguales.
%   F: una fila de la matriz por cada fila del estacionamiento:
%      [x_sup_izq y_sup_izq x_sup_der y_sup_der x_inf_der y_inf_der x_inf_izq y_inf_izq n]
%   Las esquinas deben estar sobre las líneas pintadas de los extremos de la fila.
%   esp: celda con un polígono 4x2 por espacio (sup-izq, sup-der, inf-der, inf-izq).
esp = {};
for f = 1:size(F, 1)
    p1 = F(f, 1:2);  p2 = F(f, 3:4);  p3 = F(f, 5:6);  p4 = F(f, 7:8);
    n  = F(f, 9);
    for k = 1:n
        t0 = (k - 1) / n;  t1 = k / n;
        sup0 = p1 + t0 * (p2 - p1);   sup1 = p1 + t1 * (p2 - p1);
        inf0 = p4 + t0 * (p3 - p4);   inf1 = p4 + t1 * (p3 - p4);
        esp{end+1} = [sup0; sup1; inf1; inf0]; %#ok<AGROW>
    end
end
end
