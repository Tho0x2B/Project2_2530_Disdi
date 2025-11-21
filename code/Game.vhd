LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE WORK.BasicPackage.ALL;
USE WORK.VGAPackage.ALL;

ENTITY Game IS
  PORT (
    clk       : IN  uint01;
    reset     : IN  uint01;
    ps2_clk   : IN  uint01;
    ps2_data  : IN  uint01;
    enemyShot : OUT uint01;

    RGB       : OUT ColorT;
    VGA_ctrl  : OUT vgaCtrlT
  );
END ENTITY Game;

ARCHITECTURE MainArch OF Game IS
  SIGNAL rst_sign    : uint01;

  SIGNAL initial     : ObjectT := (Xi => "00010000000",
                                   Yi => "00010000000",
                                   Xf => "00010001000",
                                   Yf => "00010001000");

  SIGNAL vx_sgn      : uint02;
  SIGNAL vy_sgn      : uint02;

  SIGNAL tck_mov     : uint01;
  SIGNAL tck_sho     : uint01;
  SIGNAL tck_mili    : uint01;

  SIGNAL arriba_s    : uint01;
  SIGNAL izquierda_s : uint01;
  SIGNAL derecha_s   : uint01;
  SIGNAL abajo_s     : uint01;
  SIGNAL espacio_s   : uint01;

  SIGNAL axis        : uint04;
  SIGNAL fire        : uint01;
 
  SIGNAL signal16    : uint01;

  ---------  Enemy1 ----------
  SIGNAL en1_trg      : uint01;
  SIGNAL en1_vx       : uint02;
  SIGNAL en1_vy       : uint02;
  ----------------------------

  ---------  Enemy2 ----------
  SIGNAL en2_trg      : uint01;
  SIGNAL en2_vx       : uint02;
  SIGNAL en2_vy       : uint02;
  ----------------------------

  ---------  Enemy3 ----------
  SIGNAL en3_trg      : uint01;
  SIGNAL en3_vx       : uint02;
  SIGNAL en3_vy       : uint02;
  ----------------------------
  
  SIGNAL gameover_s  : uint01;
  SIGNAL colision    : uint01;
  SIGNAL life_en1    : uint02;
  SIGNAL tck_hsec    : uint01;

  SIGNAL imageData   : ObjsDataT;
  
  SIGNAL startGame   : uint01;
  
BEGIN

  enemyShot <= en1_trg;
  rst_sign <= NOT reset;
  
  U_VGA : ENTITY WORK.ControladorVGA
    PORT MAP (
      clk       => clk,
      reset     => rst_sign,
      ImageData => imageData,
      RGB       => RGB,
      VGA_ctrl  => VGA_ctrl,
      signal16  => signal16
    );
  
  --------------------------------------------
  -- Enemy 1 ---------------------------------
  --------------------------------------------
  
  U_Enemy1 : ENTITY WORK.EnemyFsm
     GENERIC MAP(
          spawn_x => 700,
          spawn_y => 500
     )
     PORT MAP(
          clk        => clk,
          rst        => rst_sign,
          tck_mov    => tck_mov,
			 tck_hsec   => tck_hsec,
          tck_mili   => tck_mili,
          ply_pos    => imageData.player,
          en_pos     => imageData.enemy1 ,
			 shootPos   => imageData.playerShot,
			 GameOver   => imageData.GOEnemy1,
          trg_o      => en1_trg,
          vx_o       => en1_vx,
          vy_o       => en1_vy
     );

  U_EnemyShot1 : ENTITY WORK.ShotFsm
     GENERIC MAP(
          spd => 6
     )
     PORT MAP(
          clk    => clk,
          rst    => rst_sign,
          tck    => tck_sho,
          trg    => en1_trg,
          plypos => imageData.enemy1,
          vx_i   => en1_vx,
          vy_i   => en1_vy,
          pos_o  => imageData.enemy1shot
  );
  
  	u_rot_enemy1 : ENTITY work.RotSelector
   PORT MAP (
      vx_sgn_i => en1_vx,
      vy_sgn_i => en1_vy,
      rot_o    => imageData.enemy1_rot
   );
  
  --------------------------------------------
  
  
  --------------------------------------------
  -- Enemy 2 ---------------------------------
  --------------------------------------------
  
  U_Enemy2 : ENTITY WORK.EnemyFsm
     GENERIC MAP(
          spawn_x => 500,
          spawn_y => 100
     )
     PORT MAP(
          clk        => clk,
          rst        => rst_sign,
          tck_mov    => tck_mov,
			 tck_hsec   => tck_hsec,
          tck_mili   => tck_mili,
          ply_pos    => imageData.player,
          en_pos     => imageData.enemy2 ,
			 shootPos   => imageData.playerShot,
			 GameOver   => imageData.GOEnemy2,
          trg_o      => en2_trg,
          vx_o       => en2_vx,
          vy_o       => en2_vy
     );

  U_EnemyShot2 : ENTITY WORK.ShotFsm
     GENERIC MAP(
          spd => 6
     )
     PORT MAP(
          clk    => clk,
          rst    => rst_sign,
          tck    => tck_sho,
          trg    => en2_trg,
          plypos => imageData.enemy2,
          vx_i   => en2_vx,
          vy_i   => en2_vy,
          pos_o  => imageData.enemy2shot
  );
  
  	u_rot_enemy2 : ENTITY work.RotSelector
   PORT MAP (
      vx_sgn_i => en2_vx,
      vy_sgn_i => en2_vy,
      rot_o    => imageData.enemy2_rot
   );
  
  --------------------------------------------
  
  --------------------------------------------
  -- Enemy 3 ---------------------------------
  --------------------------------------------
  
  U_Enemy3 : ENTITY WORK.EnemyFsm
     GENERIC MAP(
          spawn_x => 100,
          spawn_y => 500
     )
     PORT MAP(
          clk        => clk,
          rst        => rst_sign,
          tck_mov    => tck_mov,
			 tck_hsec   => tck_hsec,
          tck_mili   => tck_mili,
          ply_pos    => imageData.player,
          en_pos     => imageData.enemy3,
			 shootPos   => imageData.playerShot,
			 GameOver   => imageData.GOEnemy3,
          trg_o      => en3_trg,
          vx_o       => en3_vx,
          vy_o       => en3_vy
     );

  U_EnemyShot3 : ENTITY WORK.ShotFsm
     GENERIC MAP(
          spd => 6
     )
     PORT MAP(
          clk    => clk,
          rst    => rst_sign,
          tck    => tck_sho,
          trg    => en3_trg,
          plypos => imageData.enemy3,
          vx_i   => en3_vx,
          vy_i   => en3_vy,
          pos_o  => imageData.enemy3shot
  );
  
  	u_rot_enemy3 : ENTITY work.RotSelector
   PORT MAP (
      vx_sgn_i => en3_vx,
      vy_sgn_i => en3_vy,
      rot_o    => imageData.enemy3_rot
   );
  
  --------------------------------------------
  
  --------------------------------------------------------
  --- Player   -------------------------------------------
  --------------------------------------------------------
  
  
  --- KeyBoard -------------------------------------------
  
  U_Mando : ENTITY WORK.mando
    PORT MAP (
      clk           => clk,
      rst           => rst_sign,
      data          => ps2_data,
      clk_teclado   => ps2_clk,
      signal_16_m   => signal16,
      arriba_reg    => arriba_s,
      izquierda_reg => izquierda_s,
      derecha_reg   => derecha_s,
      abajo_reg     => abajo_s,
      espacio_reg   => espacio_s
    );

	axis <= derecha_s & izquierda_s & abajo_s & arriba_s;
	fire <= espacio_s;
	
  --------------------------------------------------------
  
  

  --- PlayerCtrl -----------------------------------------

  U_Move : ENTITY WORK.PlayerMove
    GENERIC MAP (spd => 2 )
    PORT MAP (
      clk     => clk,
      rst     => rst_sign,
      tck     => tck_mov AND (NOT imageData.GoPlayer),
      axis    => axis,
      initial => initial,
      pos_o   => imageData.player,
      vx_o    => vx_sgn,
      vy_o    => vy_sgn
    );

	u_rot_player : ENTITY work.RotSelector
   PORT MAP (
      vx_sgn_i => vx_sgn,
      vy_sgn_i => vy_sgn,
      rot_o    => imageData.player_rot
   );

  U_Shot : ENTITY WORK.ShotCtrl
    GENERIC MAP ( spd => 6 )
    PORT MAP (
      clk    => clk,
      rst    => rst_sign,
      tck    => tck_sho,
      trg    => fire,
      plypos => imageData.player,
      vx_i   => vx_sgn,
      vy_i   => vy_sgn,
      balas_o=> imageData.playerShot
    );

  --- PlayerHealthPoints ---------------------------------

   U_Life : ENTITY work.lifeCtrl
          GENERIC MAP (
               N_LIVES   => 5,
               LIFE_SIZE => 3
          )
          PORT MAP (
               clk        => clk,
               rst        => rst_sign,
               tck        => tck_hsec,
               colision_i => colision,
               gameover_o => imageData.GoPlayer,
               life_o     => imageData.hpPlayer
   );
	
	
	
	colision <= '1' WHEN((computeColision(imageData.player, imageData.enemy1shot) = '1' AND imageData.goEnemy1 = '0')  OR
						     ( computeColision(imageData.player, imageData.enemy2shot) = '1' AND imageData.goEnemy2 = '0')  OR 
						     ( computeColision(imageData.player, imageData.enemy3shot) = '1' AND imageData.goEnemy3 = '0')) AND 
							   startGame = '1'                                                                               ELSE '0';

				 
   PRC_GAMEOVER : PROCESS (clk)
     BEGIN
          IF rst_sign = '1' THEN
               startGame <= '0';
          ELSIF RISING_EDGE(clk) THEN
               IF fire = '1' THEN
                    startGame <= '1';
               END IF;
          END IF;
     END PROCESS;
	  
	  ImageData.startGame <= startGame;
	 
  -------------------------------------------------
  
  
  --------------------------------------------------------
  --- Counter   ------------------------------------------
  --------------------------------------------------------
	 
  U_MiliTick : ENTITY WORK.GralLimCounter
    GENERIC MAP ( Size => 16 )
    PORT MAP (
      clk      => clk,
      rst      => rst_sign,
      syn_clr  => '0',
      en       => '1',
      up       => '1',
      limit    => "1100001101010000",
      max_tick => tck_mili,
      min_tick => OPEN,
      counter  => OPEN
    );
	 
	 	  
    hsec_counter: ENTITY work.GralLimCounter
          GENERIC MAP ( Size => 10 )
          PORT MAP (
               clk      => clk,
               rst      => rst_sign,
               syn_clr  => '0',
               en       => tck_mili,
               up       => '1',
               limit    => "1011101110",
               max_tick => tck_hsec,
               min_tick => OPEN,
               counter  => OPEN
     );

  U_ShotTick : ENTITY WORK.GralLimCounter
    GENERIC MAP ( Size => 6 )
    PORT MAP (
      clk      => clk,
      rst      => rst_sign,
      syn_clr  => '0',
      en       => tck_mili AND startGame,
      up       => '1',
      limit    => "011001",
      max_tick => tck_sho,
      min_tick => OPEN,
      counter  => OPEN
    );
	 
  U_MovTick : ENTITY WORK.GralLimCounter
    GENERIC MAP ( Size => 7 )
    PORT MAP (
      clk      => clk,
      rst      => rst_sign,
      syn_clr  => '0',
      en       => tck_mili AND startGame,
      up       => '1',
      limit    => "0111100",
      max_tick => tck_mov,
      min_tick => OPEN,
      counter  => OPEN
    );

END ARCHITECTURE MainArch;
