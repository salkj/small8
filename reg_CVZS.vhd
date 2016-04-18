-- Jayson Salkey
-- status registers
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.libSM8.all;

entity reg_CVZS  is
  port (
    clock : in std_logic;
    rst : in std_logic;
    setc : in std_logic;
    clrc : in std_logic;
    cen : in std_logic;
    ven : in std_logic;
    zen : in std_logic;
    sen : in std_logic;

    -- flip flops
    ff_C : out std_logic;
    ff_V : out std_logic;
    ff_Z : out std_logic;
    ff_S : out std_logic;

    C : in std_logic;
    V : in std_logic;
    Z : in std_logic;
    S : in std_logic
  );
end entity;

architecture arch of reg_CVZS  is

begin

  process(clock,rst)
  begin
    if(rst = '1') then
      ff_C <= '0';
      ff_V <= '0';
      ff_Z <= '0';
      ff_S <= '0';
    elsif (rising_edge(clock)) then
      if(setc = '1') then -- if both on then go to clrc
        ff_C <= '1';
      end if;
      if(clrc = '1') then -- if both on then go to clrc
        ff_C <= '0';
      end if;
      if(cen = '1') then
        ff_C <= C;
      end if;
      if(ven = '1') then
        ff_V <= V;
      end if;
      if(zen = '1') then
        ff_Z <= Z;
      end if;
      if(sen = '1') then
        ff_S <= S;
      end if;
    end if;
  end process;
end arch;
