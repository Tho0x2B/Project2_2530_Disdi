LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE WORK.BasicPackage.ALL;
USE WORK.VGAPackage.ALL;

ENTITY ShotCtrl IS
    GENERIC (
        spd : INTEGER := 6
    );
    PORT (
        clk     : IN  uint01;
        rst     : IN  uint01;
        tck     : IN  uint01;
        trg     : IN  uint01;
        plypos  : IN  ObjectT;
        vx_i    : IN  uint02;
        vy_i    : IN  uint02;
        balas_o : OUT BalasT
    );
END ENTITY ShotCtrl;

-----------------------------------------------------------------
ARCHITECTURE ArchShotCtrl OF ShotCtrl IS

    SIGNAL idx_r : UNSIGNED(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL idx_n : UNSIGNED(3 DOWNTO 0);

    SIGNAL tp_r  : uint01 := '0';
    SIGNAL tp_n  : uint01;
    SIGNAL edge  : uint01;

    SIGNAL trg0  : STD_LOGIC := '0';
    SIGNAL trg1  : STD_LOGIC := '0';
    SIGNAL trg2  : STD_LOGIC := '0';
    SIGNAL trg3  : STD_LOGIC := '0';
    SIGNAL trg4  : STD_LOGIC := '0';
    SIGNAL trg5  : STD_LOGIC := '0';
    SIGNAL trg6  : STD_LOGIC := '0';
    SIGNAL trg7  : STD_LOGIC := '0';
    SIGNAL trg8  : STD_LOGIC := '0';
    SIGNAL trg9  : STD_LOGIC := '0';

    -- Posiciones de cada bala
    SIGNAL pos0  : ObjectT;
    SIGNAL pos1  : ObjectT;
    SIGNAL pos2  : ObjectT;
    SIGNAL pos3  : ObjectT;
    SIGNAL pos4  : ObjectT;
    SIGNAL pos5  : ObjectT;
    SIGNAL pos6  : ObjectT;
    SIGNAL pos7  : ObjectT;
    SIGNAL pos8  : ObjectT;
    SIGNAL pos9  : ObjectT;

BEGIN

    PRC_REG : PROCESS (clk, rst)
    BEGIN
        IF (rst = '1') THEN
            idx_r <= (OTHERS => '0');
            tp_r  <= '0';
        ELSIF rising_edge(clk) THEN
            idx_r <= idx_n;
            tp_r  <= tp_n;
        END IF;
    END PROCESS;

    tp_n  <= trg;
    edge  <= '1' WHEN (tp_r = '1' AND trg = '0') ELSE '0';

    idx_n <= "0000"        WHEN (edge = '1' AND idx_r = "1001") ELSE
             (idx_r + 1)   WHEN (edge = '1')                    ELSE
             idx_r;

    trg0 <= '1' WHEN (edge = '1' AND idx_r = "0000") ELSE '0';
    trg1 <= '1' WHEN (edge = '1' AND idx_r = "0001") ELSE '0';
    trg2 <= '1' WHEN (edge = '1' AND idx_r = "0010") ELSE '0';
    trg3 <= '1' WHEN (edge = '1' AND idx_r = "0011") ELSE '0';
    trg4 <= '1' WHEN (edge = '1' AND idx_r = "0100") ELSE '0';
    trg5 <= '1' WHEN (edge = '1' AND idx_r = "0101") ELSE '0';
    trg6 <= '1' WHEN (edge = '1' AND idx_r = "0110") ELSE '0';
    trg7 <= '1' WHEN (edge = '1' AND idx_r = "0111") ELSE '0';
    trg8 <= '1' WHEN (edge = '1' AND idx_r = "1000") ELSE '0';
    trg9 <= '1' WHEN (edge = '1' AND idx_r = "1001") ELSE '0';

    U_S0 : ENTITY WORK.ShotFsm
        GENERIC MAP ( spd => spd )
        PORT MAP (
            clk    => clk,
            rst    => rst,
            tck    => tck,
            trg    => trg0,
            plypos => plypos,
            vx_i   => vx_i,
            vy_i   => vy_i,
            pos_o  => pos0
        );

    U_S1 : ENTITY WORK.ShotFsm
        GENERIC MAP ( spd => spd )
        PORT MAP (
            clk    => clk,
            rst    => rst,
            tck    => tck,
            trg    => trg1,
            plypos => plypos,
            vx_i   => vx_i,
            vy_i   => vy_i,
            pos_o  => pos1
        );

    U_S2 : ENTITY WORK.ShotFsm
        GENERIC MAP ( spd => spd )
        PORT MAP (
            clk    => clk,
            rst    => rst,
            tck    => tck,
            trg    => trg2,
            plypos => plypos,
            vx_i   => vx_i,
            vy_i   => vy_i,
            pos_o  => pos2
        );

    U_S3 : ENTITY WORK.ShotFsm
        GENERIC MAP ( spd => spd )
        PORT MAP (
            clk    => clk,
            rst    => rst,
            tck    => tck,
            trg    => trg3,
            plypos => plypos,
            vx_i   => vx_i,
            vy_i   => vy_i,
            pos_o  => pos3
        );

    U_S4 : ENTITY WORK.ShotFsm
        GENERIC MAP ( spd => spd )
        PORT MAP (
            clk    => clk,
            rst    => rst,
            tck    => tck,
            trg    => trg4,
            plypos => plypos,
            vx_i   => vx_i,
            vy_i   => vy_i,
            pos_o  => pos4
        );

    U_S5 : ENTITY WORK.ShotFsm
        GENERIC MAP ( spd => spd )
        PORT MAP (
            clk    => clk,
            rst    => rst,
            tck    => tck,
            trg    => trg5,
            plypos => plypos,
            vx_i   => vx_i,
            vy_i   => vy_i,
            pos_o  => pos5
        );

    U_S6 : ENTITY WORK.ShotFsm
        GENERIC MAP ( spd => spd )
        PORT MAP (
            clk    => clk,
            rst    => rst,
            tck    => tck,
            trg    => trg6,
            plypos => plypos,
            vx_i   => vx_i,
            vy_i   => vy_i,
            pos_o  => pos6
        );

    U_S7 : ENTITY WORK.ShotFsm
        GENERIC MAP ( spd => spd )
        PORT MAP (
            clk    => clk,
            rst    => rst,
            tck    => tck,
            trg    => trg7,
            plypos => plypos,
            vx_i   => vx_i,
            vy_i   => vy_i,
            pos_o  => pos7
        );

    U_S8 : ENTITY WORK.ShotFsm
        GENERIC MAP ( spd => spd )
        PORT MAP (
            clk    => clk,
            rst    => rst,
            tck    => tck,
            trg    => trg8,
            plypos => plypos,
            vx_i   => vx_i,
            vy_i   => vy_i,
            pos_o  => pos8
        );

    U_S9 : ENTITY WORK.ShotFsm
        GENERIC MAP ( spd => spd )
        PORT MAP (
            clk    => clk,
            rst    => rst,
            tck    => tck,
            trg    => trg9,
            plypos => plypos,
            vx_i   => vx_i,
            vy_i   => vy_i,
            pos_o  => pos9
        );

    balas_o.b0 <= pos0;
    balas_o.b1 <= pos1;
    balas_o.b2 <= pos2;
    balas_o.b3 <= pos3;
    balas_o.b4 <= pos4;
    balas_o.b5 <= pos5;
    balas_o.b6 <= pos6;
    balas_o.b7 <= pos7;
    balas_o.b8 <= pos8;
    balas_o.b9 <= pos9;

END ARCHITECTURE ArchShotCtrl;