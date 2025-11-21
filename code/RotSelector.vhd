LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.BasicPackage.ALL;

ENTITY RotSelector IS
   PORT (
      vx_sgn_i : IN  uint02;
      vy_sgn_i : IN  uint02;
      rot_o    : OUT uint02
   );
END ENTITY RotSelector;

-------------------------------------------------------------------------------
ARCHITECTURE rtl OF RotSelector IS
BEGIN

   rot_o <= "01" WHEN (vx_sgn_i = "01") ELSE
            "11" WHEN (vx_sgn_i = "11") ELSE
            "10" WHEN ((vx_sgn_i = "00") AND (vy_sgn_i = "11")) ELSE
            "00" WHEN ((vx_sgn_i = "00") AND ((vy_sgn_i = "01") OR (vy_sgn_i = "00"))) ELSE
            "00";

END ARCHITECTURE rtl;
