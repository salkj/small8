library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.libSM8.all;


entity reg is
  generic(width : positive := 8);
  port (
    clock : in std_logic;
    rst : in std_logic;
    en : in std_logic;
    d : in std_logic_vector(width-1 downto 0);
    q : out std_logic_vector(width-1 downto 0)
  );
end entity;

architecture arch of reg is

begin
  process(clock,rst)
  begin
    if(rst = '1') then
      q <= (others => '0');
    elsif (rising_edge(clock)) then
      if(en = '1') then
        q <= d;
      end if;
    end if;
  end process;
end architecture;
