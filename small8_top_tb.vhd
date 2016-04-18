-- Jayson Salkey
-- small8_top_tb.vhd

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.libSM8.all;

entity small8_top_tb is
end entity;

architecture arch of small8_top_tb is

  signal clock : std_logic := '0';
  signal rst : std_logic := '0';

  signal led0 : std_logic_vector(6 downto 0);
  signal led1 : std_logic_vector(6 downto 0);
  signal led2 : std_logic_vector(6 downto 0);
  signal led3 : std_logic_vector(6 downto 0);

begin

  U_SMALL8_CTRL_DATAPATH : entity work.small8_top


    port map(
      clock => clock,
      rst => rst,
      input1 => (others => '0'),
      input1_en => '0',
      input2_en => '0',
      led0 => led0,
      led1 => led1,
      led2 => led2,
      led3 => led3
    );

    clock <= not clock after 10 ns;

    process
      begin

        rst <= '1';
        wait for 20 ns;
    end process;

end architecture;
