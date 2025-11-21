LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE WORK.BasicPackage.ALL;
USE WORK.VGAPackage.ALL;

ENTITY ControladorVGA IS
  PORT (
     clk       : IN  uint01;
     reset     : IN  uint01;
     ImageData : IN  ObjsDataT;
     RGB       : OUT ColorT;
     VGA_ctrl  : OUT vgaCtrlT;
     signal16  : OUT uint01
  );
END ENTITY ControladorVGA;

ARCHITECTURE MainArch OF ControladorVGA IS
  SIGNAL VideoOn  : uint01;
  SIGNAL PixelX   : uint11;
  SIGNAL PixelY   : uint11;
  SIGNAL HSync    : uint01;
  SIGNAL VSync    : uint01;
  SIGNAL signal16_int : uint01;
BEGIN


  U_Sync : ENTITY WORK.ImageSync
    PORT MAP (
      Reset    => reset,
      SyncClk  => clk,
      HSync    => HSync,
      VSync    => VSync,
      VideoOn  => VideoOn,
      PixelX   => PixelX,
      PixelY   => PixelY,
      Pulse16 => signal16_int
    );

  U_Pixels : ENTITY WORK.PixelGenerate
    PORT MAP (
      ImageData => ImageData,
      PosX      => PixelX,
      PosY      => PixelY,
      VideoOn   => VideoOn,
      RGB       => RGB
    );

  VGA_ctrl.HSync <= HSync;	
  VGA_ctrl.VSync <= VSync;
  signal16       <= signal16_int;
END ARCHITECTURE MainArch;
