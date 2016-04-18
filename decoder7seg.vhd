-- Jayson Salkey
-- 01/25/2016 15:32 UTC-5

library ieee;
use ieee.std_logic_1164.all;


entity decoder7seg is
	port (
		input : in std_logic_vector(3 downto 0);
		output : out std_logic_vector(6 downto 0)
		);
end decoder7seg;



architecture decoder_struct of decoder7seg is
begin

	process(input)
	begin
		if(input = x"0") then
			output <= "0000001";
		elsif(input = x"1") then
			output <= "1001111";
		elsif(input = x"2") then
			output <= "0010010";
		elsif(input = x"3") then
			output <= "0000110";
		elsif(input = x"4") then
			output <= "1001100";
		elsif(input = x"5") then
			output <= "0100100";
		elsif(input = x"6") then
			output <= "0100000";
		elsif(input = x"7") then
			output <= "0001111";
		elsif(input = x"8") then
			output <= "0000000";
		elsif(input = x"9") then
			output <= "0001100";
		elsif(input = x"A") then
			output <= "0001000";
		elsif(input = x"B") then
			output <= "1100000";
		elsif(input = x"C") then
			output <= "0110001";
		elsif(input = x"D") then
			output <= "1000010";
		elsif(input = x"E") then
			output <= "0110000";
		elsif(input = x"F") then
			output <= "0111000";
		else
			output <= (others => '0');
		end if;
	end process;
end decoder_struct;
