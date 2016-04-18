library ieee;
use ieee.std_logic_1164.all;

entity tristate is
  generic (
    width  :     positive := 8);
  port (
    input  : in  std_logic_vector(width-1 downto 0);
    en     : in  std_logic;
    output : out std_logic_vector(width-1 downto 0));
end tristate;

architecture BHV of tristate is
begin

  with en select
    output <=
    input           when '1',
    (others => 'Z') when others;

end BHV;
