# Configuración de Neovim

Configuración personal de Neovim basada en
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), separada en
módulos y con los plugins gestionados por `vim.pack`, el gestor que viene con
Neovim. Requiere **Neovim 0.12 o más nuevo**.

Está pensada para programar en C/C++, Java, Python (con ejecución de celdas
contra un kernel de Jupyter vía Molten), JavaScript/TypeScript, Lua y shell, y
para escribir en LaTeX y Markdown.

## Índice

- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Estructura](#estructura)
- [Atajos generales](#atajos-generales)
- [Lenguajes](#lenguajes)
- [Formateo y linting](#formateo-y-linting)
- [Mantenimiento](#mantenimiento)

## Requisitos

En Arch Linux:

```sh
# Base
sudo pacman -S --needed neovim git make gcc unzip ripgrep fd tree-sitter-cli wl-clipboard xdg-utils nodejs npm python

# C/C++ y Java
sudo pacman -S --needed cmake gdb jdk-openjdk

# LaTeX, PDF y diagramas (texlive-meta no incluye los paquetes de idioma)
sudo pacman -S --needed texlive-meta texlive-langspanish texlive-langenglish biber zathura zathura-pdf-mupdf plantuml
```

- Una [Nerd Font](https://www.nerdfonts.com/) configurada en la terminal (por
  ejemplo `ttf-jetbrains-mono-nerd`). Si no usás una, poné
  `vim.g.have_nerd_font = false` en `lua/options.lua`.
- En X11 se usa `xclip` en lugar de `wl-clipboard`.
- Node puede venir de `nvm` en lugar de pacman, pero `node` y `npm` tienen que
  estar en el `PATH` del proceso que lanza Neovim: varias herramientas de Mason
  los necesitan para instalarse y para correr.
- Opcional: `jq`, para consultar las respuestas JSON en los archivos `.http`.
- Opcional: `ueberzugpp` e `imagemagick` para ver imágenes dentro de Neovim
  (ver [Python y Molten](#python-y-molten)).

Los servidores LSP, formateadores, linters y depuradores se instalan solos con
[Mason](https://github.com/mason-org/mason.nvim) la primera vez que se abre
Neovim (`:Mason` muestra su estado).

## Instalación

```sh
git clone https://github.com/alFigueredo/nvim-config.git ~/.config/nvim
```

Antes del primer arranque, creá el entorno de Python que usa Molten. Arch no
permite instalar paquetes con `pip` en el Python del sistema, por eso va en un
venv propio:

```sh
python -m venv ~/.local/share/nvim/python-venv
~/.local/share/nvim/python-venv/bin/pip install pynvim jupyter_client nbformat pillow ipykernel
```

`ipykernel` es el kernel `python3` que usa Molten en los proyectos sin venv
propio.

Después abrí `nvim`: `vim.pack` pide confirmación, descarga los plugins,
compila los que lo necesitan y registra el plugin remoto de Molten
(`:UpdateRemotePlugins`). Mason instala sus herramientas en segundo plano.
Conviene reiniciar Neovim una vez que termine.

Para comprobar que todo esté bien: `:checkhealth`.

## Estructura

```
init.lua                  carga options, keymaps, pack y plugins, en ese orden
lua/options.lua           opciones del editor (leader = <Space>)
lua/keymaps.lua           atajos generales y configuración de diagnósticos
lua/pack.lua              pasos de compilación tras instalar/actualizar plugins
lua/plugins.lua           lista de módulos de plugins que se cargan
lua/kickstart/plugins/    un archivo por plugin
lua/kickstart/health.lua  chequeos de `:checkhealth kickstart`
ftplugin/                 ajustes por tipo de archivo (cmake, tsv, tex, markdown, http)
nvim-pack-lock.json       versión exacta de cada plugin (lo escribe vim.pack)
```

Para desactivar un plugin, comentá su `require` en `lua/plugins.lua`. Sigue
instalado y en el lockfile hasta que se lo borra (ver
[Mantenimiento](#mantenimiento)).

## Atajos generales

`<leader>` y `<localleader>` son la barra espaciadora. `<leader>` solo, con
una pausa, muestra los atajos disponibles (which-key), y `<leader>sk` permite
buscarlos.

| Atajo                       | Acción                                                                       |
| :-------------------------- | :--------------------------------------------------------------------------- |
| `<leader>sf` / `<leader>sg` | Buscar archivos / buscar texto en el proyecto                                |
| `<leader>sF`                | Buscar archivos, incluidos los ocultos y los ignorados por git               |
| `<leader>sw`                | Buscar la palabra bajo el cursor                                             |
| `<leader>/`                 | Buscar en el buffer actual                                                   |
| `<leader>sr`                | Retomar la última búsqueda                                                   |
| `<leader><leader>`          | Buffers abiertos                                                             |
| `<leader>s.`                | Archivos recientes                                                           |
| `<leader>sd`                | Diagnósticos                                                                 |
| `<leader>sh`                | Ayuda de Neovim                                                              |
| `<leader>sn`                | Archivos de esta configuración                                               |
| `-`                         | Explorador de archivos (Oil)                                                 |
| `<C-h>` / `<C-l>`           | Buffer anterior / siguiente                                                  |
| `<C-x>`                     | Cerrar buffer                                                                |
| `<leader>f`                 | Formatear buffer o selección                                                 |
| `<leader>tc`                | Mostrar/ocultar el contexto fijo arriba                                      |
| `<leader>q`                 | Lista de diagnósticos                                                        |
| `[d` / `]d`                 | Diagnóstico anterior / siguiente                                             |
| `sa` / `sd` / `sr`          | Agregar / borrar / reemplazar lo que rodea al texto (`saiw)`, `sd'`, `sr)'`) |
| `<Esc><Esc>`                | Salir del modo terminal                                                      |

[hardtime.nvim](https://github.com/m4xshen/hardtime.nvim) obliga a usar
movimientos más eficientes: bloquea `hjkl` y otras teclas cuando se repiten
más de 3 veces en un segundo y sugiere una alternativa. También desactiva las
flechas (en modo normal, visual e inserción) y el mouse. `:Hardtime toggle` lo
apaga y lo prende.

### LSP

| Atajo        | Acción                              |
| :----------- | :---------------------------------- |
| `grd`        | Ir a la definición                  |
| `grD`        | Ir a la declaración                 |
| `grr`        | Referencias                         |
| `gri`        | Implementaciones                    |
| `grt`        | Definición del tipo                 |
| `grn`        | Renombrar                           |
| `gra`        | Acciones de código                  |
| `gO` / `gW`  | Símbolos del archivo / del proyecto |
| `K`          | Documentación                       |
| `<leader>th` | Mostrar/ocultar inlay hints         |

### Autocompletado y snippets

Los snippets de [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
aparecen en el menú de autocompletado junto con las sugerencias del LSP. En
Markdown y LaTeX también se ofrecen las palabras ya escritas en los buffers
abiertos.

| Atajo               | Acción                                      |
| :------------------ | :------------------------------------------ |
| `<C-n>` / `<C-p>`   | Sugerencia siguiente / anterior             |
| `<C-y>`             | Aceptar la sugerencia o expandir el snippet |
| `<Tab>` / `<S-Tab>` | Campo siguiente / anterior del snippet      |
| `<C-space>`         | Abrir el menú o la documentación            |
| `<C-e>`             | Cerrar el menú                              |

### Git (gitsigns)

| Atajo                       | Acción                              |
| :-------------------------- | :---------------------------------- |
| `]c` / `[c`                 | Cambio siguiente / anterior         |
| `<leader>hp`                | Ver el cambio                       |
| `<leader>hs` / `<leader>hr` | Stage / descartar el cambio         |
| `<leader>hb`                | Blame de la línea                   |
| `<leader>hd`                | Diff contra el índice               |
| `<leader>tb`                | Blame permanente en la línea actual |

### Depuración (nvim-dap)

| Atajo                                      | Acción                          |
| :----------------------------------------- | :------------------------------ |
| `<leader>db`                               | Breakpoint                      |
| `<leader>dB`                               | Breakpoint condicional          |
| `<leader>dc`                               | Iniciar / continuar             |
| `<leader>di` / `<leader>do` / `<leader>dO` | Step into / over / out          |
| `<leader>dl`                               | Repetir la última configuración |
| `<leader>dt`                               | Mostrar/ocultar la interfaz     |

La interfaz de depuración se abre sola cuando la ejecución se detiene (en un
breakpoint, un paso o una excepción) y se cierra al terminar.

## Lenguajes

### C y C++

- **LSP:** clangd, con los chequeos de clang-tidy activados y sin agregar
  `#include` automáticamente al completar. Sin un `.clang-tidy` en el proyecto
  clangd aplica solo un conjunto mínimo de chequeos; con uno, los que ese
  archivo indique.
- **Base de compilación:** clangd necesita `compile_commands.json` y lo busca
  solo en `build/`. `<leader>cg` lo genera ahí; a mano sería:

  ```sh
  cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  ```

- **Header ↔ fuente:** `grh` salta entre el `.cpp` y su `.h`.
- **Formateo:** clang-format al guardar. Usa el `.clang-format` del proyecto si
  existe. CMake se formatea con gersemi.
- **Depuración:** cpptools con gdb. En un proyecto CMake, `<leader>cd` compila
  y depura el target elegido. Fuera de CMake, `<leader>dc` lanza el programa,
  con o sin argumentos, o se conecta a un `gdbserver` en `localhost:1234`. El
  ejecutable tiene que estar compilado con símbolos de depuración (`-g`, o el
  tipo de build Debug en CMake).

#### CMake

[cmake-tools.nvim](https://github.com/Civitasv/cmake-tools.nvim) configura,
compila, ejecuta y depura el proyecto desde Neovim. Todo se construye en
`build/`.

| Atajo        | Acción                                                          |
| :----------- | :-------------------------------------------------------------- |
| `<leader>cg` | Configurar (`:CMakeGenerate!` limpia el build y la caché antes) |
| `<leader>cb` | Compilar                                                        |
| `<leader>cr` | Compilar y ejecutar                                             |
| `<leader>cd` | Compilar y depurar                                              |
| `<leader>ct` | Elegir el tipo de build (Debug, Release, …)                     |
| `<leader>cl` | Elegir el ejecutable a lanzar                                   |
| `<leader>ca` | Argumentos del ejecutable                                       |
| `<leader>cs` | Detener la compilación o la ejecución                           |

- La primera vez pregunta el tipo de build y el ejecutable, y los recuerda por
  proyecto.
- La salida de la compilación va al quickfix, que se cierra solo si no hubo
  errores. `:cnext` / `:cprev` saltan entre los errores.
- El programa corre en una terminal abajo.
- Al guardar un `CMakeLists.txt` se vuelve a configurar el proyecto.
- `:CMakeRunTest` corre los tests de CTest.

### Java

jdtls se inicia con [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls),
con un workspace por proyecto en `~/.cache/nvim/jdtls/workspace/`. El proyecto
se detecta por `pom.xml`, `build.gradle`, `gradlew`, `mvnw` o `.git`.

| Atajo                       | Acción                                           |
| :-------------------------- | :----------------------------------------------- |
| `<leader>jo`                | Organizar imports                                |
| `<leader>jv` / `<leader>jc` | Extraer variable / constante (también en visual) |
| `<leader>jm`                | Extraer método (en visual)                       |
| `<leader>jt`                | Ejecutar los tests de la clase                   |
| `<leader>jn`                | Ejecutar el test más cercano                     |
| `<leader>jp`                | Elegir un test                                   |
| `<leader>ju`                | Recargar la configuración del proyecto           |

- **Depuración:** `<leader>dc` muestra las clases `main` del proyecto. Los
  cambios se aplican en caliente (hot code replace).
- **Linting:** checkstyle, solo en proyectos que traen sus reglas en
  `checkstyle.xml` o `config/checkstyle/checkstyle.xml`.
- **Formateo:** google-java-format, solo manual con `<leader>f`.
- **Lombok:** jdtls arranca con el agente de Lombok que instala Mason, así que
  reconoce el código que generan sus anotaciones.

### Python y Molten

- **LSP:** pyright. **Linting:** ruff. **Formateo:** ruff al guardar.
- **Depuración:** debugpy.
- pyright, debugpy y Molten usan el venv activo (`$VIRTUAL_ENV`) o el
  `.venv`/`venv` de la raíz del proyecto, sin necesidad de activarlo.
- **Molten** ejecuta código de un archivo `.py` en un kernel de Jupyter y
  muestra el resultado debajo de cada celda. No abre notebooks `.ipynb`.

| Atajo        | Acción                                                       |
| :----------- | :----------------------------------------------------------- |
| `<leader>mi` | Iniciar con el venv del proyecto                             |
| `<leader>mI` | Iniciar eligiendo el kernel                                  |
| `<leader>ml` | Evaluar la línea                                             |
| `<leader>me` | Evaluar un movimiento (`<leader>meip`) o la selección visual |
| `<leader>mr` | Reevaluar la celda                                           |
| `<leader>ms` | Entrar a la salida                                           |
| `<leader>mh` | Ocultar la salida                                            |
| `<leader>md` | Borrar la celda                                              |
| `<leader>mp` | Abrir la imagen de la salida en un visor externo             |

`<leader>mi` registra el venv del proyecto como kernel de Jupyter la primera
vez. Ese venv necesita `ipykernel`:

```sh
.venv/bin/python -m pip install ipykernel   # o: uv add --dev ipykernel
```

Si el proyecto no tiene venv, se usa el kernel `python3` del venv de Neovim
(ver [Instalación](#instalación)).

Los gráficos se dibujan dentro de Neovim con `ueberzugpp`, que no funciona en
KDE Plasma con Wayland. Ahí se abren con `<leader>mp`.

### JavaScript y TypeScript

- **LSP:** ts_ls (typescript-language-server), también en JSX y TSX.
- **Linting:** eslint_d, solo en proyectos con configuración de ESLint
  (`eslint.config.*` o `.eslintrc*`). Usa el ESLint instalado en el proyecto.
- **Formateo:** prettierd al guardar, igual que en HTML y CSS.
- [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) cierra y
  renombra las etiquetas en HTML, JSX y TSX.

### LaTeX

[vimtex](https://github.com/lervag/vimtex) compila y abre el PDF;
[texlab](https://github.com/latex-lsp/texlab) aporta el autocompletado de
`\ref`, `\cite` y comandos, y los diagnósticos.

| Atajo        | Acción                                               |
| :----------- | :--------------------------------------------------- |
| `<leader>ll` | Compilar de forma continua (se recompila al guardar) |
| `<leader>lv` | Abrir el PDF en la posición del cursor               |
| `<leader>le` | Errores y advertencias de la compilación             |
| `<leader>lc` | Borrar archivos auxiliares                           |
| `<leader>lt` | Índice del documento                                 |

- Compila con latexmk y biber. Los auxiliares (`.aux`, `.log`, `.bbl`, …) van a
  `build/`; el PDF queda junto al `.tex`.
- El visor es zathura. Ctrl+clic en el PDF salta a la línea correspondiente
  del `.tex`. En X11 con `xdotool` se usa la integración completa de vimtex; en
  Wayland, la simple.
- texlab corre [ChkTeX](https://www.nongnu.org/chktex/) al abrir y al guardar,
  con avisos tipográficos (falta `~` antes de `\ref`, guiones, comillas). Los
  que no interesen se silencian con un `.chktexrc` en el proyecto o en `~`.

#### Snippets matemáticos

[luasnip-latex-snippets](https://github.com/iurimateus/luasnip-latex-snippets.nvim)
expande estos atajos mientras se escribe, sin pasar por el menú. Los dos
primeros funcionan en el texto; el resto, solo dentro de una zona matemática.

| Se escribe                    | Resultado                            |
| :---------------------------- | :----------------------------------- |
| `mk` / `dm`                   | `\( \)` / `\[ \]`                    |
| `beg` (al inicio de la línea) | `\begin{} … \end{}`                  |
| `//`                          | `\frac{}{}`                          |
| `x2`                          | `x_{2}`                              |
| `sr` / `cb`                   | `^2` / `^3`                          |
| `xhat` / `xbar`               | `\hat{x}` / `\overline{x}`           |
| `<=` / `>=` / `!=`            | `\le` / `\ge` / `\neq`               |
| `=>` / `ooo` / `RR`           | `\implies` / `\infty` / `\mathbb{R}` |

`<Tab>` salta al campo siguiente. Solo funcionan en archivos `.tex`.

### Markdown

- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
  muestra títulos, listas, tablas y bloques de código con formato mientras se
  edita. La línea del cursor se ve como texto plano.
- Formateo con prettierd al guardar.

### Corrector ortográfico

En LaTeX y Markdown el corrector está activo en español e inglés, y las líneas
largas se cortan entre palabras.

| Atajo       | Acción                                     |
| :---------- | :----------------------------------------- |
| `]s` / `[s` | Error siguiente / anterior                 |
| `z=`        | Sugerencias                                |
| `zg`        | Agregar la palabra al diccionario personal |
| `zw`        | Marcar la palabra como incorrecta          |

Neovim ofrece descargar el diccionario de un idioma la primera vez que hace
falta.

### Otros

- **Lua:** lua_ls y stylua al guardar.
- **Shell:** en `sh` y `bash`, bashls con los diagnósticos y arreglos rápidos
  de shellcheck (lo instala Mason), y shfmt al guardar, con la indentación del
  buffer. En zsh solo hay formateo, y shfmt no entiende toda su sintaxis: si el
  archivo usa algo que no reconoce, queda sin formatear.
- **CMake:** neocmakelsp y gersemi.
- **PlantUML:** los `.puml` generan un `.png` al guardar. `<leader>pr` (o
  `:RenderUML`) lo genera y lo abre.
- **HTTP:** los `.http` se ejecutan con
  [resty.nvim](https://github.com/lima1909/resty.nvim): `<leader>rr` ejecuta
  la petición bajo el cursor y `<leader>rl` repite la última. Se formatean con
  kulala-fmt.

## Formateo y linting

[conform.nvim](https://github.com/stevearc/conform.nvim) formatea al guardar
con el formateador de cada lenguaje (ver [Lenguajes](#lenguajes)). JSON y YAML
(prettierd) y Java quedan fuera y se formatean a mano con `<leader>f`. Los
tipos de archivo habilitados están en `lua/kickstart/plugins/conform.lua`.

[nvim-lint](https://github.com/mfussenegger/nvim-lint) revisa el buffer al
abrirlo, al guardar y al salir del modo inserción. Además de los linters de
cada lenguaje, editorconfig-checker corre en todos los archivos.

### Indentación

Los archivos nuevos o sin indentar usan 2 espacios en todos los lenguajes
(`lua/options.lua`). Los archivos existentes conservan la suya, tabs o
espacios, y el `.editorconfig` del proyecto manda sobre todo lo demás.

Las excepciones son los lenguajes con estilo propio: Python, Rust y Markdown
usan 4 espacios y Go y los Makefile usan tabs (lo define Neovim), CMake usa 4
espacios porque así formatea gersemi, y en los TSV el tabulador es un tab real.
Para agregar otra, creá un `ftplugin/<lenguaje>.lua`.

## Mantenimiento

| Tarea                               | Cómo                                                                                    |
| :---------------------------------- | :-------------------------------------------------------------------------------------- |
| Actualizar plugins                  | `:lua vim.pack.update()`. `:write` aplica los cambios y `:quit` los cancela             |
| Ver el estado de los plugins        | `:lua vim.pack.update(nil, { offline = true })`                                         |
| Volver a las versiones del lockfile | `:lua vim.pack.update(nil, { target = 'lockfile' })`                                    |
| Borrar un plugin                    | Quitar su `require` de `lua/plugins.lua`, reiniciar y `:lua vim.pack.del({ 'nombre' })` |
| Actualizar LSP y herramientas       | `:MasonToolsUpdate`                                                                     |
| Actualizar parsers de treesitter    | `:TSUpdate`                                                                             |
| Revisar problemas                   | `:checkhealth`                                                                          |

`nvim-pack-lock.json` está versionado: después de actualizar plugins,
commiteá el lockfile. En otra máquina que ya tenía los plugins, después de un
`git pull` reiniciá Neovim y volvé a las versiones del lockfile con el comando
de la tabla.

## Licencia

MIT, como kickstart.nvim. Ver [LICENSE.md](LICENSE.md).
