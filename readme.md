# Taller 1 — Sudoku como CSP en MiniZinc

Modelado del Sudoku como problema de satisfacción de restricciones (CSP) en MiniZinc. Se comparan dos implementaciones de las restricciones (`all_different` frente a desigualdades binarias), varias estrategias de búsqueda, restricciones redundantes y rompimiento de simetrías. El informe está escrito en LaTeX.

## Contenido del repositorio

```text
csp-taller1-programacion-restricciones/
├── README.md
├── informe.tex                    # Informe en LaTeX (documento principal)
└── sudoku/
    ├── sudoku_v1.mzn              # all_different + búsqueda por defecto
    ├── sudoku_v2.mzn              # desigualdades binarias (!=)
    ├── sudoku_v3.mzn              # all_different + first_fail
    ├── sudoku_v4.mzn              # all_different + input_order
    ├── sudoku_v5.mzn              # V4 + restricciones redundantes de suma
    ├── sudoku_v6a.mzn             # sin rompimiento de simetrías
    ├── sudoku_v6a_final.mzn       # misma versión de V6A, comentarios reorganizados
    ├── sudoku_v6b.mzn             # V6A + lex_lesseq en filas 1-3
    ├── sudoku_v6b_final.mzn       # misma versión de V6B, comentarios reorganizados
    ├── sudoku_instancia1.dzn      # S1: Sudoku clásico
    ├── sudoku_instancia2.dzn      # S2: pocas pistas
    ├── sudoku_symmetry.dzn        # instancia de simetría (filas 1-3 vacías)
    └── sudoku_symmetry_v6.dzn     # misma instancia de simetría
```

| Modelo | Restricciones                  | Búsqueda                      | Instancia |
| ------ | ------------------------------ | ----------------------------- | --------- |
| V1     | `all_different`                | por defecto del solver        | S1 / S2   |
| V2     | `x[i,j] != x[i,k]` (binarias)  | por defecto del solver        | S1 / S2   |
| V3     | `all_different`                | `first_fail`, `indomain_min`  | S1 / S2   |
| V4     | `all_different`                | `input_order`, `indomain_min` | S1 / S2   |
| V5     | `all_different` + sumas = 45   | `input_order`, `indomain_min` | S1 / S2   |
| V6A    | `all_different`                | `input_order`, `indomain_min` | simetría  |
| V6B    | `all_different` + `lex_lesseq` | `input_order`, `indomain_min` | simetría  |

---

## 1. Instalar Git

Verifica si ya lo tienes instalado:

```bash
git --version
```

Si el comando no existe, instálalo según tu sistema operativo:

- **Windows:** descarga el instalador desde <https://git-scm.com/download/win> y ejecútalo con las opciones por defecto. Después usa **Git Bash** o la terminal de Windows.
- **macOS:** ejecuta `xcode-select --install` o, si usas Homebrew, `brew install git`.
- **Linux (Debian/Ubuntu):**
  ```bash
  sudo apt update
  sudo apt install git
  ```

## 2. Descargar el proyecto

**Opción A — Clonar con Git (recomendada):**

```bash
git clone https://github.com/maicolanders/csp-taller1-programacion-restricciones.git
cd csp-taller1-programacion-restricciones
```

Para traer cambios posteriores:

```bash
git pull
```

**Opción B — Descargar como ZIP:** en la página del repositorio en GitHub, ve a **Code → Download ZIP** y descomprime el archivo.

---

## 3. Instalar MiniZinc

1. Descarga el paquete **MiniZinc IDE (bundled)** desde <https://www.minizinc.org/software.html>. Ese paquete ya incluye el solver **Gecode**, que se usó en las pruebas.
2. Instálalo:
   - **Windows / macOS:** ejecuta el instalador.
   - **Linux:** descomprime el `.tgz` o usa la AppImage, y añade la carpeta `bin` al `PATH`.
3. Verifica la instalación:
   ```bash
   minizinc --version
   minizinc --solvers
   ```

## 4. Ejecutar los modelos

Todos los modelos leen el tablero desde un archivo `.dzn` (parámetro `puzzle`, donde `0` es una celda vacía). Por eso siempre se ejecuta un **modelo + una instancia**:

| Experimento                    | Modelos                            | Instancia                                                   |
| ------------------------------ | ---------------------------------- | ----------------------------------------------------------- |
| Implementaciones y estrategias | `sudoku_v1.mzn` … `sudoku_v5.mzn`  | `sudoku_instancia1.dzn` (S1) o `sudoku_instancia2.dzn` (S2) |
| Rompimiento de simetrías       | `sudoku_v6a.mzn`, `sudoku_v6b.mzn` | `sudoku_symmetry.dzn`                                       |

### Desde el MiniZinc IDE

1. **File → Open** y abre el modelo, por ejemplo `sudoku/sudoku_v1.mzn`, y la instancia, por ejemplo `sudoku/sudoku_instancia2.dzn`.
2. Con la pestaña del modelo activa, elige el solver **Gecode** en la barra superior.
3. Para ver nodos, fallos y propagaciones, abre la configuración del solver (**Show configuration editor**) y marca **Output solving statistics**.
4. Para V6A y V6B, marca también **User-defined behavior → Print all solutions**. Así se enumeran todas las soluciones.
5. Pulsa **Run**. En el cuadro que aparece, selecciona el archivo `.dzn` correspondiente.

### Desde la terminal

Ejecuta los comandos desde la raíz del repositorio.

Un modelo sobre una instancia, con estadísticas:

```bash
minizinc --solver gecode --statistics sudoku/sudoku_v1.mzn sudoku/sudoku_instancia2.dzn
```

V1 a V5 sobre S2 de una sola vez (Git Bash, macOS o Linux):

```bash
for v in v1 v2 v3 v4 v5; do
  echo "== $v =="
  minizinc --solver gecode --statistics sudoku/sudoku_$v.mzn sudoku/sudoku_instancia2.dzn
done
```

Para usar S1, cambia `sudoku_instancia2.dzn` por `sudoku_instancia1.dzn`.

Experimento de simetrías, enumerando todas las soluciones:

```bash
minizinc --solver gecode --statistics --all-solutions sudoku/sudoku_v6a.mzn sudoku/sudoku_symmetry.dzn
minizinc --solver gecode --statistics --all-solutions sudoku/sudoku_v6b.mzn sudoku/sudoku_symmetry.dzn
```

V6A debe reportar 144 soluciones y V6B, 24.

Las métricas que se reportan en el informe corresponden a estas estadísticas de la salida:

| Métrica del informe | Estadística de MiniZinc |
| ------------------- | ----------------------- |
| Restricciones       | `flatIntConstraints`    |
| Nodos               | `nodes`                 |
| Fallos              | `failures`              |
| Propagaciones       | `propagations`          |
| Tiempo de búsqueda  | `solveTime`             |

Los tiempos varían según el equipo. Los nodos, fallos y propagaciones deberían coincidir si usas la misma versión de Gecode.

---

## 5. Compilar el informe en Overleaf

El informe es un solo archivo, `informe.tex`, sin imágenes ni `.bib` externos.

1. Crea una cuenta o inicia sesión en <https://www.overleaf.com/>.
2. Crea el proyecto de una de estas formas:
   - **Proyecto en blanco (más simple):** ve a **New Project → Blank Project** y ponle un nombre. En el panel de archivos, pulsa **Upload** (icono de subir) y sube `informe.tex`. Si quieres, borra el `main.tex` que Overleaf crea por defecto.
   - **Desde el ZIP del repositorio:** descarga el ZIP desde GitHub (**Code → Download ZIP**). En Overleaf ve a **New Project → Upload Project** y selecciona ese `.zip`. Los archivos `.mzn` también se subirán, pero no afectan la compilación.
   - **Importar desde GitHub:** ve a **New Project → Import from GitHub**. Esta opción requiere vincular tu cuenta de GitHub y puede depender del plan de Overleaf.
3. Abre **Menu** (arriba a la izquierda) y revisa estas opciones:
   - **Compiler:** `pdfLaTeX`.
   - **Main document:** `informe.tex`.
4. Pulsa **Recompile** y el PDF aparecerá en el panel derecho. Para descargarlo, usa el icono de descarga junto a **Recompile**.

**Problemas comunes**

- **`Undefined control sequence` en `\section` o `Missing \begin{document}`:** el documento principal no tiene preámbulo. Verifica que **Main document** sea `informe.tex` y no otro archivo.
- **Citas que aparecen como `[?]`:** recompila una segunda vez, porque las referencias necesitan dos pasadas.
- **Aviso sobre `output.pdf`:** si el proyecto contiene un archivo con ese nombre, renómbralo o elimínalo.

### Compilar localmente (opcional)

Con una distribución de LaTeX instalada (TeX Live, MiKTeX o MacTeX), desde la raíz del repositorio:

```bash
pdflatex informe.tex
pdflatex informe.tex
```
