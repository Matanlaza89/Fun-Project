-----------------------------------------------------------------------------
----------------  This RTL Code written by Matan Leizerovich  ---------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-------			            Fun Project       	              -------
-----------------------------------------------------------------------------
------ 		  This entity mimics the default action of the         ------
------ 		     development board when it is turned on            ------
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity funProject is
	port(
		-- Inputs --
		CLOCK_50 : in std_logic;
		KEY 		: in std_logic_vector (0 downto 0);
		
		-- Outputs --
		HEX0 : out std_logic_vector(6 downto 0);
		HEX1 : out std_logic_vector(6 downto 0);
		HEX2 : out std_logic_vector(6 downto 0);
		HEX3 : out std_logic_vector(6 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		LEDG : out std_logic_vector(7 downto 0)
	    );
end entity funProject;

architecture rtl of funProject is
	-- Functions --
	
	-- Displays the 4 bit binray counter on the 7 segments --
	function binaryTo7Segment (counter:std_logic_vector(3 downto 0)) return std_logic_vector is
		begin
			case (counter) is
				when "0000" => return "1000000"; -- 0
				when "0001" => return "1111001"; -- 1
				when "0010" => return "0100100"; -- 2
				when "0011" => return "0110000"; -- 3
				when "0100" => return "0011001"; -- 4
				when "0101" => return "0010010"; -- 5
				when "0110" => return "0000010"; -- 6
				when "0111" => return "1111000"; -- 7
				when "1000" => return "0000000"; -- 8
				when "1001" => return "0010000"; -- 9
				when "1010" => return "0001000"; -- a
				when "1011" => return "0000011"; -- b
				when "1100" => return "1000110"; -- c
				when "1101" => return "0100001"; -- d
				when "1110" => return "0000110"; -- e
				when "1111" => return "0001110"; -- f
			        when others => return "UUUUUUU"; -- 0
			end case;
	end function binaryTo7Segment;

	-- Aliases --
	alias i_clk : std_logic is CLOCK_50;
	alias i_reset : std_logic is KEY(0);
	
	-- Constants --
	constant c_LED_FREQ : natural := 13; -- Desired frequency - 13 Hz
	constant c_HEX_FREQ : natural := 3; -- Desired frequency - 3 Hz
	
	-- Signals --
	signal r_LEDG : std_logic_vector(7 downto 0) := X"07";
	signal r_LEDR : std_logic_vector(9 downto 0) := "0000000111";
	signal r_cnt_hex : natural:= 0;
	
	signal s_green_direction : std_logic := '0'; -- '0' Left , '1' Right
	signal s_red_direction : std_logic := '0'; -- '0' Left , '1' Right
	
	signal w_3hz_clk : std_logic;
	signal w_3hz_tick : std_logic;
	signal w_13hz_clk : std_logic;
	signal w_13hz_tick : std_logic;
	
begin
	-------- instance of clock divider for the LEDS --------
	i_13Hz_clk : entity work.clockDivider
	generic map(g_FREQ => c_LED_FREQ)
	port map (
			i_clk   => i_clk ,
			i_reset => i_reset ,  
			o_clk   => w_13hz_clk,
			o_tick  => open);
	--------------------------------------------------------
	
	
	-------- instance of clock divider for the 7 segments displays --------
	i_3Hz_clk : entity work.clockDivider
	generic map(g_FREQ => c_HEX_FREQ)
	port map (
			i_clk   => i_clk ,
			i_reset => i_reset ,  
			o_clk   => w_3hz_clk,
			o_tick  => open);
	------------------------------------------------------------------------
	
	
	-- This process moves the LEDs back and forth --
	p_LEDs_handler : process(w_13hz_clk , i_reset) is
	begin
		if (r_LEDG(7) = '1') then
			s_green_direction <= '1'; -- '1' Right
			
		elsif (r_LEDG(0) = '1') then
			s_green_direction <= '0'; -- '0' Left
			
		end if; -- r_LEDG
		
		if (r_LEDR(9) = '1') then
			s_red_direction <= '1'; -- '1' Right
			
		elsif (r_LEDR(0) = '1') then
			s_red_direction <= '0'; -- '0' Left
			
		end if; -- r_LEDR
				
		if (i_reset = '0') then
			r_LEDG <= X"07"; -- Initial LEDG State
			r_LEDR <= "0000000111"; -- Initial LEDR State
			s_green_direction <= '0'; -- '0' Left
			s_red_direction <= '0'; -- '0' Left
			
		elsif (rising_edge(w_13hz_clk)) then	
			
			if (s_green_direction = '0') then -- Left
				r_LEDG <= r_LEDG(6 downto 0) & '0';
				
			else -- Right
				r_LEDG <= '0' & r_LEDG(7 downto 1);
				
			end if; -- s_green_direction
			
			if (s_red_direction = '0') then -- Left
				r_LEDR <= r_LEDR(8 downto 0) & '0';
				
			else -- Right
				r_LEDR <= '0' & r_LEDR(9 downto 1);
				
			end if; -- s_red_direction
			
		end if; -- i_reset / rising_edge(w_13hz_clk)
	end process p_LEDs_handler;
	
	
	-- This process changes the view of the 7 segments from 0 to F --
	p_HEXs_handler: process(w_3hz_clk , i_reset) is
	begin				
		if (i_reset = '0') then
			r_cnt_hex <= 0;
			
		elsif (rising_edge(w_3hz_clk)) then	
			
			if (r_cnt_hex = 15) then
				r_cnt_hex <= 0;
				
			else
				r_cnt_hex <= r_cnt_hex + 1;
				
			end if; -- r_cnt_hex
			
		end if; -- i_reset / rising_edge(w_3hz_clk)
	end process p_HEXs_handler;
	
	
	-- LEDG output display --
	LEDG <= r_LEDG;
	LEDR <= r_LEDR;
	
	-- HEXs output display using convertion to unsigned first and then to std_logic_vector --
	HEX0 <= binaryTo7Segment(std_logic_vector(to_unsigned(r_cnt_hex,4)));
	HEX1 <= binaryTo7Segment(std_logic_vector(to_unsigned(r_cnt_hex,4)));
	HEX2 <= binaryTo7Segment(std_logic_vector(to_unsigned(r_cnt_hex,4)));
	HEX3 <= binaryTo7Segment(std_logic_vector(to_unsigned(r_cnt_hex,4)));

end architecture rtl;
