LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.BasicPackage.ALL;
USE work.VGAPackage.ALL;

ENTITY EnemyShot IS
     PORT (
          clk         : IN  uint01;
          rst         : IN  uint01;
          fire_req_i  : IN  uint01;                     -- pedido de disparo (1 ciclo)
          dir_r_i     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);

          trg_o       : OUT uint01;                     -- flanco 1->0
          vx_o        : OUT uint02;                     -- "01"=+X, "11"=-X, "00"=0
          vy_o        : OUT uint02                      -- "11"=+Y, "01"=-Y, "00"=0
     );
END ENTITY;

ARCHITECTURE rtl OF EnemyShot IS
     TYPE st_fire_t IS (WAIT_F, FIRE_F);

     CONSTANT DIR_UP         : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
     CONSTANT DIR_UP_RIGHT   : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
     CONSTANT DIR_RIGHT      : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
     CONSTANT DIR_DOWN_RIGHT : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";
     CONSTANT DIR_DOWN       : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
     CONSTANT DIR_DOWN_LEFT  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";
     CONSTANT DIR_LEFT       : STD_LOGIC_VECTOR(2 DOWNTO 0) := "110";
     CONSTANT DIR_UP_LEFT    : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111";

     SIGNAL st_fire    : st_fire_t := WAIT_F;
     SIGNAL trg_r      : uint01 := '1';

     --
     -- Eliminado "fired_once" para permitir disparos periódicos.  El
     -- módulo original sólo permitía un único disparo durante toda la
     -- ejecución porque el flag "fired_once" nunca se reiniciaba.  Al
     -- eliminar dicha variable, el disparo se generará cada vez que
     -- "fire_req_i" sea alto por un ciclo y luego se restablecerá para
     -- aceptar nuevas solicitudes.

     SIGNAL vx_map  : uint02;
     SIGNAL vy_map  : uint02;
BEGIN
     trg_o <= trg_r;

     vx_o <= vx_map;
     vy_o <= vy_map;

     ------------------------------------------------------------------
     -- Mapeo de dirección a vector velocidad
     ------------------------------------------------------------------
     vx_map <= "01" WHEN (dir_r_i = DIR_RIGHT)      ELSE
               "01" WHEN (dir_r_i = DIR_UP_RIGHT)   ELSE
               "01" WHEN (dir_r_i = DIR_DOWN_RIGHT) ELSE
               "11" WHEN (dir_r_i = DIR_LEFT)       ELSE
               "11" WHEN (dir_r_i = DIR_UP_LEFT)    ELSE
               "11" WHEN (dir_r_i = DIR_DOWN_LEFT)  ELSE
               "00";

     vy_map <= "11" WHEN (dir_r_i = DIR_DOWN)       ELSE
               "11" WHEN (dir_r_i = DIR_DOWN_RIGHT) ELSE
               "11" WHEN (dir_r_i = DIR_DOWN_LEFT)  ELSE
               "01" WHEN (dir_r_i = DIR_UP)         ELSE
               "01" WHEN (dir_r_i = DIR_UP_RIGHT)   ELSE
               "01" WHEN (dir_r_i = DIR_UP_LEFT)    ELSE
               "00";

     ------------------------------------------------------------------
     -- FSM de disparo: genera un pulso de disparo cada vez que se
     -- recibe "fire_req_i".  El diseño original permitía disparar
     -- únicamente una vez debido a la variable "fired_once".  Se ha
     -- eliminado dicha restricción para que el enemigo pueda disparar
     -- periódicamente según lo indique el módulo superior.
     ------------------------------------------------------------------
     PRC_FIRE : PROCESS (clk)
     BEGIN
          IF RISING_EDGE(clk) THEN
               IF rst = '1' THEN
                    st_fire <= WAIT_F;
                    trg_r   <= '1';
               ELSE
                    CASE st_fire IS
                         WHEN WAIT_F =>
                              -- Estado de espera: salida alta (no disparo)
                              trg_r <= '1';
                              -- Si se recibe una solicitud de disparo, pasar al estado de disparo
                              IF fire_req_i = '1' THEN
                                   st_fire <= FIRE_F;
                              END IF;

                         WHEN FIRE_F =>
                              -- Estado de disparo: generar un pulso bajo 1 ciclo 1->0
                              trg_r <= '0';
                              -- Después del pulso regresar al estado de espera para aceptar nuevas solicitudes
                              st_fire <= WAIT_F;
                    END CASE;
               END IF;
          END IF;
     END PROCESS;
END ARCHITECTURE;

