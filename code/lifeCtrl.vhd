LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.BasicPackage.ALL;

ENTITY lifeCtrl IS
     GENERIC (
          N_LIVES   : INTEGER := 3;
          LIFE_SIZE : INTEGER := 2
     );
     PORT (
          clk        : IN  uint01;
          rst        : IN  uint01;
          tck        : IN  uint01;
          colision_i : IN  uint01;

          gameover_o : OUT uint01;
          life_o     : OUT STD_LOGIC_VECTOR(LIFE_SIZE-1 DOWNTO 0)
     );
END ENTITY lifeCtrl;

ARCHITECTURE rtl OF lifeCtrl IS

     SIGNAL col_now    : uint01;
     SIGNAL col_prev   : uint01 := '0';
     SIGNAL col_seen   : uint01 := '0';
     SIGNAL col_pulse  : uint01 := '0';
     SIGNAL col_tick   : uint01;
     SIGNAL gameover_r : uint01 := '0';
     SIGNAL hits_cnt   : STD_LOGIC_VECTOR(LIFE_SIZE-1 DOWNTO 0);

BEGIN

     col_now <= colision_i;

     PRC_COL_RATE : PROCESS (clk)
     BEGIN
          IF rst = '1' THEN
               col_prev  <= '0';
               col_seen  <= '0';
               col_pulse <= '0';
          ELSIF RISING_EDGE(clk) THEN

               col_prev <= col_now;

               IF (col_now = '1' AND col_prev = '0') THEN
                    col_seen <= '1';
               END IF;

               IF tck = '1' THEN
                    col_pulse <= col_seen;
                    col_seen  <= '0';
               ELSE
                    col_pulse <= '0';
               END IF;
          END IF;
     END PROCESS;

     col_counter : ENTITY work.GralLimCounter
          GENERIC MAP ( Size => LIFE_SIZE )
          PORT MAP (
               clk      => clk,
               rst      => rst,
               syn_clr  => '0',
               en       => col_pulse AND (NOT gameover_r),
               up       => '1',
               limit    => Int2Slv(N_LIVES - 1, LIFE_SIZE),
               max_tick => col_tick,
               min_tick => OPEN,
               counter  => hits_cnt
          );
			 
     PRC_GAMEOVER : PROCESS (clk)
     BEGIN
          IF rst = '1' THEN
               gameover_r <= '0';
          ELSIF RISING_EDGE(clk) THEN
               IF col_tick = '1' THEN
                    gameover_r <= '1';
               END IF;
          END IF;
     END PROCESS;

     gameover_o <= gameover_r;

     life_o <= Int2Slv( N_LIVES - slv2int(hits_cnt),LIFE_SIZE);

END ARCHITECTURE rtl;
