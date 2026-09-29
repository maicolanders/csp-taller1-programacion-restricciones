include "globals.mzn";

% ============================================================
% Sudoku - Version 2
% Restricciones mediante desigualdades !=
% Estrategia de búsqueda: default
% ============================================================

% ------------------------------------------------------------
% PARAMETRO
% ------------------------------------------------------------

% Tablero inicial.
% 0 representa una celda vacia.

array[1..9, 1..9] of int: puzzle;


% ------------------------------------------------------------
% VARIABLES DE DECISION
% ------------------------------------------------------------

% x[i,j] representa el valor de la celda
% ubicada en la fila i, columna j.

array[1..9, 1..9] of var 1..9: x;


% ------------------------------------------------------------
% RESTRICCIONES
% ------------------------------------------------------------

% 1. RESPETAR LAS PISTAS INICIALES

constraint
    forall(i in 1..9, j in 1..9 where puzzle[i,j] != 0) (
        x[i,j] = puzzle[i,j]
    );


% ------------------------------------------------------------
% 2. RESTRICCIONES DE FILAS
% ------------------------------------------------------------

% Todas las parejas de celdas de una misma fila
% deben contener valores diferentes.

constraint
    forall(i in 1..9, j1, j2 in 1..9 where j1 < j2) (
        x[i,j1] != x[i,j2]
    );


% ------------------------------------------------------------
% 3. RESTRICCIONES DE COLUMNAS
% ------------------------------------------------------------

% Todas las parejas de celdas de una misma columna
% deben contener valores diferentes.

constraint
    forall(j in 1..9, i1, i2 in 1..9 where i1 < i2) (
        x[i1,j] != x[i2,j]
    );


% ------------------------------------------------------------
% 4. RESTRICCIONES DE REGIONES 3x3
% ------------------------------------------------------------

% Todas las parejas de celdas pertenecientes
% a una misma region 3x3 deben ser diferentes.

constraint
    forall(br in 0..2, bc in 0..2) (
        forall(r1, c1, r2, c2 in 1..3
               where r1 < r2 \/
                     (r1 = r2 /\ c1 < c2)) (
            x[br * 3 + r1, bc * 3 + c1]
            !=
            x[br * 3 + r2, bc * 3 + c2]
        )
    );


% ------------------------------------------------------------
% BUSQUEDA
% ------------------------------------------------------------

% Igual que V1: estrategia de búsqueda por defecto.

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