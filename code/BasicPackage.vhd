LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE BasicPackage IS

    SUBTYPE uint01 IS STD_LOGIC;
    SUBTYPE uint02 IS STD_LOGIC_VECTOR(1  DOWNTO 0);
    SUBTYPE uint03 IS STD_LOGIC_VECTOR(2  DOWNTO 0);
    SUBTYPE uint04 IS STD_LOGIC_VECTOR(3  DOWNTO 0);
    SUBTYPE uint05 IS STD_LOGIC_VECTOR(4  DOWNTO 0);
    SUBTYPE uint06 IS STD_LOGIC_VECTOR(5  DOWNTO 0);
    SUBTYPE uint07 IS STD_LOGIC_VECTOR(6  DOWNTO 0);
    SUBTYPE uint08 IS STD_LOGIC_VECTOR(7  DOWNTO 0);
    SUBTYPE uint09 IS STD_LOGIC_VECTOR(8  DOWNTO 0);
    SUBTYPE uint10 IS STD_LOGIC_VECTOR(9  DOWNTO 0);
    SUBTYPE uint11 IS STD_LOGIC_VECTOR(10 DOWNTO 0);
	 
	 TYPE ObjectT IS RECORD
            Xi : uint11;
            Yi : uint11;
            Xf : uint11;
            Yf : uint11;
    END RECORD ObjectT;
	
	TYPE BalasT IS RECORD
		 b0  : ObjectT;
		 b1  : ObjectT;
		 b2  : ObjectT;
		 b3  : ObjectT;
		 b4  : ObjectT;
		 b5  : ObjectT;
		 b6  : ObjectT;
		 b7  : ObjectT;
		 b8  : ObjectT;
		 b9  : ObjectT;
	END RECORD BalasT;
	
	TYPE ObjsDataT IS RECORD
		---------------------
	   startGame  : uint01;
		---------------------
		player     : ObjectT;
		playerShot : BalasT;
		player_rot : uint02;
		hpPlayer   : uint03;
		GOPlayer   : uint01;
		---------------------
		enemy1     : ObjectT;
		enemy1Shot : ObjectT;
		enemy1_rot : uint02;
		GOEnemy1   : uint01;
		---------------------
		enemy2     : ObjectT;
		enemy2Shot : ObjectT;
		enemy2_rot : uint02;
		GOEnemy2   : uint01;
		---------------------
		enemy3     : ObjectT;
		enemy3Shot : ObjectT;
		enemy3_rot : uint02;
		GOEnemy3   : uint01;
		---------------------
	END RECORD ObjsDataT;
	 
    PURE FUNCTION Int2Slv(Input : INTEGER;
                          Size  : INTEGER)
    RETURN STD_LOGIC_VECTOR;

	 PURE FUNCTION Slv2Int(Input : STD_LOGIC_VECTOR)
		 RETURN INTEGER;

	 PURE FUNCTION ComputePos(ImageData : objectT;
                             posX      : STD_LOGIC_VECTOR;
                             posY      : STD_LOGIC_VECTOR
                            )
	 RETURN uint01;
	 
	 PURE FUNCTION computeColision (
		  posA  : ObjectT;
		  posB  : ObjectT
	  ) RETURN uint01;
	 
END PACKAGE BasicPackage;

PACKAGE BODY BasicPackage IS


    PURE FUNCTION ComputePos(ImageData : objectT;
                             posX      : STD_LOGIC_VECTOR;
                             posY      : STD_LOGIC_VECTOR
                            )
    RETURN uint01 IS
    BEGIN
         IF(((Slv2Int(ImageData.Xi) <= Slv2Int(posX)) AND (Slv2Int(ImageData.Xf) >= Slv2Int(posX))) AND 
            ((Slv2Int(ImageData.Yi) <= Slv2Int(posY)) AND (Slv2Int(ImageData.Yf) >= Slv2Int(posY)))) THEN
              RETURN '1';
          ELSE
              RETURN '0';
         END IF;
    END ComputePos;
	 
   PURE FUNCTION computeColision (
     posA : ObjectT;
     posB  : ObjectT
	) 
	RETURN uint01 IS
	BEGIN
		  IF (Slv2Int(posA.xf) >= Slv2Int(posB.xi)) AND
			  (Slv2Int(posA.xi) <= Slv2Int(posB.xf)) AND
			  (Slv2Int(posA.yf) >= Slv2Int(posB.yi)) AND
			  (Slv2Int(posA.yi) <= Slv2Int(posB.yf)) THEN

				 RETURN '1';

		  ELSE
				 RETURN '0';
		  END IF;
	END computeColision;

    PURE FUNCTION Int2Slv(Input : INTEGER;
                          Size  : INTEGER)
    RETURN STD_LOGIC_VECTOR IS

    BEGIN
    RETURN STD_LOGIC_VECTOR(TO_UNSIGNED(Input, Size));
    END Int2Slv;

	 PURE FUNCTION Slv2Int(Input : STD_LOGIC_VECTOR)
	 RETURN INTEGER IS
	 BEGIN
		 RETURN TO_INTEGER(UNSIGNED(Input));
	 END Slv2Int;

END BasicPackage;