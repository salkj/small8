library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clk_div is
    generic(clk_in_freq  : natural;
            clk_out_freq : natural);
    port (
        clk_in  : in  std_logic;
        clk_out : out std_logic;
        rst     : in  std_logic);
end clk_div;


architecture CLK_DIV_STR of clk_div is

	constant NUM_BITS : positive := integer(ceil(log2(real((clk_in_freq/clk_out_freq)+1))));
	signal clk_o : std_logic;
	-- do some math here
	signal count : unsigned(NUM_BITS-1  downto 0);
  signal spec : natural;
begin


	process(clk_in, rst)
	begin
		if(rst = '1') then
			count <= (others => '0');
			clk_o <= '0';
		elsif (rising_edge(clk_in)) then
			-- do some math here
			if (count = to_unsigned(spec-1,NUM_BITS)) then
				clk_o <= '1';
				count <= (others => '0');
			else
				clk_o <= '0';
				count <= "1" + count;
			end if;
		end if;
	end process;

	spec <= ((clk_in_freq/clk_out_freq));
	clk_out <= clk_o;

end CLK_DIV_STR;
