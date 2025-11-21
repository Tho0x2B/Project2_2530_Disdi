LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.BasicPackage.ALL;
USE WORK.vgaPackage.ALL;

ENTITY PlayerMove IS
     GENERIC (
          spd    : INTEGER := 2
     );
     PORT (
          clk    : IN  uint01 ;
          rst    : IN  uint01 ;
          tck    : IN  uint01 ;
          axis   : IN  uint04 ;
          initial: IN  ObjectT;
          pos_o  : OUT ObjectT;
          vx_o   : OUT uint02 ;     -- "01" der, "11" izq, "00" idle
          vy_o   : OUT uint02       -- "01" arr, "11" abj, "00" idle
     );
END ENTITY;

ARCHITECTURE ArchPlayerMove OF PlayerMove IS

     TYPE st_t IS (RESET_S, WAIT_S, APPLY_S);
     SIGNAL st     : st_t := RESET_S;
     SIGNAL st_n   : st_t;

     SIGNAL pos_r  : ObjectT;
     SIGNAL pos_n  : ObjectT;

     SIGNAL vxs_r  : uint02 := "00";
     SIGNAL vys_r  : uint02 := "01";
     SIGNAL vxs_n  : uint02;
     SIGNAL vys_n  : uint02;

     SIGNAL vxm    : uint02;
     SIGNAL vym    : uint02;

     SIGNAL any_on : STD_LOGIC;

     SIGNAL xi_inc : uint11;
     SIGNAL xi_dec : uint11;
     SIGNAL yi_inc : uint11;
     SIGNAL yi_dec : uint11;

     SIGNAL xi_sel : uint11;
     SIGNAL yi_sel : uint11;

BEGIN
     WITH axis(3 DOWNTO 2) SELECT
          vxm <= "01" WHEN "10",   -- D
                 "11" WHEN "01",   -- A
                 "00" WHEN OTHERS;

     WITH axis(1 DOWNTO 0) SELECT
          vym <= "11" WHEN "10",   -- S
                 "01" WHEN "01",   -- W
                 "00" WHEN OTHERS;

     any_on <= '1' WHEN (vxm /= "00") OR (vym /= "00") ELSE '0';

     xi_inc <= Int2Slv(Slv2Int(pos_r.xi) + spd, 11);
     xi_dec <= Int2Slv(Slv2Int(pos_r.xi) - spd, 11);
     yi_inc <= Int2Slv(Slv2Int(pos_r.yi) + spd, 11);
     yi_dec <= Int2Slv(Slv2Int(pos_r.yi) - spd, 11);

     WITH vxm SELECT
          xi_sel <= xi_inc   WHEN "01",
                    xi_dec   WHEN "11",
                    pos_r.xi WHEN OTHERS;

     WITH vym SELECT
          yi_sel <= yi_dec   WHEN "01",
                    yi_inc   WHEN "11",
                    pos_r.yi WHEN OTHERS;

     pos_o <= pos_r;
     vx_o  <= vxs_r;
     vy_o  <= vys_r;

     PRC_REG : PROCESS (clk, rst)
     BEGIN
          IF rst = '1' THEN
               st       <= RESET_S;
               pos_r.xi <= (OTHERS => '0');
               pos_r.yi <= (OTHERS => '0');
               vxs_r    <= "00";
               vys_r    <= "01";
          ELSIF RISING_EDGE(clk) THEN
               st       <= st_n;
               pos_r    <= pos_n;
               vxs_r    <= vxs_n;
               vys_r    <= vys_n;
          END IF;
     END PROCESS;

     --------------------------------------------------------------------------
     PRC_FSM : PROCESS (st, tck, any_on)
     BEGIN
          st_n      <= st;

          pos_n.xi  <= pos_r.xi;
          pos_n.yi  <= pos_r.yi;
          vxs_n     <= vxs_r;
          vys_n     <= vys_r;

          CASE st IS
               WHEN RESET_S =>
                    pos_n.xi <= initial.xi;
                    pos_n.yi <= initial.yi;
                    vxs_n    <= "00";
                    vys_n    <= "01";
                    st_n     <= WAIT_S;

               WHEN WAIT_S =>
                    IF tck = '1' THEN
                         st_n <= APPLY_S;
                    END IF;

               WHEN APPLY_S =>
                    pos_n.xi <= xi_sel;
                    pos_n.yi <= yi_sel;

                    IF any_on = '1' THEN
                         vxs_n <= vxm;
                         vys_n <= vym;
                    END IF;

                    st_n <= WAIT_S;

          END CASE;
     END PROCESS;

     pos_n.xf <= Int2Slv(Slv2Int(pos_n.Xi) + 39, 11);
     pos_n.yf <= Int2Slv(Slv2Int(pos_n.Yi) + 39, 11);

END ARCHITECTURE;
