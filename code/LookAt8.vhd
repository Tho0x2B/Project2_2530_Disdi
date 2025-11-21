LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

USE work.BasicPackage.ALL;

ENTITY lookat8 IS
     PORT (
          dx       : IN  uint11;
          dy       : IN  uint11;
          dir_prev : IN  uint03;
          dir_next : OUT uint03;
          idle     : OUT uint01
     );
END ENTITY;

ARCHITECTURE rtl OF lookat8 IS

     CONSTANT BITS : NATURAL := 10;

     ------------------------------------------------------------------
     -- Constantes de direccion
     ------------------------------------------------------------------
     CONSTANT dir_up         : uint03 := "000";
     CONSTANT dir_up_right   : uint03 := "001";
     CONSTANT dir_right      : uint03 := "010";
     CONSTANT dir_down_right : uint03 := "011";
     CONSTANT dir_down       : uint03 := "100";
     CONSTANT dir_down_left  : uint03 := "101";
     CONSTANT dir_left       : uint03 := "110";
     CONSTANT dir_up_left    : uint03 := "111";

     SIGNAL sdx_neg, sdy_neg : uint01;
     SIGNAL dx_zero, dy_zero : uint01;

     SIGNAL is_u, is_ur, is_r, is_dr, is_d, is_dl, is_l, is_ul : uint01;
     SIGNAL dec8      : uint08;
     SIGNAL dir_comb  : uint03;
     SIGNAL Sign_idle : uint01;

BEGIN
     ------------------------------------------------------------------
     -- Bit de signo de dx, dy
     ------------------------------------------------------------------
     sdx_neg <= dx(BITS);
     sdy_neg <= dy(BITS);

     ------------------------------------------------------------------
     -- Detectores de cero
     ------------------------------------------------------------------
     dx_zero <= '1' WHEN dx = (OTHERS => '0') ELSE '0';
     dy_zero <= '1' WHEN dy = (OTHERS => '0') ELSE '0';

     ------------------------------------------------------------------
     -- Regiones de direccion
     ------------------------------------------------------------------
     -- Ejes
     is_u <= '1' WHEN (sdy_neg = '1' AND dy_zero = '0' AND dx_zero = '1') ELSE '0';
     is_d <= '1' WHEN (sdy_neg = '0' AND dy_zero = '0' AND dx_zero = '1') ELSE '0';
     is_r <= '1' WHEN (sdx_neg = '0' AND dx_zero = '0' AND dy_zero = '1') ELSE '0';
     is_l <= '1' WHEN (sdx_neg = '1' AND dx_zero = '0' AND dy_zero = '1') ELSE '0';

     ------------------------------------------------------------------
     -- Diagonales
     ------------------------------------------------------------------

     is_ur <= '1' WHEN (sdx_neg = '0' AND sdy_neg = '1' AND dx_zero = '0' AND dy_zero = '0') ELSE '0';
     is_dr <= '1' WHEN (sdx_neg = '0' AND sdy_neg = '0' AND dx_zero = '0' AND dy_zero = '0') ELSE '0';
     is_dl <= '1' WHEN (sdx_neg = '1' AND sdy_neg = '0' AND dx_zero = '0' AND dy_zero = '0') ELSE '0';
     is_ul <= '1' WHEN (sdx_neg = '1' AND sdy_neg = '1' AND dx_zero = '0' AND dy_zero = '0') ELSE '0';

     dec8 <= is_u & is_ur & is_r & is_dr & is_d & is_dl & is_l & is_ul;

     ------------------------------------------------------------------
     -- Selección de la direccion combinacional
     ------------------------------------------------------------------
     WITH dec8 SELECT
          dir_comb <=
               dir_up          WHEN "10000000",
               dir_up_right    WHEN "01000000",
               dir_right       WHEN "00100000",
               dir_down_right  WHEN "00010000",
               dir_down        WHEN "00001000",
               dir_down_left   WHEN "00000100",
               dir_left        WHEN "00000010",
               dir_up_left     WHEN "00000001",
               dir_prev        WHEN OTHERS;

     Sign_idle <= '1' WHEN (dx_zero = '1' AND dy_zero = '1') ELSE '0';

     idle <= Sign_idle;

     ------------------------------------------------------------------
     -- Conserva orientacion previa
     ------------------------------------------------------------------
     dir_next <= dir_prev WHEN Sign_idle = '1' ELSE dir_comb;

END ARCHITECTURE;
