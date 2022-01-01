-----------------------------------------------------------------------------
----------------  This RTL Code written by Matan Leizerovich  ---------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-------			    Fun Project TestBench	  	      -------
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity funProjectTB is
end entity funProjectTB;

architecture sim of funProjectTB is
	-- Constants --
	constant c_PERIOD : time := 20 ns; -- T = 1/f => T=1/50*10^6 => T = 20nsec
	
	-- Stimulus signals --
	signal i_clk   : std_logic;
	signal i_reset : std_logic;
	
	-- Observed signal --
	signal o_LEDR : std_logic_vector(9 downto 0);
	signal o_LEDG : std_logic_vector(7 downto 0);
	signal o_HEX0 : std_logic_vector(6 downto 0);
	signal o_HEX1 : std_logic_vector(6 downto 0);
	signal o_HEX2 : std_logic_vector(6 downto 0);
	signal o_HEX3 : std_logic_vector(6 downto 0);

	
begin
	
	-- Unit Under Test port map --
	UUT : entity work.funProject(rtl) 
	port map (
			i_clk   => i_clk ,
			i_reset => i_reset ,  
			LEDR  => o_LEDR ,
			LEDG  => o_LEDG ,
			HEX0  => o_HEX0 ,
			HEX1  => o_HEX1 , 
			HEX2  => o_HEX2 ,
			HEX3  => o_HEX3
		 );
			

	-- Testbench process --
	p_TB : process
	begin
		i_reset <= '0'; wait for c_PERIOD;
		i_reset <= '1'; wait for c_PERIOD * 15; 
		wait; 
	end process p_TB;
	
	
	-- 50 MHz clock in duty cycle of 50% - 20 ns
	p_clock : process 
	begin 
		i_clk <= '0'; wait for c_PERIOD/2; -- 10 ns
		i_clk <= '1'; wait for c_PERIOD/2; -- 10 ns
	end process p_clock;

end architecture sim;
