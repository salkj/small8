-- Jayson Salkey
-- VHDL that combines 2 8 bit registers with load functionality


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.libSM8.all;

entity reg_16_sepld  is
  port (
    clock : in std_logic;
    rst : in std_logic;
    d0 : in std_logic_vector(CPU_WIDTH-1 downto 0);
    d1 : in std_logic_vector(CPU_WIDTH-1 downto 0);
    l_ld : in std_logic;
    h_ld : in std_logic;
    q0 : out std_logic_vector(CPU_WIDTH-1 downto 0);
    q1 : out std_logic_vector(CPU_WIDTH-1 downto 0)
    --q_W : out std_logic_vector((2*CPU_WIDTH)-1 downto 0)
  );
end entity;

architecture arch of reg_16_sepld is

begin
  -- process(clock,rst)
  -- begin
  --   if(rst = '1') then
  --     q0 <= (others => '0');
  --     q1 <= (others => '0');
  --   elsif (rising_edge(clock)) then
  --     if(l_ld = '1') then
  --       q0 <= d0;
  --     end if;
  --     if(h_ld = '1') then
  --       q1 <= d1;
  --     end if;
  --     q_W <= std_logic_vector(q1 & q0);
  --   end if;
  -- end process;
  UREG0 : entity work.reg
    port map(
      clock => clock,
      rst => rst,
      en => l_ld,
      d => d0,
      q => q0
    );
  UREG1 : entity work.reg
    port map(
      clock => clock,
      rst => rst,
      en => h_ld,
      d => d1,
      q => q1
    );
end architecture;
