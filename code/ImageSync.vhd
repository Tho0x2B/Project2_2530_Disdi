LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE WORK.BasicPackage.ALL;
USE WORK.VgaPackage.ALL;

ENTITY ImageSync IS
  PORT (
    Reset  : IN  uint01;
    SyncClk: IN  uint01;
    HSync  : OUT uint01;
    VSync  : OUT uint01;
    VideoOn: OUT uint01;
    PixelX : OUT uint11;
    PixelY : OUT uint11;
    Pulse16: OUT uint01
  );
END ENTITY ImageSync;

ARCHITECTURE MainArch OF ImageSync IS
  CONSTANT Zero: uint11 := (OTHERS => '0');

  SIGNAL VEnable: uint01;
  SIGNAL HCount : uint11;
  SIGNAL VCount : uint11;
  SIGNAL VideoVon: uint01;
  SIGNAL VideoHon: uint01;
  SIGNAL TmpVideoOn: uint01;
  
  SIGNAL TmpHs1: uint01;
  SIGNAL TmpHs2: uint01;
  SIGNAL TmpVs1: uint01;
  SIGNAL TmpVs2: uint01;
  
  CONSTANT ZEROS : uint11 := (OTHERS => '0');
  
BEGIN
  
  TmpVideoOn <= VideoVon AND VideoHon;
  VideoOn <= TmpVideoOn;
  
  VideoHOn  <= '1' WHEN (UNSIGNED(HCount) <= UNSIGNED(HTime.Display)) ELSE '0';
  VideoVOn  <= '1' WHEN (UNSIGNED(VCount) <= UNSIGNED(VTime.Display)) ELSE '0';
  
  
  WITH TmpVideoOn    SELECT
    PixelX <= HCount WHEN '1',
              Zero   WHEN OTHERS;
  
  WITH TmpVideoOn    SELECT
    PixelY <= VCount WHEN '1',
              Zero   WHEN OTHERS;
  
  TmpHs1 <= '1' WHEN (UNSIGNED(HCount) <= UNSIGNED(HTime.FrontPorch)) ELSE '0';
  TmpHs2 <= '1' WHEN (UNSIGNED(HCount) >  UNSIGNED(HTime.Retrace   )) ELSE '0';
  TmpVs1 <= '1' WHEN (UNSIGNED(VCount) <= UNSIGNED(VTime.FrontPorch)) ELSE '0';
  TmpVs2 <= '1' WHEN (UNSIGNED(VCount) >  UNSIGNED(VTime.Retrace   )) ELSE '0';
  
  HSync <= TmpHs1 OR TmpHs2;
  VSync <= TmpVs1 OR TmpVs2;
  
  Pulse16 <= '1' WHEN (VCount = "1000000000" AND HCount = ZEROS AND TmpVideoOn = '1')
              ELSE '0';
  
  HCounter: ENTITY WORK.GralLimCounter
    GENERIC MAP (Size => 11)
    PORT MAP (
      clk      => SyncClk        ,
      rst      => Reset          ,
      syn_clr  => '0'            ,
      en       => '1'            ,
      up       => '1'            ,
      Limit    => HTime.FullScan ,
      max_tick => VEnable        ,
      min_tick => OPEN           ,
      counter  => HCount          
    );

  VCounter: ENTITY WORK.GralLimCounter
  
    GENERIC MAP (Size => 11)
    PORT MAP (
      clk      => SyncClk        ,
      rst      => Reset          ,
      syn_clr  => '0'            ,
      en       => VEnable        ,
      up       => '1'            ,
      Limit    => VTime.FullScan ,
      max_tick => OPEN           ,
      min_tick => OPEN           ,
      counter  => VCount          
    );

END MainArch;
