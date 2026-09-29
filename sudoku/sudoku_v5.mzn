include "globals.mzn";

% ============================================================
% Sudoku - Version 5
% all_different + restricciones redundantes de suma
% Búsqueda: input_order + indomain_min
% ============================================================

array[1..9, 1..9] of int: puzzle;

array[1..9, 1..9] of var 1..9: x;


% ------------------------------------------------------------
% PISTAS
% ------------------------------------------------------------

constraint
    forall(i in 1..9, j in 1..9 where puzzle[i,j] != 0) (
        x[i,j] = puzzle[i,j]
    );


% ------------------------------------------------------------
% FILAS
% ------------------------------------------------------------

constraint
    forall(i in 1..9) (
        all_different([
            x[i,j]
            | j in 1..9
        ])
    );


% ------------------------------------------------------------
% COLUMNAS
% ------------------------------------------------------------

constraint
    forall(j in 1..9) (
        all_different([
            x[i,j]
            | i in 1..9
        ])
    );


% ------------------------------------------------------------
% REGIONES 3x3
% ------------------------------------------------------------

constraint
    forall(br in 0..2, bc in 0..2) (
        all_different([
            x[br * 3 + r, bc * 3 + c]
            | r in 1..3, c in 1..3
        ])
    );


% ------------------------------------------------------------
% RESTRICCIONES REDUNDANTES
% ------------------------------------------------------------

% Cada fila contiene exactamente los valores 1..9.
% Por tanto, su suma debe ser 45.

constraint
    forall(i in 1..9) (
        sum(j in 1..9)(x[i,j]) = 45
    );


% Cada columna contiene exactamente los valores 1..9.

constraint
    forall(j in 1..9) (
        sum(i in 1..9)(x[i,j]) = 45
    );


% Cada region 3x3 contiene exactamente los valores 1..9.

constraint
    forall(br in 0..2, bc in 0..2) (
        sum(r in 1..3, c in 1..3)(
            x[br * 3 + r, bc * 3 + c]
        ) = 45
    );


% ------------------------------------------------------------
% BUSQUEDA
% ------------------------------------------------------------

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