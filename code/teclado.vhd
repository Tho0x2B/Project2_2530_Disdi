LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
------------------------------------------------------------------------------------
ENTITY teclado IS
	PORT (	clk_ps2	          :  IN    STD_LOGIC;
           	clk                :  IN    STD_LOGIC;
				syn_clr            :  OUT    STD_LOGIC;
				rst		          :	 IN    STD_LOGIC; 
				max_tick           :	 IN    STD_LOGIC;				
				ena_reg            :  OUT   STD_LOGIC;
				ena_count          :  OUT   STD_LOGIC);
END ENTITY teclado;
-------------------------------------------------------------------------------------
ARCHITECTURE rtl OF teclado IS
	TYPE state IS (state_IDL, state_wait1,state_save_reg,state_w0);
	SIGNAL pr_state, nx_state: state;
-------------------------------------------------------------------------------------
BEGIN
-----------------------------------------------------------------	
		PROCESS(rst,clk)
			BEGIN
				IF(rst='1') THEN
					   pr_state <= state_IDL;
				ELSIF(rising_edge(clk)) THEN
						pr_state <= nx_state;
				END IF;
			END PROCESS;
-----------------------------------------------------------------------------------
	PROCESS (pr_state,max_tick,clk_ps2)
		BEGIN
			CASE pr_state IS
				WHEN state_IDL =>
				   ena_reg   <= '0';
					ena_count <= '1';
					syn_clr   <= '1';
				   IF(clk_ps2='1') THEN
						nx_state <= state_IDL;
					ELSE 
						IF(clk_ps2 /='1' ) THEN
							nx_state <= state_wait1;
						ELSE 
							nx_state <= state_wait1;
						END IF;
					END IF;
		--------------------------------		
				WHEN state_wait1 =>
				   ena_reg   <= '0';
					ena_count <= '0';
					syn_clr   <= '0';
				   IF(max_tick='1' AND clk_ps2='1') THEN
						nx_state <= state_IDL;
					ELSIF(max_tick='0' AND clk_ps2='1') THEN 
						nx_state <= state_w0;					
					ELSE 
						IF(clk_ps2 /='0') THEN
							nx_state <= state_wait1;
						ELSE 
							nx_state <= state_wait1;
						END IF;
					END IF;
		--------------------------------		
				WHEN state_save_reg =>
				   ena_reg   <= '1';
					ena_count <= '1';
					syn_clr   <= '0';
			      nx_state <= state_wait1;
		--------------------------------	
				WHEN state_w0 =>
				   ena_reg   <= '0';
					ena_count <= '0';
					syn_clr   <= '0';
				   IF(clk_ps2='0') THEN
						nx_state <= state_save_reg;
					ELSE 
						IF(clk_ps2 /='0') THEN
							nx_state <= state_w0;
						ELSE
							nx_state <= state_w0;
						END IF;
					END IF;
			END CASE;
		END PROCESS;		
-----------------------------------------------------------------------------------
						
END ARCHITECTURE rtl;