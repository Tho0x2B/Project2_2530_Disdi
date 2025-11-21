LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE WORK.BasicPackage.ALL;
USE WORK.VgaPackage.ALL;
USE WORK.ImagePackage.ALL;

ENTITY PixelGenerate IS
     PORT (
          ImageData : IN  ObjsDataT;
          PosX      : IN  uint11;
          PosY      : IN  uint11;
          VideoOn   : IN  uint01;
          RGB       : OUT ColorT
     );
END ENTITY PixelGenerate;
ARCHITECTURE MainArch OF PixelGenerate IS

	SIGNAL colorSelec  : ColorT;
	SIGNAL startGame   : ColorT;
	SIGNAL healthPoint5: ColorT;
	SIGNAL healthPoint4: ColorT;
	SIGNAL healthPoint3: ColorT;
	SIGNAL healthPoint2: ColorT;
	SIGNAL healthPoint1: ColorT;
	SIGNAL spaceship1  : ColorT;
	SIGNAL spaceshipEn1: ColorT;
	SIGNAL spaceshipEn2: ColorT;
	SIGNAL spaceshipEn3: ColorT;
	SIGNAL background  : ColorT;
	SIGNAL playerPosY  : uint11;
	SIGNAL playerPosX  : uint11;
	
	CONSTANT SPRITE_MAX_PLAYER : INTEGER := 39;
	CONSTANT SPRITE_MAX_ENEMY  : INTEGER := 39;
	
	
	CONSTANT background_size  : ObjectT := (Xi => "00000000000",
                                           Yi => "00000000000",
                                           Xf => int2slv(799, 11),
                                           Yf => int2slv(599, 11));
	
	CONSTANT Health_point  : ObjectT := (Xi => int2slv(20, 11),
                                        Yi => int2slv(10, 11),
                                        Xf => int2slv(107, 11),
                                        Yf => int2slv(49, 11));

	SIGNAL hp_px_x : uint11;
	SIGNAL hp_px_y : uint11;

	SIGNAL pl_px_x : uint11;
	SIGNAL pl_px_y : uint11;
	
	SIGNAL en1_px_x : uint11;
	SIGNAL en1_px_y : uint11;
	
	SIGNAL en2_px_x : uint11;
	SIGNAL en2_px_y : uint11;
	
	SIGNAL en3_px_x : uint11;
	SIGNAL en3_px_y : uint11;
	
	SIGNAL bcg_px_x : uint11;
	SIGNAL bcg_px_y : uint11;
	
	SIGNAL str_px_x : uint11;
	SIGNAL str_px_y : uint11;

BEGIN 

	colorSelec <= startGame    WHEN ComputePos(background_size         , posX, posY) = '1' AND ImageData.startGame = '0'  ELSE
					  healthPoint5 WHEN ComputePos(Health_point            , posX, posY) = '1' AND ImageData.hpPlayer = "101"  AND ImageData.GOplayer = '0' ELSE
	              healthPoint4 WHEN ComputePos(Health_point            , posX, posY) = '1' AND ImageData.hpPlayer = "100" ELSE
	              healthPoint3 WHEN ComputePos(Health_point            , posX, posY) = '1' AND ImageData.hpPlayer = "011" ELSE
	              healthPoint2 WHEN ComputePos(Health_point            , posX, posY) = '1' AND ImageData.hpPlayer = "010" ELSE
	              healthPoint1 WHEN ComputePos(Health_point            , posX, posY) = '1' AND ImageData.hpPlayer = "001" ELSE
	              spaceship1   WHEN ComputePos(ImageData.player        , posX, posY) = '1' AND ImageData.GOplayer = '0'   ELSE
					  color_purple WHEN ComputePos(ImageData.playerShot.b0 , posX, posY) = '1' AND ImageData.GOplayer = '0'   ELSE
					  color_purple WHEN ComputePos(ImageData.playerShot.b1 , posX, posY) = '1' AND ImageData.GOplayer = '0'   ELSE
					  color_purple WHEN ComputePos(ImageData.playerShot.b2 , posX, posY) = '1' AND ImageData.GOplayer = '0'   ELSE
					  color_purple WHEN ComputePos(ImageData.playerShot.b3 , posX, posY) = '1' AND ImageData.GOplayer = '0'   ELSE
					  color_purple WHEN ComputePos(ImageData.playerShot.b4 , posX, posY) = '1' AND ImageData.GOplayer = '0'   ELSE
					  color_purple WHEN ComputePos(ImageData.playerShot.b6 , posX, posY) = '1' AND ImageData.GOplayer = '0'   ELSE
					  color_purple WHEN ComputePos(ImageData.playerShot.b7 , posX, posY) = '1' AND ImageData.GOplayer = '0'   ELSE
					  color_purple WHEN ComputePos(ImageData.playerShot.b8 , posX, posY) = '1' AND ImageData.GOplayer = '0'   ELSE
					  color_purple WHEN ComputePos(ImageData.playerShot.b9 , posX, posY) = '1' AND ImageData.GOplayer = '0'   ELSE
					  spaceshipEn1 WHEN ComputePos(ImageData.enemy1        , posX, posY) = '1' AND imageData.GOEnemy1 = '0'  AND ImageData.GOplayer = '0' ELSE
					  spaceshipEn2 WHEN ComputePos(ImageData.enemy2        , posX, posY) = '1' AND imageData.GOEnemy2 = '0'  AND ImageData.GOplayer = '0' ELSE
					  spaceshipEn3 WHEN ComputePos(ImageData.enemy3        , posX, posY) = '1' AND imageData.GOEnemy3 = '0'  AND ImageData.GOplayer = '0' ELSE
					  color_purple WHEN ComputePos(ImageData.enemy1Shot    , posX, posY) = '1' AND imageData.GOEnemy1 = '0'  AND ImageData.GOplayer = '0' ELSE
					  color_purple WHEN ComputePos(ImageData.enemy2Shot    , posX, posY) = '1' AND imageData.GOEnemy2 = '0'  AND ImageData.GOplayer = '0' ELSE
					  color_purple WHEN ComputePos(ImageData.enemy3Shot    , posX, posY) = '1' AND imageData.GOEnemy3 = '0'  AND ImageData.GOplayer = '0' ELSE
					  background   WHEN ComputePos(background_size         , posX, posY) = '1' ELSE
					  color_black;
		
	u_rot_start: ENTITY work.SpriteRotator
		GENERIC MAP (
			shifts => 3,
			sprite => 0
		)
		PORT MAP (
			posX     => PosX,
			posY     => PosY,
			refObj   => background_size,
			rot      => "00",
			px_x_out => str_px_x,
			px_y_out => str_px_y
		);
					  
	u_rot_healthPoint : ENTITY work.SpriteRotator
		GENERIC MAP (
			shifts => 1,
			sprite => 0
		)
		PORT MAP (
			posX     => PosX,
			posY     => PosY,
			refObj   => Health_point,
			rot      => "00",
			px_x_out => hp_px_x,
			px_y_out => hp_px_y
		);		
					  
	u_rot_player : ENTITY work.SpriteRotator
		GENERIC MAP (
			shifts => 0,
			sprite => SPRITE_MAX_PLAYER
		)
		PORT MAP (
			posX     => PosX,
			posY     => PosY,
			refObj   => ImageData.player,
			rot      => ImageData.player_rot,
			px_x_out => pl_px_x,
			px_y_out => pl_px_y
		);		
		
	u_rot_enemy1 : ENTITY work.SpriteRotator
		GENERIC MAP (
			shifts => 1,
			sprite => SPRITE_MAX_ENEMY
		)
		PORT MAP (
			posX     => PosX,
			posY     => PosY,
			refObj   => ImageData.enemy1,
			rot      => ImageData.enemy1_rot,
			px_x_out => en1_px_x,
			px_y_out => en1_px_y
		);
		
	u_rot_enemy2 : ENTITY work.SpriteRotator
		GENERIC MAP (
			shifts => 1,
			sprite => SPRITE_MAX_ENEMY
		)
		PORT MAP (
			posX     => PosX,
			posY     => PosY,
			refObj   => ImageData.enemy2,
			rot      => ImageData.enemy2_rot,
			px_x_out => en2_px_x,
			px_y_out => en2_px_y
		);
		
	u_rot_enemy3 : ENTITY work.SpriteRotator
		GENERIC MAP (
			shifts => 1,
			sprite => SPRITE_MAX_ENEMY
		)
		PORT MAP (
			posX     => PosX,
			posY     => PosY,
			refObj   => ImageData.enemy3,
			rot      => ImageData.enemy3_rot,
			px_x_out => en3_px_x,
			px_y_out => en3_px_y
		);
		
	u_rot_bckground : ENTITY work.SpriteRotator
		GENERIC MAP (
			shifts => 3,
			sprite => 0
		)
		PORT MAP (
			posX     => PosX,
			posY     => PosY,
			refObj   => background_size,
			rot      => "00",
			px_x_out => bcg_px_x,
			px_y_out => bcg_px_y
		);


	startGame.R <= startR(slv2int(str_px_y), slv2int(str_px_x));
	startGame.G <= startG(slv2int(str_px_y), slv2int(str_px_x));
	startGame.B <= startB(slv2int(str_px_y), slv2int(str_px_x));

	spaceship1.R <= spaceshipR(slv2int(pl_px_y), slv2int(pl_px_x));
	spaceship1.G <= spaceshipG(slv2int(pl_px_y), slv2int(pl_px_x));
	spaceship1.B <= spaceshipB(slv2int(pl_px_y), slv2int(pl_px_x));

   spaceshipEn1.R <= spaceshipR(slv2int(en1_px_y), slv2int(en1_px_x));
   spaceshipEn1.G <= spaceshipG(slv2int(en1_px_y), slv2int(en1_px_x));
   spaceshipEn1.B <= spaceshipB(slv2int(en1_px_y), slv2int(en1_px_x));

   spaceshipEn2.R <= spaceshipR(slv2int(en2_px_y), slv2int(en2_px_x));
   spaceshipEn2.G <= spaceshipG(slv2int(en2_px_y), slv2int(en2_px_x));
   spaceshipEn2.B <= spaceshipB(slv2int(en2_px_y), slv2int(en2_px_x));

   spaceshipEn3.R <= spaceshipR(slv2int(en3_px_y), slv2int(en3_px_x));
   spaceshipEn3.G <= spaceshipG(slv2int(en3_px_y), slv2int(en3_px_x));
   spaceshipEn3.B <= spaceshipB(slv2int(en3_px_y), slv2int(en3_px_x));

   healthPoint5.R <= health_point_5R(slv2int(hp_px_y), slv2int(hp_px_x));
   healthPoint5.G <= health_point_5G(slv2int(hp_px_y), slv2int(hp_px_x));
   healthPoint5.B <= health_point_5B(slv2int(hp_px_y), slv2int(hp_px_x));

   healthPoint4.R <= health_point_4R(slv2int(hp_px_y), slv2int(hp_px_x));
   healthPoint4.G <= health_point_4G(slv2int(hp_px_y), slv2int(hp_px_x));
   healthPoint4.B <= health_point_4B(slv2int(hp_px_y), slv2int(hp_px_x));

   healthPoint3.R <= health_point_3R(slv2int(hp_px_y), slv2int(hp_px_x));
   healthPoint3.G <= health_point_3G(slv2int(hp_px_y), slv2int(hp_px_x));
   healthPoint3.B <= health_point_3B(slv2int(hp_px_y), slv2int(hp_px_x));

   healthPoint2.R <= health_point_2R(slv2int(hp_px_y), slv2int(hp_px_x));
   healthPoint2.G <= health_point_2G(slv2int(hp_px_y), slv2int(hp_px_x));
   healthPoint2.B <= health_point_2B(slv2int(hp_px_y), slv2int(hp_px_x));

   healthPoint1.R <= health_point_1R(slv2int(hp_px_y), slv2int(hp_px_x));
   healthPoint1.G <= health_point_1G(slv2int(hp_px_y), slv2int(hp_px_x));
   healthPoint1.B <= health_point_1B(slv2int(hp_px_y), slv2int(hp_px_x));

   Background.R <= BackgroundR(slv2int(bcg_px_y), slv2int(bcg_px_x));
   Background.G <= BackgroundG(slv2int(bcg_px_y), slv2int(bcg_px_x));
   Background.B <= BackgroundB(slv2int(bcg_px_y), slv2int(bcg_px_x));
  


  RGB <= ColorSelec WHEN videoOn = '1' ELSE Color_Black;

END MainArch;
