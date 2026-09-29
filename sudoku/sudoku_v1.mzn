include "globals.mzn";

% ============================================================
% Sudoku - Version 1
% Restricciones mediante all_different
% Estrategia de búsqueda: default
% ============================================================

% ------------------------------------------------------------
% PARAMETROS
% ------------------------------------------------------------

% Tablero inicial.
% 0 representa una celda vacía.
array[1..9, 1..9] of int: puzzle;


% ------------------------------------------------------------
% VARIABLES DE DECISION
% ------------------------------------------------------------

% x[i,j] representa el valor de la celda
% ubicada en la fila i y columna j.
%
% Cada celda puede tomar un valor entre 1 y 9.

array[1..9, 1..9] of var 1..9: x;


% ------------------------------------------------------------
% RESTRICCIONES
% ------------------------------------------------------------

% 1. RESPETAR LAS PISTAS DEL TABLERO
%
% Si una celda del tablero inicial contiene un valor
% diferente de 0, ese valor debe mantenerse.

constraint
    forall(i in 1..9, j in 1..9 where puzzle[i,j] != 0) (
        x[i,j] = puzzle[i,j]
    );


% 2. RESTRICCION DE FILAS
%
% Todos los valores de una misma fila deben ser diferentes.

constraint
    forall(i in 1..9) (
        all_different([
            x[i,j]
            | j in 1..9
        ])
    );


% 3. RESTRICCION DE COLUMNAS
%
% Todos los valores de una misma columna deben ser diferentes.

constraint
    forall(j in 1..9) (
        all_different([
            x[i,j]
            | i in 1..9
        ])
    );


% 4. RESTRICCION DE REGIONES 3x3
%
% El tablero está dividido en 9 regiones de 3x3.
% Los nueve valores de cada región deben ser diferentes.

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

% En V1 utilizamos la estrategia de búsqueda por defecto
% del solver.

solve satisfy;


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