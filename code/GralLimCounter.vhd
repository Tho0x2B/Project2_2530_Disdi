LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE WORK.BasicPackage.ALL;

ENTITY GralLimCounter IS
    GENERIC ( Size : INTEGER := 4);
    PORT (
        clk       : IN  STD_LOGIC;
        rst       : IN  STD_LOGIC;
        syn_clr   : IN  STD_LOGIC;
        en        : IN  STD_LOGIC;
        up        : IN  STD_LOGIC;
        limit     : IN  STD_LOGIC_VECTOR(Size-1 DOWNTO 0);
        max_tick  : OUT STD_LOGIC;
        min_tick  : OUT STD_LOGIC;
        counter   : OUT STD_LOGIC_VECTOR(Size-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF GralLimCounter IS
    CONSTANT ZEROS      : UNSIGNED(Size-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL   count_s    : UNSIGNED(Size-1 DOWNTO 0);
    SIGNAL   count_next : UNSIGNED(Size-1 DOWNTO 0);
BEGIN
    count_next <= (OTHERS => '0') WHEN syn_clr='1' OR count_s = Slv2Int(limit) ELSE
                  count_s + 1     WHEN (en='1' AND up='1') ELSE
                  count_s - 1     WHEN (en='1' AND up='0') ELSE
                  count_s;

    PROCESS(clk, rst)
        VARIABLE temp : UNSIGNED(Size-1 DOWNTO 0);
    BEGIN
        IF (rst='1') THEN
            temp := (OTHERS => '0');
        ELSIF (rising_edge(clk)	) THEN
            IF (en='1') THEN
                temp := count_next;
            END IF;
        END IF;
        counter <= STD_LOGIC_VECTOR(temp);
        count_s <= temp;
    END PROCESS;

	max_tick <= '1' WHEN (en = '1' AND count_s = Slv2Int(limit)) ELSE '0';
	min_tick <= '1' WHEN (en = '1' AND count_s = ZEROS)          ELSE '0';
END ARCHITECTURE;
