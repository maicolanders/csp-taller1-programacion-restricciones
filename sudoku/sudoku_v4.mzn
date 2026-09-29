include "globals.mzn";

% ============================================================
% Sudoku - Version 4
% Restricciones: all_different
% Búsqueda: input_order + indomain_min
% ============================================================


% ------------------------------------------------------------
% PARAMETRO
% ------------------------------------------------------------

% Tablero inicial.
% 0 representa una celda vacía.

array[1..9, 1..9] of int: puzzle;


% ------------------------------------------------------------
% VARIABLES DE DECISION
% ------------------------------------------------------------

% x[i,j] representa el valor de la celda
% ubicada en la fila i y columna j.

array[1..9, 1..9] of var 1..9: x;


% ------------------------------------------------------------
% RESTRICCIONES
% ------------------------------------------------------------

% 1. PISTAS INICIALES

constraint
    forall(i in 1..9, j in 1..9 where puzzle[i,j] != 0) (
        x[i,j] = puzzle[i,j]
    );


% 2. FILAS

constraint
    forall(i in 1..9) (
        all_different([
            x[i,j]
            | j in 1..9
        ])
    );


% 3. COLUMNAS

constraint
    forall(j in 1..9) (
        all_different([
            x[i,j]
            | i in 1..9
        ])
    );


% 4. REGIONES 3x3

constraint
    forall(br in 0..2, bc in 0..2) (
        all_different([
            x[br * 3 + r, bc * 3 + c]
            | r in 1..3, c in 1..3
        ])
    );


% ------------------------------------------------------------
% BUSQUEDA
% ------------------------------------------------------------

% Selecciona las variables en el orden en que aparecen
% en la lista [x[i,j] | i,j in 1..9].

solve :: int_search(
    [x[i,j] | i,j in 1..9],
    input_order,
    indomain_min,
    complete
) satisfy;


% ------------------------------------------------------------
% SALIDA
% ------------------------------------------------------------

output [
    if j = 9 then
        show(x[i,j]) ++ "\n"
    else
        show(x[i,j]) ++ " "
    endif
    | i in 1..9, j in 1..9
];