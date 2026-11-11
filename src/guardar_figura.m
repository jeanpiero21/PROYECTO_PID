function guardar_figura(fig, archivo)
%GUARDAR_FIGURA Guarda una figura como imagen y la cierra.
%   Usa exportgraphics (R2020a o más nuevo); si no existe, usa saveas.
if exist('exportgraphics', 'file')
    exportgraphics(fig, archivo, 'Resolution', 150);
else
    saveas(fig, archivo);
end
close(fig);
end
