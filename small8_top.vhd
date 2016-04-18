library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.libSM8.all;

entity small8_top is
  port (
    clock : in std_logic;
    rst : in std_logic;

    input1 : in std_logic_vector(CPU_WIDTH-1 downto 0);
    input1_en : in std_logic;
    input2_en : in std_logic;

    led0    : out std_logic_vector(6 downto 0);
    led1    : out std_logic_vector(6 downto 0);
    led2    : out std_logic_vector(6 downto 0);
    led3    : out std_logic_vector(6 downto 0)
  );
end entity;

architecture arch of small8_top is
  signal global_rst : std_logic;
  signal lt_input1_en : std_logic;
  signal lt_input2_en : std_logic;

  signal output1 : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal output2 : std_logic_vector(CPU_WIDTH-1 downto 0);

  signal opcode : std_logic_vector(CPU_WIDTH-1 downto 0);

  signal externalbus_sel : std_logic_vector(1 downto 0);
  signal internalbus_sel : std_logic_vector(3 downto 0);
  signal addr_bus_sel : std_logic_vector(1 downto 0);

  signal addr_en : std_logic_vector(1 downto 0);
  signal pc_en : std_logic_vector(1 downto 0);
  signal sp_en : std_logic_vector(1 downto 0);
  signal x_en : std_logic_vector(1 downto 0);
  signal mult_en : std_logic_vector(1 downto 0);
  signal ir_en : std_logic;
  signal d_en : std_logic;
  signal a_en : std_logic;
  signal cvzs_en : std_logic_vector(3 downto 0);
  signal internal_to_external_en : std_logic;
  signal external_to_internal_en : std_logic;

  signal pc_inc : std_logic;
  signal x_inc : std_logic;
  signal sp_inc : std_logic;
  signal x_inc00_dec10_b11 : std_logic_vector(1 downto 0);
  signal sp_inc0_dec1 : std_logic;

  signal set_C : std_logic;
  signal clr_C : std_logic;

  signal output1_en : std_logic;
  signal output2_en : std_logic;

  signal addr_bus_low : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal addr_bus_high : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal addr_bus : std_logic_vector(15 downto 0);

  signal cin_toCTRL : std_logic;
  signal V_fromCVZS : std_logic;
  signal Z_fromCZVS : std_logic;
  signal S_fromCZVS : std_logic;

  signal wren : std_logic;
  signal reset_global : std_logic;

  signal ir_instruct : std_logic_vector(CPU_WIDTH-1 downto 0);

  signal clk_to_everything_else : std_logic;
begin

  addr_bus <= std_logic_vector(addr_bus_high&addr_bus_low);

  lt_input1_en <= not input1_en;
  lt_input2_en <= not input2_en;

  global_rst <= not rst;

  U_LED3 : entity work.decoder7seg port map (
        input  => output2(7 downto 4),
        output => led3);

  U_LED2 : entity work.decoder7seg port map (
      input  => output2(3 downto 0),
      output => led2);

  U_LED1 : entity work.decoder7seg port map (
      input  => output1(7 downto 4),
      output => led1);

  U_LED0 : entity work.decoder7seg port map (
      input  => output1(3 downto 0),
      output => led0);

  U_CLKDIV : entity work.clk_div
    generic map(clk_in_freq => 2, clk_out_freq => 1)
    port map(
      clk_in => clock,
      clk_out => clk_to_everything_else,
      rst => global_rst
    );

  U_CONTROLLER : entity work.controller
    port map(
      clock => clk_to_everything_else,
      rst => global_rst,
      C => cin_toCTRL,
      V => V_fromCVZS,
      Z => Z_fromCZVS,
      S => S_fromCZVS,
      address_bus => addr_bus,
      instruction => ir_instruct,
      opcode => opcode,
      mult_en => mult_en,
      addr_en => addr_en,
      pc_en => pc_en,
      sp_en => sp_en,
      x_en => x_en,
      ir_en => ir_en,
      d_en => d_en,
      a_en => a_en,
      internal_to_external_en => internal_to_external_en,
      external_to_internal_en => external_to_internal_en,
      cvzs_en => cvzs_en,
      pc_inc => pc_inc,
      x_inc => x_inc,
      x_inc00_dec10_b11 => x_inc00_dec10_b11,
      sp_inc => sp_inc,
      sp_inc0_dec1 => sp_inc0_dec1,
      set_C => set_C,
      clr_C => clr_C,
      internal_bus_select => internalbus_sel,
      external_bus_select => externalbus_sel,
      output0_en => output1_en,
      output1_en => output2_en,
      reset_global => open,
      wren => wren,
      addr_bus_sel => addr_bus_sel
    );
  -- component to the architecture
  U_DATAPATH : entity work.datapath
    port map(
      clock => clk_to_everything_else,
      ram_clock => clock,
      rst => global_rst,
      mult_en => mult_en,
      addr_en => addr_en,
      pc_en => pc_en,
      sp_en => sp_en,
      x_en => x_en,
      ir_en => ir_en,
      d_en => d_en,
      a_en => a_en,
      cvzs_en => cvzs_en,
      external_bus_select => externalbus_sel,
      internal_bus_select => internalbus_sel,
      input0_en => lt_input1_en,
      input1_en => lt_input2_en,
      output0_en => output1_en,
      output1_en => output2_en,
      output0_rst => global_rst,
      output1_rst => global_rst,
      alu_opcode => opcode,
      input0_in => input1,
      output0_out => output1,
      output1_out => output2,
      set_C => set_C,
      clr_C => clr_C,
      output_address_bus_low => addr_bus_low,
      output_address_bus_high => addr_bus_high,
      wren => wren,
      pc_mux_sel => pc_inc,
      x_mux_sel => x_inc,
      sp_mux_sel => sp_inc,
      sp_inc0_dec1 => sp_inc0_dec1,
      x_inc00_dec10_b11 => x_inc00_dec10_b11,
      cin_toCTRL => cin_toCTRL,
      V_fromCVZS => V_fromCVZS,
      Z_fromCZVS => Z_fromCZVS,
      S_fromCZVS => S_fromCZVS,
      ir_reg_intermediate_instruction => ir_instruct,
      addr_bus_sel => addr_bus_sel,
      internal_to_external_en => internal_to_external_en,
      external_to_internal_en => external_to_internal_en
    );

end architecture;
