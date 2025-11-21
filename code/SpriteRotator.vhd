LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.BasicPackage.ALL;

ENTITY SpriteRotator IS
   GENERIC (
      shifts : INTEGER := 1;
      sprite : INTEGER := 19
   );
   PORT (
      posX     : IN  uint11;
      posY     : IN  uint11;
      refObj   : IN  ObjectT;
      rot      : IN  uint02;
      px_x_out : OUT uint11;
      px_y_out : OUT uint11
   );
END ENTITY SpriteRotator;

-------------------------------------------------------------------------------
ARCHITECTURE rtl OF SpriteRotator IS

   SIGNAL dx_i, dy_i : INTEGER;

   SIGNAL dx_slv, dy_slv   : uint11;
   SIGNAL dx_s_slv, dy_s_slv : uint11;

   SIGNAL dx_s_i, dy_s_i : INTEGER;
   SIGNAL px_x_i, px_y_i : INTEGER;

BEGIN

   dx_i <= Slv2Int(posX) - Slv2Int(refObj.Xi);
   dy_i <= Slv2Int(posY) - Slv2Int(refObj.Yi);

   dx_slv <= Int2Slv(dx_i, 11);
   dy_slv <= Int2Slv(dy_i, 11);

   dx_s_slv <= dx_slv                                         WHEN shifts = 0 ELSE
               '0'         & dx_slv(10 DOWNTO 1)              WHEN shifts = 1 ELSE
               "00"        & dx_slv(10 DOWNTO 2)              WHEN shifts = 2 ELSE
               "000"       & dx_slv(10 DOWNTO 3)              WHEN shifts = 3 ELSE
               "0000"      & dx_slv(10 DOWNTO 4)              WHEN shifts = 4 ELSE
               (OTHERS => '0');

   dy_s_slv <= dy_slv                                         WHEN shifts = 0 ELSE
               '0'         & dy_slv(10 DOWNTO 1)              WHEN shifts = 1 ELSE
               "00"        & dy_slv(10 DOWNTO 2)              WHEN shifts = 2 ELSE
               "000"       & dy_slv(10 DOWNTO 3)              WHEN shifts = 3 ELSE
               "0000"      & dy_slv(10 DOWNTO 4)              WHEN shifts = 4 ELSE
               (OTHERS => '0');

   dx_s_i <= Slv2Int(dx_s_slv);
   dy_s_i <= Slv2Int(dy_s_slv);

   WITH rot SELECT
      px_x_i <= dx_s_i           WHEN "00",
                dy_s_i           WHEN "01",
                sprite - dx_s_i  WHEN "10",
                sprite - dy_s_i  WHEN OTHERS;

   WITH rot SELECT
      px_y_i <= dy_s_i           WHEN "00",
                sprite - dx_s_i  WHEN "01",
                sprite - dy_s_i  WHEN "10",
                dx_s_i           WHEN OTHERS;

   px_x_out <= Int2Slv(px_x_i, 11);
   px_y_out <= Int2Slv(px_y_i, 11);

END ARCHITECTURE rtl;

