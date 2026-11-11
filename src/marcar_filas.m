function marcar_filas(nombre)
%MARCAR_FILAS Marca las filas de espacios de una imagen y las guarda en CSV.
%   marcar_filas('gf2_07') abre data/originales/gf2_07.jpg. Por cada fila de
%   espacios:
%     1) Clic en sus 4 esquinas, en este orden: superior izquierda, superior
%        derecha, inferior derecha, inferior izquierda. Las esquinas deben
%        caer sobre las líneas pintadas de los extremos de la fila.
%     2) Escriban en la ventana de comandos cuántos espacios tiene la fila.
%   Para terminar, presionen Enter sin hacer clic.
%   Resultado: data/espacios/<nombre>.csv (lo usa ocupacion.m).
I = imread(fullfile('data', 'originales', [nombre '.jpg']));
fig = figure('Name', ['Filas de espacios: ' nombre]);
imshow(I); hold on

filas = zeros(0, 10);
while true
    title('Clic: sup-izq, sup-der, inf-der, inf-izq de la fila  (Enter = terminar)');
    [x, y] = ginput(4);
    if numel(x) < 4, break; end
    plot([x; x(1)], [y; y(1)], 'y-', 'LineWidth', 2);
    n = input(sprintf('Fila %d: ¿cuántos espacios tiene? ', size(filas, 1) + 1));
    filas(end+1, :) = [size(filas, 1) + 1, reshape([x y]', 1, []), n]; %#ok<AGROW>
    esp = espacios_desde_filas(filas(end, 2:10));
    for e = 1:numel(esp)
        q = esp{e};
        plot(q([1:4 1], 1), q([1:4 1], 2), 'c-');
    end
end
close(fig);

if isempty(filas)
    disp('No se marcó ninguna fila.');
    return
end
carpeta = fullfile('data', 'espacios');
if ~exist(carpeta, 'dir'), mkdir(carpeta); end
T = array2table(filas, 'VariableNames', {'fila', 'x_sup_izq', 'y_sup_izq', 'x_sup_der', ...
    'y_sup_der', 'x_inf_der', 'y_inf_der', 'x_inf_izq', 'y_inf_izq', 'n_espacios'});
archivo = fullfile(carpeta, [nombre '.csv']);
writetable(T, archivo);
fprintf('Guardado %s (%d filas, %d espacios)\n', archivo, size(filas, 1), sum(filas(:, 10)));
end
