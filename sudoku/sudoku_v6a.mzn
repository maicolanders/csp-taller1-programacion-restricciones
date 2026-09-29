include "globals.mzn";

% =========================================================
% VARIABLES
% =========================================================

array[1..9, 1..9] of int: puzzle;

array[1..9, 1..9] of var 1..9: x;


% =========================================================
% PISTAS DEL SUDOKU
% =========================================================

constraint
    forall(i, j in 1..9 where puzzle[i,j] != 0)(
        x[i,j] = puzzle[i,j]
    );


% =========================================================
% RESTRICCIONES DE SUDOKU
% =========================================================

% Filas
constraint
    forall(i in 1..9)(
        all_different([x[i,j] | j in 1..9])
    );

% Columnas
constraint
    forall(j in 1..9)(
        all_different([x[i,j] | i in 1..9])
    );

% Regiones 3x3
constraint
    forall(br, bc in 0..2)(
        all_different([
            x[br*3 + r, bc*3 + c]
            | r, c in 1..3
        ])
    );


% =========================================================
% ESTRATEGIA DE BÚSQUEDA
% =========================================================

solve :: int_search(
    [x[i,j] | i,j in 1..9],
    input_order,
    indomain_min,
    complete
) satisfy;


% =========================================================
% SALIDA
% =========================================================

output [
    show(x[i,j]) ++
    if j = 9 then "\n" else " " endif
    | i,j in 1..9
];