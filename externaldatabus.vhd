-- Jayson Salkey
-- external data bus
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.libSM8.all;


entity externaldatabus is
  port (
    reg_in : in std_logic_vector(CPU_WIDTH-1 downto 0);
    sel : in std_logic_vector(1 downto 0);
    -- link to internal bus
    -- to memory
    mem_d : in std_logic_vector(CPU_WIDTH-1 downto 0);
    -- to ioport inport registers
    input0 : in std_logic_vector(CPU_WIDTH-1 downto 0);
    input1 : in std_logic_vector(CPU_WIDTH-1 downto 0);
    -- current output of external bus
    bus_out : out std_logic_vector(CPU_WIDTH-1 downto 0)
  );
end entity;

architecture arch of externaldatabus is

begin

  -- U_TS1 : entity work.tristate
  --   port map (
  --     input  => internal_dbus,
  --     en     => sel(0),
  --     output => bus_out);
  --
  -- U_TS2 : entity work.tristate
  --   port map (
  --     input  => input0,
  --     en     => sel(1),
  --     output => bus_out);
  --
  -- U_TS3 : entity work.tristate
  --   port map (
  --     input  => input1,
  --     en     => sel(2),
  --     output => bus_out);
  --
  -- U_TS4 : entity work.tristate
  --   port map (
  --     input  => mem_d,
  --     en     => sel(3),
  --     output => bus_out);
 -- the logic is here
  bus_out <=  input0 when (sel = EXT_IN0_SEL) else
              input1 when (sel = EXT_IN1_SEL) else
              reg_in when (sel = IBUS_INTO_EBUS_SEL) else
              mem_d;
end architecture;
