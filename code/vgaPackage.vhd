LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE vgaPackage IS

    USE WORK.BasicPackage.ALL;

    TYPE ColorT IS RECORD
            R : uint04;
            G : uint04;
            B : uint04;
    END RECORD ColorT;

    TYPE vgaCtrlT IS RECORD
        HSync : uint01;
        VSync : uint01;
    END RECORD vgaCtrlT;

    TYPE SvgaDataT IS RECORD
        Display : INTEGER;
        FrontP  : INTEGER;
        Retrace : INTEGER;
        BackP   : INTEGER;
    END RECORD SvgaDataT;

    CONSTANT HData : SvgaDataT := (Display => (799),
                                   FrontP  => ( 16),
                                   Retrace => ( 80),
                                   BackP   => (160)
                                   );

    CONSTANT VData : SvgaDataT := (Display => (599),
                                   FrontP  => (  1),
                                   Retrace => (  2),
                                   BackP   => ( 21)
                                   );				  
		 TYPE TimestampT IS RECORD
			  Display     : uint11;
			  FrontPorch  : uint11;
			  Retrace     : uint11;
			  FullScan    : uint11;
		 END RECORD TimestampT;
											  
	  CONSTANT Color_Blank: ColorT := (R => x"F",
												  G => x"F",
												  B => x"F");
												
	  CONSTANT Color_Black: ColorT := (R => x"0",
												  G => x"0",
												  B => x"0");
												  
	  CONSTANT Color_Purple: ColorT := (R => x"F",
													G => x"0",
													B => x"F");


	CONSTANT HTime : TimestampT := (Display    => (Int2slv((HData.Display ),11)),
											  FrontPorch => (Int2slv((HData.Display + HData.FrontP),11)),
											  Retrace    => (Int2slv((HData.Display + HData.FrontP + HData.Retrace),11)),
											  FullScan   => (Int2slv((HData.Display + HData.FrontP + HData.Retrace + HData.BackP),11))
											  );

	CONSTANT VTime : TimestampT := (Display    => (Int2slv((VData.Display ),11)),
											  FrontPorch => (Int2slv((VData.Display + VData.FrontP),11)),
											  Retrace    => (Int2slv((VData.Display + VData.FrontP + VData.Retrace),11)),
											  FullScan   => (Int2slv((VData.Display + VData.FrontP + VData.Retrace + VData.BackP),11))
											  );


END vgaPackage;


PACKAGE BODY vgaPackage IS

END vgaPackage;