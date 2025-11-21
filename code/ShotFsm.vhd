LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE WORK.BasicPackage.ALL;
USE WORK.VGAPackage.ALL;

ENTITY ShotFsm IS
     GENERIC (
          spd : INTEGER := 6
     );
     PORT (
          clk    : IN  uint01;
          rst    : IN  uint01;
          tck    : IN  uint01;
          trg    : IN  uint01;
          plypos : IN  ObjectT;
          vx_i   : IN  uint02;
          vy_i   : IN  uint02;
          pos_o  : OUT ObjectT
     );
END ENTITY;

ARCHITECTURE ArchShotFsm OF ShotFsm IS
     TYPE st_t IS (RST_S, HLD_S, MOV_S);
     SIGNAL st     : st_t := RST_S;
     SIGNAL st_n   : st_t;

     SIGNAL pos_r  : ObjectT;
     SIGNAL pos_n  : ObjectT;

     SIGNAL sx_r   : uint02 := "00";
     SIGNAL sy_r   : uint02 := "00";
     SIGNAL sx_n   : uint02;
     SIGNAL sy_n   : uint02;

     SIGNAL tp_r   : uint01 := '0';
     SIGNAL tp_n   : uint01;
BEGIN
     pos_o <= pos_r;

     PRC_REG : PROCESS (clk, rst)
     BEGIN
          IF rst = '1' THEN
               st      <= RST_S;
               pos_r.xi <= (OTHERS => '0');
               pos_r.yi <= (OTHERS => '0');
               sx_r    <= "00";
               sy_r    <= "00";
               tp_r    <= '0';
          ELSIF RISING_EDGE(clk) THEN
               st      <= st_n;
               pos_r   <= pos_n;
               sx_r    <= sx_n;
               sy_r    <= sy_n;
               tp_r    <= tp_n;
          END IF;
     END PROCESS;

     PRC_FSM : PROCESS (st, tck, trg, plypos, vx_i, vy_i, pos_r, sx_r, sy_r, tp_r)
     BEGIN
          st_n  <= st;
          pos_n.xi  <= pos_r.xi;
          pos_n.yi  <= pos_r.yi;
          sx_n  <= sx_r;
          sy_n  <= sy_r;
          tp_n  <= trg;

          CASE st IS
               WHEN RST_S =>
                    pos_n.xi <= (OTHERS => '0');
                    pos_n.yi <= (OTHERS => '0');
                    st_n    <= HLD_S;

               WHEN HLD_S =>
                    pos_n.xi <= int2Slv(((slv2Int(plypos.xi) + slv2Int(plypos.xf))/2) - 10, 11);
                    pos_n.yi <= int2Slv(((slv2Int(plypos.yi) + slv2Int(plypos.yf))/2) - 10, 11);
                    IF (tp_r = '1') AND (trg = '0') THEN
                         sx_n <= vx_i;
                         sy_n <= vy_i;
                         st_n <= MOV_S;
                    END IF;

               WHEN MOV_S =>
                    IF tck = '1' THEN
                         IF sx_r = "01" THEN
                              IF (Slv2Int(pos_r.xi) + spd) > 799 THEN
                                   st_n    <= HLD_S;
                              ELSE
                                   pos_n.xi <= Int2Slv(Slv2Int(pos_r.xi) + spd, 11);
                              END IF;
                         ELSIF sx_r = "11" THEN
                              IF Slv2Int(pos_r.xi) < spd THEN
                                   st_n    <= HLD_S;
                              ELSE
                                   pos_n.xi <= Int2Slv(Slv2Int(pos_r.xi) - spd, 11);
                              END IF;
                         ELSIF sx_r = "00" THEN
                              pos_n.xi <= pos_r.xi;
                         END IF;

                         IF sy_r = "11" THEN
                              IF (Slv2Int(pos_r.yi) + spd) > 599 THEN
                                   st_n    <= HLD_S;
                              ELSE
                                   pos_n.yi <= Int2Slv(Slv2Int(pos_r.yi) + spd, 11);
                              END IF;
                         ELSIF sy_r = "01" THEN
                              IF Slv2Int(pos_r.yi) < spd THEN
                                   st_n    <= HLD_S;
                              ELSE
                                   pos_n.yi <= Int2Slv(Slv2Int(pos_r.yi) - spd, 11);
                              END IF;
                         ELSIF sy_r = "00" THEN
                              pos_n.yi <= pos_r.yi;
                         END IF;
                    END IF;

                    IF trg = '1' THEN
                         st_n <= HLD_S;
                    END IF;
          END CASE;
     END PROCESS;

     pos_n.xf <= Int2Slv(Slv2Int(pos_n.Xi) + 20, 11);
     pos_n.yf <= Int2Slv(Slv2Int(pos_n.Yi) + 20, 11);
END ARCHITECTURE;
