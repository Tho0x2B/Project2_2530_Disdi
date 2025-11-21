LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.BasicPackage.ALL;
USE work.VGAPackage.ALL;

ENTITY EnemyFsm IS
     GENERIC (
          spawn_x           : INTEGER := 400;
          spawn_y           : INTEGER := 100
     );
     PORT (

     ------------------------------------------------------------------

          clk        : IN  uint01;
          rst        : IN  uint01;
          tck_mov    : IN  uint01;
			 tck_mili   : IN  uint01;
          ply_pos    : IN  ObjectT;
          shootpos   : IN  BalasT;
			 tck_hsec   : IN  uint01;
          trg_o      : OUT uint01;
          vx_o       : OUT uint02;
          vy_o       : OUT uint02;
          GameOver   : OUT uint01;
			 life_s     : OUT uint02;
          en_pos     : OUT ObjectT

     ------------------------------------------------------------------

     );

END ENTITY;

ARCHITECTURE rtl OF EnemyFsm IS

     ------------------------------------------------------------------

     CONSTANT DIR_UP         : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
     CONSTANT DIR_UP_RIGHT   : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
     CONSTANT DIR_RIGHT      : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
     CONSTANT DIR_DOWN_RIGHT : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";
     CONSTANT DIR_DOWN       : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
     CONSTANT DIR_DOWN_LEFT  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";
     CONSTANT DIR_LEFT       : STD_LOGIC_VECTOR(2 DOWNTO 0) := "110";
     CONSTANT DIR_UP_LEFT    : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111";


     ------------------------------------------------------------------

     SIGNAL pos_xi_r : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
     SIGNAL pos_yi_r : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
     SIGNAL dir_r    : STD_LOGIC_VECTOR(2 DOWNTO 0)  := DIR_DOWN;

     ------------------------------------------------------------------

     TYPE enemy_st_t IS (ST_ROTATE, ST_MOVE);
     SIGNAL st_r : enemy_st_t := ST_ROTATE;

     ------------------------------------------------------------------

     SIGNAL pos_xi_n : uint11;
     SIGNAL pos_yi_n : uint11;
     SIGNAL dir_echo : uint03;

     SIGNAL abs_dx   : STD_LOGIC_VECTOR(11 DOWNTO 0);
     SIGNAL abs_dy   : STD_LOGIC_VECTOR(11 DOWNTO 0);
     SIGNAL x_dom    : uint01;
     SIGNAL y_dom    : uint01;
     SIGNAL diag     : uint01;
     SIGNAL dx_pos   : uint01;
     SIGNAL dx_neg   : uint01;
     SIGNAL dy_pos   : uint01;
     SIGNAL dy_neg   : uint01;
     SIGNAL center   : uint01;
     SIGNAL dir_raw  : uint03;
     SIGNAL dir_next : uint03;
     SIGNAL colision : uint01;

     ------------------------------------------------------------------

     SIGNAL tck_fire     : uint01;
     SIGNAL fire_req_r   : uint01 := '0';

     ------------------------------------------------------------------

     SIGNAL trg_s  : uint01;
     SIGNAL vx_s   : uint02;
     SIGNAL vy_s   : uint02;

     SIGNAL shot_active : STD_LOGIC := '0';
     SIGNAL tck_shot    : uint01;
     SIGNAL syn_clr_shot : STD_LOGIC := '0';
     SIGNAL vx_map      : uint02;
     SIGNAL vy_map      : uint02;

     SIGNAL gameover_s  : uint01;

	  SIGNAL enPos       : ObjectT;

BEGIN
     trg_o <= trg_s;
     vx_o  <= vx_s;
     vy_o  <= vy_s;

	  en_pos <= enPos;

     enPos.xi <= pos_xi_r;
     enPos.yi <= pos_yi_r;
     enPos.xf <= Int2Slv(Slv2Int(pos_xi_r) + 79, 11);
     enPos.yf <= Int2Slv(Slv2Int(pos_yi_r) + 79, 11);

     ------------------------------------------------------------------
     abs_dx <= Int2Slv( -(Slv2Int(ply_pos.xi) - Slv2Int(pos_xi_r)), 12 )
               WHEN (Slv2Int(ply_pos.xi) - Slv2Int(pos_xi_r)) < 0 ELSE
               Int2Slv(  (Slv2Int(ply_pos.xi) - Slv2Int(pos_xi_r)), 12 );

     abs_dy <= Int2Slv( -(Slv2Int(ply_pos.yi) - Slv2Int(pos_yi_r)), 12 )
               WHEN (Slv2Int(ply_pos.yi) - Slv2Int(pos_yi_r)) < 0 ELSE
               Int2Slv(  (Slv2Int(ply_pos.yi) - Slv2Int(pos_yi_r)), 12 );

     ------------------------------------------------------------------

     x_dom  <= '1' WHEN Slv2Int(abs_dx) >  Slv2Int(abs_dy) ELSE '0';
     y_dom  <= '1' WHEN Slv2Int(abs_dx) <  Slv2Int(abs_dy) ELSE '0';
     diag   <= '1' WHEN Slv2Int(abs_dx) =  Slv2Int(abs_dy) ELSE '0';

     ------------------------------------------------------------------

     dx_pos <= '1' WHEN Slv2Int(ply_pos.xi) > Slv2Int(pos_xi_r) ELSE '0';
     dx_neg <= '1' WHEN Slv2Int(ply_pos.xi) < Slv2Int(pos_xi_r) ELSE '0';
     dy_pos <= '1' WHEN Slv2Int(ply_pos.yi) > Slv2Int(pos_yi_r) ELSE '0';
     dy_neg <= '1' WHEN Slv2Int(ply_pos.yi) < Slv2Int(pos_yi_r) ELSE '0';

     ------------------------------------------------------------------


     colision <= '1' WHEN (computeColision(enPos, shootpos.b0) = '1') OR
                          (computeColision(enPos, shootpos.b1) = '1') OR
                          (computeColision(enPos, shootpos.b2) = '1') OR
                          (computeColision(enPos, shootpos.b3) = '1') OR
                          (computeColision(enPos, shootpos.b4) = '1') OR
                          (computeColision(enPos, shootpos.b5) = '1') OR
                          (computeColision(enPos, shootpos.b6) = '1') OR
                          (computeColision(enPos, shootpos.b7) = '1') OR
                          (computeColision(enPos, shootpos.b8) = '1') OR
                          (computeColision(enPos, shootpos.b9) = '1')
                          ELSE '0';

     ------------------------------------------------------------------

     dir_raw <=
          DIR_RIGHT      WHEN (x_dom = '1' AND dx_pos = '1') ELSE
          DIR_LEFT       WHEN (x_dom = '1' AND dx_neg = '1') ELSE
          DIR_DOWN       WHEN (y_dom = '1' AND dy_pos = '1') ELSE
          DIR_UP         WHEN (y_dom = '1' AND dy_neg = '1') ELSE
          DIR_UP_RIGHT   WHEN (diag  = '1' AND dx_pos = '1' AND dy_neg = '1') ELSE
          DIR_DOWN_RIGHT WHEN (diag  = '1' AND dx_pos = '1' AND dy_pos = '1') ELSE
          DIR_DOWN_LEFT  WHEN (diag  = '1' AND dx_neg = '1' AND dy_pos = '1') ELSE
          DIR_UP_LEFT    WHEN (diag  = '1' AND dx_neg = '1' AND dy_neg = '1') ELSE
          dir_r;

     ------------------------------------------------------------------

     dir_next <= dir_r WHEN center = '1' ELSE dir_raw;

     ------------------------------------------------------------------

     U_Life : ENTITY work.lifeCtrl
          GENERIC MAP (
               N_LIVES   => 4,
               LIFE_SIZE => 2
          )
          PORT MAP (
               clk        => clk,
               rst        => rst,
               tck        => tck_hsec,
               colision_i => colision,
               gameover_o => gameover_s,
               life_o     => life_s
          );


     GameOver <= gameover_s;

     ------------------------------------------------------------------

     U_Move : ENTITY work.EnemyMove
          GENERIC MAP (
               step_pix => 1
          )
          PORT MAP (
               pos_xi_i   => pos_xi_r,
               pos_yi_i   => pos_yi_r,
               tck_mov    => tck_mov,
               dir_next_i => dir_r,
               pos_xi_o   => pos_xi_n,
               pos_yi_o   => pos_yi_n,
               dir_r_o    => dir_echo
          );
			 

     ------------------------------------------------------------------
	  
     U_ShotDur : ENTITY work.GralLimCounter
          GENERIC MAP ( Size => 3 )
          PORT MAP (
               clk      => clk,
               rst      => rst,
               syn_clr  => '0',
               en       => shot_active AND tck_hsec,
               up       => '1',
               limit    => "100",
               max_tick => tck_shot,
               min_tick => OPEN,
               counter  => OPEN
          );

     ------------------------------------------------------------------

     PRC_FSM : PROCESS (clk)
     BEGIN
               IF rst = '1' THEN
                    pos_xi_r <= Int2Slv(spawn_x, 11);
                    pos_yi_r <= Int2Slv(spawn_y, 11);
                    dir_r    <= DIR_DOWN;
                    st_r     <= ST_ROTATE;
                    fire_req_r <= '0';
               ELSIF RISING_EDGE(clk) THEN
                    IF gameover_s = '1' THEN
                         fire_req_r <= '0';
                         pos_xi_r <= pos_xi_r;
                         pos_yi_r <= pos_yi_r;
                         dir_r    <= dir_r;
                         st_r     <= ST_ROTATE; 
                    ELSE

                    CASE st_r IS

     ------------------------------------------------------------------

                         WHEN ST_ROTATE =>
                              fire_req_r <= '0';
                              dir_r <= dir_next;
                              pos_xi_r <= pos_xi_r;
                              pos_yi_r <= pos_yi_r;
                              st_r <= ST_MOVE;

     ------------------------------------------------------------------

                         WHEN ST_MOVE =>

                              fire_req_r <= '0';
                              pos_xi_r <= pos_xi_n;
                              pos_yi_r <= pos_yi_n;
                              dir_r    <= dir_r;
                              fire_req_r <= '1';

                              IF (colision = '0') THEN
                                   st_r <= ST_ROTATE;
                              ELSE
                                   st_r <= ST_MOVE;
                              END IF;

     ------------------------------------------------------------------

                    END CASE;
                    END IF;
               END IF;
     END PROCESS;

     ------------------------------------------------------------------

     vx_map <=
          "01" WHEN (dir_r = DIR_RIGHT)      OR
                    (dir_r = DIR_UP_RIGHT)   OR
                    (dir_r = DIR_DOWN_RIGHT) ELSE
          "11" WHEN (dir_r = DIR_LEFT)       OR
                    (dir_r = DIR_UP_LEFT)    OR
                    (dir_r = DIR_DOWN_LEFT)  ELSE
          "00";

     vy_map <=
          "11" WHEN (dir_r = DIR_DOWN)       OR
                    (dir_r = DIR_DOWN_RIGHT) OR
                    (dir_r = DIR_DOWN_LEFT)  ELSE
          "01" WHEN (dir_r = DIR_UP)         OR
                    (dir_r = DIR_UP_RIGHT)   OR
                    (dir_r = DIR_UP_LEFT)    ELSE
          "00";

     ------------------------------------------------------------------

     PRC_SHOT : PROCESS (clk)
     BEGIN
               IF rst = '1' THEN
                    shot_active  <= '0';
                    trg_s        <= '1';
                    vx_s         <= (others => '0');
                    vy_s         <= (others => '0');
               ELSIF RISING_EDGE(clk) THEN

                    IF gameover_s = '1' THEN
                         shot_active <= '0';
                         trg_s       <= '1';
                         vx_s        <= (OTHERS => '0');
                         vy_s        <= (OTHERS => '0');
                    ELSE
                         IF (fire_req_r = '1') AND (shot_active = '0') THEN
                              shot_active  <= '1';
                              trg_s        <= '0';
                              vx_s         <= vx_map;
                              vy_s         <= vy_map;
                         ELSIF shot_active = '1' THEN
                              IF tck_shot = '0' THEN
                                   trg_s <= '0';
                              ELSE
                                   shot_active <= '0';
                                   trg_s       <= '1';
                              END IF;
                         ELSE
                              trg_s <= '1';
                         END IF;
                    END IF;
               END IF;
     END PROCESS;

     ------------------------------------------------------------------

END ARCHITECTURE;