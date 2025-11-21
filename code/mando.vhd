LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
------------------------------------------------------------------------------
ENTITY mando IS
	PORT    ( data         :  IN     STD_LOGIC;
				 clk_teclado  :  IN     STD_LOGIC;
				 clk          :  IN     STD_LOGIC;
				 rst          :  IN     STD_LOGIC;
				 signal_16_m  :  IN     STD_LOGIC;
				 arriba_reg   :  OUT    STD_LOGIC;
				 derecha_reg  :  OUT    STD_LOGIC;
				 izquierda_reg:  OUT    STD_LOGIC;
             abajo_reg    :  OUT    STD_LOGIC;
				 espacio_reg  :  OUT    STD_LOGIC
				);
END ENTITY mando;
-------------------------------------------------------------------------------			 
ARCHITECTURE  rtl OF mando IS	
-------------------------------------------------------------------------------
	SIGNAL max_tick, ena_count, ena_reg							   : STD_LOGIC;
	SIGNAL syn_clr_a,syn_clr_d,syn_clr_i,syn_clr_s, syn_clr_b: STD_LOGIC;
	SIGNAL clk_ps2, syn_clr											   : STD_LOGIC;
	SIGNAL der_sig,izq_sig,arri_sig, space_sig,abaj_sig      : STD_LOGIC;
	SIGNAL max_tick_arriba,max_tick_izquierda  			    	: STD_LOGIC;
	SIGNAL arriba, derecha, izquierda, espacio, abajo  	   : STD_LOGIC;
	SIGNAL max_tick_derecha, max_tick_espacio, max_tick_abajo: STD_LOGIC;
	SIGNAL counter                                	         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL ena_registro, registro	   							   : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL lock_w      : STD_LOGIC := '0';
	SIGNAL lock_a      : STD_LOGIC := '0';
	SIGNAL lock_s      : STD_LOGIC := '0';
	SIGNAL lock_d      : STD_LOGIC := '0';
	SIGNAL lock_space  : STD_LOGIC := '0';
	SIGNAL flag_End    : STD_LOGIC := '0';
-------------------------------------------------------------------------------

BEGIN

	arriba_reg<= arriba;
	derecha_reg<= derecha;
	izquierda_reg<= izquierda;
	abajo_reg      <= abajo;
	espacio_reg<= espacio;
	
-------------------------------------------------------------------------------

	 def_mux_1: FOR i IN 0 To 7 GENERATE
			DUT: ENTITY work.my_dff
			PORT MAP (		clk				=>	clk,
								rst				=>	rst,
								en 				=>	ena_registro(i),
								d 					=>	data,
								q 					=>	registro(i));
	 END GENERATE;		
						
	DUT: ENTITY work.my_dff
			PORT MAP (		clk				=>	clk,
								rst				=>	rst,
								en 				=>	'1',
								d 					=>	clk_teclado,
								q 					=>	clk_ps2);
	
	ena_registro<= "00000001" WHEN counter="0000"AND ena_reg='1' ELSE
						"00000010" WHEN counter="0001"AND ena_reg='1' ELSE
						"00000100" WHEN counter="0010"AND ena_reg='1' ELSE
						"00001000" WHEN counter="0011"AND ena_reg='1' ELSE
						"00010000" WHEN counter="0100"AND ena_reg='1' ELSE
						"00100000" WHEN counter="0101"AND ena_reg='1' ELSE
						"01000000" WHEN counter="0110"AND ena_reg='1' ELSE
						"10000000" WHEN counter="0111"AND ena_reg='1' ELSE
						"00000000";
	
	cont_x:ENTITY work.GralLimCounter
	GENERIC MAP(Size => 4)
	PORT MAP ( clk      => clk,
				  rst      => rst,
				  syn_clr  =>syn_clr,
				  en       => ena_count,
				  up       => '1',
				  limit    => "1010",
				  max_tick => max_tick,
				  min_tick => OPEN,
				  counter  => counter);

	fsm:ENTITY work.teclado
	PORT MAP ( clk      		=> clk,
				  rst      		=> rst,
				  clk_ps2  		=> clk_ps2,
				  syn_clr      => syn_clr,
				  max_tick     => max_tick,
				  ena_reg      => ena_reg,
				  ena_count    => ena_count);		  

	der_sig   <= '1' WHEN registro = X"46" ELSE '0'; -- D
	izq_sig   <= '1' WHEN registro = X"38" ELSE '0'; -- A
	arri_sig  <= '1' WHEN registro = X"3A" ELSE '0'; -- W
	abaj_sig  <= '1' WHEN registro = X"36" ELSE '0'; -- S
	space_sig <= '1' WHEN registro = X"52" ELSE '0'; -- Espacio

	PROCESS(clk, rst)
	BEGIN
		IF (rst = '1') THEN
			-- latches de salida
			arriba    <= '0';
			derecha   <= '0';
			izquierda <= '0';
			abajo     <= '0';
			espacio   <= '0';
			-- locks
			lock_w      <= '0';
			lock_a      <= '0';
			lock_s      <= '0';
			lock_d      <= '0';
			lock_space  <= '0';
			flag_End    <= '0';

		ELSIF rising_edge(clk) THEN
			IF (max_tick = '1') THEN

				IF (registro = X"E0") THEN 
					flag_End <= '1';

				ELSE
					IF (flag_End = '1') THEN
						IF (arri_sig = '1') THEN
							arriba <= '0';
							flag_End <= '0';
						END IF;

						IF (der_sig = '1') THEN
							derecha <= '0';
							flag_End <= '0';
						END IF;

						IF (izq_sig = '1') THEN
							izquierda <= '0';
							flag_End <= '0';
						END IF;

						IF (abaj_sig = '1') THEN
							abajo <= '0';
							flag_End <= '0';
						END IF;

						IF (space_sig = '1') THEN
							espacio <= '0';
							flag_End <= '0';
						END IF;

						lock_w      <= '0';
						lock_a      <= '0';
						lock_s      <= '0';
						lock_d      <= '0';
						lock_space  <= '0';

					ELSE

						IF (arri_sig = '1') THEN
							IF (lock_w = '0') THEN
								arriba <= NOT arriba;
								lock_w <= '1';
							END IF;
						ELSE
							lock_w <= '0';
						END IF;

						-- TECLA D (der_sig)
						IF (der_sig = '1') THEN
							IF (lock_d = '0') THEN
								derecha <= NOT derecha;
								lock_d  <= '1';
							END IF;
						ELSE
							lock_d <= '0';
						END IF;

						-- TECLA A (izq_sig)
						IF (izq_sig = '1') THEN
							IF (lock_a = '0') THEN
								izquierda <= NOT izquierda;
								lock_a    <= '1';
							END IF;
						ELSE
							lock_a <= '0';
						END IF;

						-- TECLA S (abaj_sig)
						IF (abaj_sig = '1') THEN
							IF (lock_s = '0') THEN
								abajo  <= NOT abajo;
								lock_s <= '1';
							END IF;
						ELSE
							lock_s <= '0';
						END IF;

						-- ESPACIO (space_sig)
						IF (space_sig = '1') THEN
							IF (lock_space = '0') THEN
								espacio    <= NOT espacio;
								lock_space <= '1';
							END IF;
						ELSE
							lock_space <= '0';
						END IF;

					END IF; -- flag_End
				END IF; -- registro = X"E0"
			END IF; -- max_tick
		END IF; -- rst / clk
	END PROCESS;

	
END ARCHITECTURE rtl;