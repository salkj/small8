-- Jayson Salkey
-- IO port
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.libSM8.all;


entity ioport is
  port (
    -- register enables from controller
    input0_en : in std_logic;
    input1_en : in std_logic;
    output0_en : in std_logic;
    output1_en : in std_logic;
    clk : in std_logic;
    rst : in std_logic; -- for the reset of CPU and Memory
    output0_rst : in std_logic;
    output1_rst : in std_logic;
    -- to externaldatabus
    input0_out : out std_logic_vector(CPU_WIDTH-1 downto 0);
    input1_out : out std_logic_vector(CPU_WIDTH-1 downto 0);
    -- external switches
    input0_in : in std_logic_vector(CPU_WIDTH-1 downto 0);
    input1_in : in std_logic_vector(CPU_WIDTH-1 downto 0);

    --extbus : in std_logic_vector(CPU_WIDTH-1 downto 0);

    -- to outside
    output0_out : out std_logic_vector(CPU_WIDTH-1 downto 0);
    output1_out : out std_logic_vector(CPU_WIDTH-1 downto 0);
    -- from externaldatabus
    output0_in : in std_logic_vector(CPU_WIDTH-1 downto 0);
    output1_in : in std_logic_vector(CPU_WIDTH-1 downto 0)

  );
end entity;

architecture arch of ioport is

begin

  -- outport registers
  OUTPORT0 : entity work.reg
    port map(
      clock => clk,
      rst => output0_rst, -- fill this in
      en => output0_en,
      d => output0_in,
      q => output0_out
    );
  OUTPORT1 : entity work.reg
    port map(
      clock => clk,
      rst => output1_rst, -- fill this in
      en => output1_en,
      d => output1_in,
      q => output1_out
    );
  -- inport registers
  INPORT0 : entity work.reg
    port map(
      clock => clk,
      rst => '0', -- fill this in
      en => input0_en,
      d => input0_in,
      q => input0_out
    );
  INPORT1 : entity work.reg
    port map(
      clock => clk,
      rst => '0', -- fill this in
      en => input1_en,
      d => input1_in,
      q => input1_out
    );
end architecture;
