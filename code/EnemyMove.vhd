LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.BasicPackage.ALL;
USE work.VGAPackage.ALL;

ENTITY EnemyMove IS
     GENERIC (
          step_pix  : INTEGER := 1
     );
     PORT (

          pos_xi_i   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
          pos_yi_i   : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);

          tck_mov    : IN  uint01;
          dir_next_i : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);

          pos_xi_o   : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
          pos_yi_o   : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
          dir_r_o    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)

     );
END ENTITY;

ARCHITECTURE rtl OF EnemyMove IS

     CONSTANT DIR_UP         : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
     CONSTANT DIR_UP_RIGHT   : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
     CONSTANT DIR_RIGHT      : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
     CONSTANT DIR_DOWN_RIGHT : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";
     CONSTANT DIR_DOWN       : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
     CONSTANT DIR_DOWN_LEFT  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";
     CONSTANT DIR_LEFT       : STD_LOGIC_VECTOR(2 DOWNTO 0) := "110";
     CONSTANT DIR_UP_LEFT    : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111";

     SIGNAL x_step : STD_LOGIC_VECTOR(10 DOWNTO 0);
     SIGNAL y_step : STD_LOGIC_VECTOR(10 DOWNTO 0);

BEGIN
     dir_r_o <= dir_next_i;

     x_step <=
          -- +X
          Int2Slv(Slv2Int(pos_xi_i) + step_pix, 11) WHEN
               ( (dir_next_i = DIR_RIGHT) OR
                 (dir_next_i = DIR_UP_RIGHT) OR
                 (dir_next_i = DIR_DOWN_RIGHT) ) AND
               ( Slv2Int(pos_xi_i) < 799 ) ELSE
          -- -X
          Int2Slv(Slv2Int(pos_xi_i) - step_pix, 11) WHEN
               ( (dir_next_i = DIR_LEFT) OR
                 (dir_next_i = DIR_UP_LEFT) OR
                 (dir_next_i = DIR_DOWN_LEFT) ) AND
               ( Slv2Int(pos_xi_i) > 0 ) ELSE
          pos_xi_i;

     y_step <=
          Int2Slv(Slv2Int(pos_yi_i) + step_pix, 11) WHEN
               ( (dir_next_i = DIR_DOWN) OR
                 (dir_next_i = DIR_DOWN_RIGHT) OR
                 (dir_next_i = DIR_DOWN_LEFT) ) AND
               ( Slv2Int(pos_yi_i) < 599 ) ELSE
					
          Int2Slv(Slv2Int(pos_yi_i) - step_pix, 11) WHEN
               ( (dir_next_i = DIR_UP) OR
                 (dir_next_i = DIR_UP_RIGHT) OR
                 (dir_next_i = DIR_UP_LEFT) ) AND
               ( Slv2Int(pos_yi_i) > 0 ) ELSE
          pos_yi_i;

     pos_xi_o <= x_step WHEN tck_mov = '1' ELSE pos_xi_i;
     pos_yi_o <= y_step WHEN tck_mov = '1' ELSE pos_yi_i;
END ARCHITECTURE;

