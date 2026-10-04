# Project2_2530_Disdi

Juego gráfico descrito en **VHDL** para FPGA, con generación de video VGA y entrada de teclado mediante señales PS/2. Integra movimiento del jugador, tres enemigos, disparos, colisiones, vidas y sprites.

La entidad superior es [Game](code/Game.vhd). El proyecto combina máquinas de estados y lógica de renderizado; no es un juego de escritorio ni requiere un motor de videojuegos.

## Funcionalidades implementadas

- Área visible de **800 × 600 píxeles**, según las constantes actuales.
- Color RGB de **12 bits**: cuatro bits por componente.
- Jugador con movimiento y selección de orientación.
- Tres instancias de enemigos con movimiento y disparos.
- Controlador de diez posiciones de disparos del jugador.
- Detección de colisiones mediante las estructuras de posición de los objetos.
- Control de vida parametrizado: `N_LIVES = 5` para el jugador y `N_LIVES = 4` para cada enemigo; hay una limitación de ancho en la salida de vida de los enemigos.
- Pantalla de inicio, fondo y visualización de vida mediante datos gráficos.
- Inicio de la partida a partir de la señal de disparo.

Estas características describen los módulos del código. La compatibilidad del teclado, temporización del monitor y funcionamiento completo en una placa deben verificarse; véase la sección de limitaciones.

## Estructura del repositorio

```text
code/
├── Game.vhd              # Integración del juego
├── BasicPackage.vhd      # Tipos, objetos y funciones comunes
├── vgaPackage.vhd        # Colores y temporización de video
├── ImagePackage.vhd      # Datos gráficos integrados en VHDL
├── ControladorVGA.vhd    # Integración de sincronización y renderizado
├── ImageSync.vhd         # Contadores, coordenadas y sincronismos
├── PixelGenerate.vhd     # Selección del color de cada píxel
├── SpriteRotator.vhd     # Orientación de gráficos
├── RotSelector.vhd       # Selección de orientación según movimiento
├── PlayerMove.vhd        # Movimiento del jugador
├── EnemyFsm.vhd          # Control de cada enemigo
├── EnemyMove.vhd         # Movimiento de enemigos
├── ShotCtrl.vhd          # Banco de disparos del jugador
├── ShotFsm.vhd           # Estado y movimiento de un disparo
├── EnemyShot.vhd         # Módulo auxiliar no instanciado por Game
├── lifeCtrl.vhd          # Vidas y señal de fin
├── mando.vhd             # Captura y decodificación del control
├── teclado.vhd           # Máquina de estados de recepción
├── my_dff.vhd            # Registro auxiliar
├── GralLimCounter.vhd    # Contador parametrizable
└── TestProtocol.vhd      # Banco de pruebas completamente comentado
matlab/
├── Bmp2Vhdl.mlx          # Live Script para trabajar con BMP y VHDL
├── Background.bmp
├── start.bmp
└── health_point_0.bmp … health_point_5.bmp
```

## Arquitectura

| Subsistema | Módulos principales | Responsabilidad |
| --- | --- | --- |
| Integración | `Game`, `BasicPackage` | Conectar objetos, colisiones, disparos y estado de partida |
| Entrada | `mando`, `teclado`, `my_dff` | Capturar datos del teclado y generar señales de dirección/disparo |
| Movimiento | `PlayerMove`, `EnemyFsm`, `EnemyMove` | Actualizar posiciones y decisiones de enemigos |
| Disparos | `ShotCtrl`, `ShotFsm` | Mantener el banco del jugador y los disparos enemigos |
| Vida | `lifeCtrl` | Descontar vidas y señalar fin de vida |
| Video | `ControladorVGA`, `ImageSync`, `PixelGenerate` | Generar sincronismos y el color de cada píxel |
| Gráficos | `ImagePackage`, `SpriteRotator`, `RotSelector` | Almacenar y orientar sprites |
| Temporización | `GralLimCounter` | Generar contadores y pulsos de actualización |

`Game` contiene tres `EnemyFsm` y tres `ShotFsm` para los disparos enemigos. `ShotCtrl` administra diez `ShotFsm` del jugador. El módulo separado `EnemyShot.vhd` no participa en esta integración.

## Interfaz de Game

| Puerto | Dirección | Tipo | Función |
| --- | --- | --- | --- |
| `clk` | Entrada | `uint01` | Reloj de la integración y generación de video |
| `reset` | Entrada | `uint01` | Reset externo **activo en bajo** |
| `ps2_clk` | Entrada | `uint01` | Señal de reloj del teclado |
| `ps2_data` | Entrada | `uint01` | Señal de datos del teclado |
| `enemyShot` | Salida | `uint01` | Señal de disparo del primer enemigo (`en1_trg`) |
| `RGB` | Salida | `ColorT` | Registro con R, G y B de cuatro bits |
| `VGA_ctrl` | Salida | `vgaCtrlT` | Registro con `HSync` y `VSync` |

[BasicPackage.vhd](code/BasicPackage.vhd) define los tipos básicos. [vgaPackage.vhd](code/vgaPackage.vhd) define los registros de video.

El reset externo se invierte mediante `rst_sign <= NOT reset`; los módulos internos reciben el reset activo en alto. No confundir la polaridad del puerto superior con la de sus componentes.

Los registros de salida requieren una asignación compatible con la herramienta de síntesis, o un wrapper que exponga sus campos como puertos físicos separados.

## Controles: intención y código actual

Los comentarios de [mando.vhd](code/mando.vhd) identifican W/A/S/D y espacio, pero la implementación compara **estos bytes concretos**:

| Acción | Etiqueta en los comentarios | Byte comparado |
| --- | --- | --- |
| Arriba | W | `0x3A` |
| Izquierda | A | `0x38` |
| Abajo | S | `0x36` |
| Derecha | D | `0x46` |
| Disparo / inicio | Espacio | `0x52` |

Estos valores no deben interpretarse como una garantía de correspondencia con las teclas de un teclado PS/2 estándar. La lógica conmuta señales mediante bloqueos y trata `0xE0` como un indicador que precede a su desactivación. Deben validarse la captura de bits y las secuencias reales de pulsación/liberación antes de afirmar que los controles funcionan como indican los comentarios.

En `Game`, la señal de disparo activa `startGame`; los pulsos de movimiento y disparo se habilitan a partir de ese estado.

## Video y reloj

Las constantes de [vgaPackage.vhd](code/vgaPackage.vhd) y los contadores de [ImageSync.vhd](code/ImageSync.vhd) establecen:

| Parámetro | Horizontal | Vertical |
| --- | --- | --- |
| Zona visible | 800 píxeles | 600 líneas |
| Front porch | 16 | 1 |
| Pulso de sincronismo | 80 | 2 |
| Back porch | 160 | 21 |
| Conteo completo, incluidos intervalos no visibles | 1056 ciclos | 624 líneas |

Los límites de los contadores son inclusivos: `HTime.FullScan = 1055` y `VTime.FullScan = 623`. Por tanto, la frecuencia de cuadro depende del reloj efectivo:

```text
frecuencia_de_cuadro = frecuencia_clk / (1056 × 624)
```

No se incluye una PLL ni un archivo de restricciones de reloj. No debe suponerse una frecuencia fija o la compatibilidad automática con cualquier monitor.

Los pulsos de movimiento, disparo y vida también dependen de contadores en `Game`; nombres como `tck_mili` o `tck_hsec` no garantizan por sí solos una duración real. Sus límites deben revisarse junto con la frecuencia seleccionada.

## Requisitos

- Simulador VHDL, como ModelSim/Questa.
- Herramienta de síntesis adecuada para la FPGA elegida.
- Placa con recursos suficientes para la lógica y datos gráficos.
- Interfaz VGA y conexión de teclado con niveles eléctricos compatibles.
- MATLAB únicamente para abrir o modificar [Bmp2Vhdl.mlx](matlab/Bmp2Vhdl.mlx); no es necesario para analizar las fuentes VHDL existentes.
- Git para descargar el repositorio.

```bash
git clone https://github.com/Tho0x2B/Project2_2530_Disdi.git
cd Project2_2530_Disdi
```

## Compilación y simulación

Desde la raíz del repositorio, ejecute en la consola **Tcl de ModelSim/Questa**:

```tcl
vlib work
vmap work work

foreach src {
    BasicPackage vgaPackage ImagePackage GralLimCounter
    my_dff teclado RotSelector SpriteRotator lifeCtrl
    PlayerMove EnemyMove ShotFsm mando EnemyFsm ShotCtrl
    ImageSync PixelGenerate ControladorVGA Game
} {
    vcom -2008 code/$src.vhd
}

vsim work.Game
add wave -r /*
```

Este orden coloca paquetes y componentes antes de las entidades que los instancian. No se incluye `TestProtocol.vhd`, porque está completamente comentado, ni `EnemyShot.vhd`, porque no es utilizado por `Game`.

### Arranque manual de simulación

```tcl
# Reloj de ejemplo de 20 ns. No es una recomendación de temporización VGA.
force -freeze sim:/game/clk 0 0ns, 1 10ns -r 20ns
force -freeze sim:/game/reset 0
force -freeze sim:/game/ps2_clk 1
force -freeze sim:/game/ps2_data 1
run 100 ns

# Liberar el reset externo.
force -freeze sim:/game/reset 1
run 1 ms
```

Esto permite observar reset y contadores, pero **no simula una partida ni valida el protocolo del teclado**. Con líneas PS/2 en reposo no se genera una orden de inicio. Para una prueba completa hace falta un testbench que produzca tramas y compruebe las salidas.

No se adjuntan resultados nuevos de ejecución en simulador, síntesis o validación física.

## Recursos gráficos y MATLAB

Los recursos originales están en [matlab](matlab/): [fondo](matlab/Background.bmp), [pantalla de inicio](matlab/start.bmp) e imágenes de vida de [cero](matlab/health_point_0.bmp) a [cinco](matlab/health_point_5.bmp).

Los datos que consume el circuito están en [ImagePackage.vhd](code/ImagePackage.vhd). Sustituir un BMP no modifica automáticamente el hardware: es necesario revisar el Live Script, actualizar los datos VHDL correspondientes y volver a compilar.

Antes de usar `Bmp2Vhdl.mlx`, revise sus rutas, dimensiones y formato de salida en MATLAB. Los BMP son recursos gráficos, no capturas de una partida ejecutada.

## Implementación en FPGA

1. Seleccionar la placa y el dispositivo concretos.
2. Crear el proyecto de síntesis y añadir las fuentes en el orden indicado.
3. Seleccionar `Game` como entidad superior, o un wrapper que exponga sus registros de salida.
4. Definir el reloj y comprobar tanto los tiempos VGA como los pulsos de actualización.
5. Asignar pines de reloj, reset, teclado, RGB y sincronismos conforme a la placa.
6. Revisar niveles eléctricos y adaptación de las señales PS/2 y VGA.
7. Sintetizar, revisar advertencias y consumo de recursos, y probar primero video y entrada por separado.

No se incluyen archivos de proyecto, asignaciones `.qsf`/`.qpf`, restricciones `.sdc` ni una selección de placa reproducible. La configuración física debe aportarse para el hardware utilizado.

## Limitaciones y validaciones pendientes

- [TestProtocol.vhd](code/TestProtocol.vhd) no proporciona un testbench ejecutable.
- La correspondencia de teclas y el manejo de liberación deben comprobarse con el protocolo real.
- Aunque el banco del jugador tiene diez disparos, [PixelGenerate.vhd](code/PixelGenerate.vhd) no incluye `b5` en la selección gráfica de sus disparos. Debe revisarse antes de dar por completa la representación de los diez.
- `EnemyFsm` configura `N_LIVES = 4` y `LIFE_SIZE = 2`: dos bits no pueden representar cuatro. La conversión de la vida inicial a ese ancho necesita revisión; no debe interpretarse su salida inicial como una indicación correcta de cuatro vidas.
- `enemyShot` expone únicamente el primer enemigo, no una agregación de los tres.
- El reloj y los contadores necesitan validación conjunta; no hay restricciones temporales incluidas.
- No hay capturas o GIF de funcionamiento ni resultados de pruebas automatizadas en la raíz.

### Plan de pruebas sugerido

| Área | Comprobaciones |
| --- | --- |
| Reset | Polaridad del puerto superior y reinicialización de objetos y vidas |
| Video | Zona visible, total de ciclos, sincronismos y negro fuera de imagen |
| Entrada | Captura de tramas, bytes recibidos, pulsación y liberación |
| Movimiento | Direcciones, orientación y límites de la pantalla |
| Disparos | Las diez posiciones, cadencia, trayectoria y representación de `b5` |
| Colisiones | Impactos, descuento de vidas y objetos fuera de juego |
| Partida | Inicio, vidas del jugador/enemigos y visualización al finalizar |

La documentación describe lo observado en el código y distingue los pendientes; no modifica la implementación ni certifica su funcionamiento.

## Contexto y atribución

Repositorio académico de Diseño de Sistemas Digitales, mantenido en [Tho0x2B](https://github.com/Tho0x2B). Se conservan las fuentes y recursos originales. No se incluye un archivo de licencia en la raíz.
