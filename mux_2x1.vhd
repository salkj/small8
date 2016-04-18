library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.libSM8.all;

entity mux_2x1 is
  port(
    in1    : in  std_logic_vector(CPU_WIDTH-1 downto 0);
    in2    : in  std_logic_vector(CPU_WIDTH-1 downto 0);
    in3    : in  std_logic_vector((2*CPU_WIDTH)-1 downto 0);
    sel    : in  std_logic;
    output1 : out std_logic_vector(CPU_WIDTH-1 downto 0);
    output2 : out std_logic_vector(CPU_WIDTH-1 downto 0)
    );
end mux_2x1;

architecture arch of mux_2x1 is
begin

  process(in1,in2,in3,sel)
  begin
    if(sel = '0') then
      output1 <= in1;
      output2 <= in2;
    else
      output1 <= in3(7 downto 0);
      output2 <= in3(15 downto 8);
    end if;
  end process;

end arch;
