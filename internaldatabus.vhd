-- Jayson Salkey
-- internal data bus
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.libSM8.all;


entity internaldatabus is
  port (
    reg_in : in std_logic_vector(CPU_WIDTH-1 downto 0);
    -- All registers within the internal architecture
    -- mult register
    MULT_reg_low : in std_logic_vector(CPU_WIDTH-1 downto 0);
    MULT_reg_high : in std_logic_vector(CPU_WIDTH-1 downto 0);
    -- Address Register
    AR_reg_low : in std_logic_vector(CPU_WIDTH-1 downto 0);
    AR_reg_high : in std_logic_vector(CPU_WIDTH-1 downto 0);
    -- Stack pointer
    SP_reg_low : in std_logic_vector(CPU_WIDTH-1 downto 0);
    SP_reg_high : in std_logic_vector(CPU_WIDTH-1 downto 0);
    -- Register X
    X_reg_low : in std_logic_vector(CPU_WIDTH-1 downto 0);
    X_reg_high : in std_logic_vector(CPU_WIDTH-1 downto 0);
    -- Program Counter
    PC_reg_low : in std_logic_vector(CPU_WIDTH-1 downto 0);
    PC_reg_high : in std_logic_vector(CPU_WIDTH-1 downto 0);
    -- Register D
    D_reg : in std_logic_vector(CPU_WIDTH-1 downto 0);
    -- Register A
    A_reg : in std_logic_vector(CPU_WIDTH-1 downto 0);
    -- ALU feedback into bus
    ALU_in : in std_logic_vector(CPU_WIDTH-1 downto 0);
    -- select line
    sel : in std_logic_vector(3 downto 0);
    -- bus current output
    bus_out : out std_logic_vector(CPU_WIDTH-1 downto 0)
  );
end entity;

architecture arch of internaldatabus is

begin

  -- U_TS1 : entity work.tristate
  --   port map (
  --     input  => SP_reg_low,
  --     en     => sel(0),
  --     output => bus_out);
  -- U_TS2 : entity work.tristate
  --   port map (
  --     input  => SP_reg_high,
  --     en     => sel(1),
  --     output => bus_out);
  -- U_TS3 : entity work.tristate
  --   port map (
  --     input  => X_reg_low,
  --     en     => sel(2),
  --     output => bus_out);
  -- U_TS4 : entity work.tristate
  --   port map (
  --     input  => X_reg_high,
  --     en     => sel(3),
  --     output => bus_out);
  -- U_TS5 : entity work.tristate
  --   port map (
  --     input  => PC_reg_low,
  --     en     => sel(4),
  --     output => bus_out);
  -- U_TS6 : entity work.tristate
  --   port map (
  --     input  => PC_reg_high,
  --     en     => sel(5),
  --     output => bus_out);
  -- U_TS7 : entity work.tristate
  --   port map (
  --     input  => D_reg,
  --     en     => sel(6),
  --     output => bus_out);
  -- U_TS8 : entity work.tristate
  --   port map (
  --     input  => A_reg,
  --     en     => sel(7),
  --     output => bus_out);
  -- U_TS9 : entity work.tristate
  --   port map (
  --     input  => ALU_in,
  --     en     => sel(8),
  --     output => bus_out);


  bus_out <= SP_reg_low when (sel = SP_LOW_SEL) else
              SP_reg_high when (sel = SP_HIGH_SEL) else
              X_reg_low when (sel = X_LOW_SEL) else
              X_reg_high when (sel = X_HIGH_SEL) else
              PC_reg_low when (sel = PC_LOW_SEL) else
              PC_reg_high when (sel = PC_HIGH_SEL) else
              D_reg when (sel = D_SEL) else
              A_reg when (sel = A_SEL) else
              ALU_in when (sel = ALU_IN_SEL) else
              reg_in when (sel = EBUS_INTO_IBUS_SEL) else
              AR_reg_low when (sel = AR_LOW_SEL) else
              AR_reg_high when (sel = AR_HIGH_SEL) else
              MULT_reg_low when (sel = MULTAD_LOW_SEL) else
              MULT_reg_high when (sel = MULTAD_HIGH_SEL) else
              (others => '-');
end architecture;
