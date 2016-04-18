-- Jayson Salkey
-- Internal Architecture of Small 8 (Datapath)
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.libSM8.all;

entity datapath is
  port (
    clock : in std_logic;
    rst : in std_logic;
    ram_clock : in std_logic;
    -- Register Enables from Controller
    addr_en : in std_logic_vector(1 downto 0);
    pc_en : in std_logic_vector(1 downto 0);
    sp_en : in std_logic_vector(1 downto 0);
    x_en : in std_logic_vector(1 downto 0);
    mult_en : in std_logic_vector(1 downto 0);
    ir_en : in std_logic;
    d_en : in std_logic;
    a_en : in std_logic;
    cvzs_en : in std_logic_vector(3 downto 0);

    -- Set for Carry from Controller?
    set_C : in std_logic;
    clr_C : in std_logic;

    --address registers out
    output_address_bus_low : out std_logic_vector(CPU_WIDTH-1 downto 0);
    output_address_bus_high : out std_logic_vector(CPU_WIDTH-1 downto 0);

    -- ALU opcode
    alu_opcode : in std_logic_vector(CPU_WIDTH-1 downto 0);

    -- Bus Selects
    internal_bus_select : in std_logic_vector(3 downto 0);
    external_bus_select : in std_logic_vector(1 downto 0);
    addr_bus_sel  : in std_logic_vector(1 downto 0);
    x_inc00_dec10_b11 : in std_logic_vector(1 downto 0);
    sp_inc0_dec1 : in std_logic;


    -- i/o controls
    input0_en : in std_logic;
    input1_en : in std_logic;
    output0_en : in std_logic;
    output1_en : in std_logic;
    output0_rst : in std_logic;
    output1_rst : in std_logic;

    -- Read and Write Enable from Controller
    wren : in std_logic;

    -- PC mux sel
    pc_mux_sel : in std_logic;

    -- X mux sel
    x_mux_sel : in std_logic;

    -- SP mux sel
    sp_mux_sel : in std_logic;

    internal_to_external_en : in std_logic;
    external_to_internal_en : in std_logic;

    -- register ins and outs for io port
    input0_in : in std_logic_vector(CPU_WIDTH-1 downto 0);
    output0_out : out std_logic_vector(CPU_WIDTH-1 downto 0);
    output1_out : out std_logic_vector(CPU_WIDTH-1 downto 0);

    --cin_toALU : out std_logic;
    cin_toCTRL : out std_logic;
    V_fromCVZS : out std_logic;
    Z_fromCZVS : out std_logic;
    S_fromCZVS : out std_logic;

    ir_reg_intermediate_instruction : out std_logic_vector(CPU_WIDTH-1 downto 0)

  );
end entity;

architecture arch of datapath is

  -- Intermediate Register Signals
  signal multAD : std_logic_vector((2*CPU_WIDTH)-1 downto 0);
  signal multAD_low_to_D : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal multAD_high_to_A : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal a_reg_intermediate : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal d_reg_intermediate : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal addr_low_reg_intermediate : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal addr_high_reg_intermediate : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal pc_low_reg_intermediate : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal pc_high_reg_intermediate : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal pc_register_immediate_plusOne : std_logic_vector((2*CPU_WIDTH)-1 downto 0);
  signal sp_low_reg_intermediate : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal sp_high_reg_intermediate : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal sp_register_immediate : std_logic_vector((2*CPU_WIDTH)-1 downto 0);
  signal sp_register_original : std_logic_vector((2*CPU_WIDTH)-1 downto 0);
  signal x_low_reg_intermediate : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal x_high_reg_intermediate : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal x_register_immediate : std_logic_vector((2*CPU_WIDTH)-1 downto 0);
  signal internal_bus_out : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal internal_bus_reg_out : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal external_bus_out : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal external_bus_reg_out : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal alu_output : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal input0_out_intermediate_to_externalBus : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal input1_out_intermediate_to_externalBus : std_logic_vector(CPU_WIDTH-1 downto 0);

  signal ram_data_out : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal pc_mux_out1 : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal pc_mux_out2 : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal x_mux_out1 : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal x_mux_out2 : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal sp_mux_out1 : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal sp_mux_out2 : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal output_address_bus : std_logic_vector(15 downto 0);

  signal cout : std_logic;
  signal signb : std_logic;
  signal zero : std_logic;
  signal overflow : std_logic;

  signal cin_toALU : std_logic;
begin

  cin_toCTRL <= cin_toALU;

  output_address_bus_low <= addr_low_reg_intermediate;
  output_address_bus_high <= addr_high_reg_intermediate;
  output_address_bus <= std_logic_vector(addr_high_reg_intermediate&addr_low_reg_intermediate) when (addr_bus_sel = "00") else
                        x_register_immediate when (addr_bus_sel = "01") else
                        sp_register_original when (addr_bus_sel = "10") else
                        std_logic_vector(pc_high_reg_intermediate&pc_low_reg_intermediate);

  pc_register_immediate_plusOne <= std_logic_vector(unsigned(pc_high_reg_intermediate&pc_low_reg_intermediate) + 1);
  x_register_immediate <= std_logic_vector(unsigned(x_high_reg_intermediate&x_low_reg_intermediate) + 1) when (x_inc00_dec10_b11 = "00") else
                          std_logic_vector(unsigned(x_high_reg_intermediate&x_low_reg_intermediate) - 1) when (x_inc00_dec10_b11 = "01") else
                          std_logic_vector(unsigned(x_high_reg_intermediate&x_low_reg_intermediate) + unsigned(internal_bus_out));

  sp_register_immediate <= std_logic_vector(unsigned(sp_high_reg_intermediate&sp_low_reg_intermediate) + 1) when (sp_inc0_dec1 = '0') else
                          std_logic_vector(unsigned(sp_high_reg_intermediate&sp_low_reg_intermediate) - 1);
  sp_register_original <= std_logic_vector(sp_high_reg_intermediate&sp_low_reg_intermediate);

  multAD <= std_logic_vector(unsigned(a_reg_intermediate)*unsigned(d_reg_intermediate));
  U_RAM : entity work.ram_small8
    port map(
      address => output_address_bus(8 downto 0),
      clock => ram_clock,
      data => external_bus_out,
      wren => wren,
      q => ram_data_out
    );

  -- IOPORT BITCH
  U_IOPORT : entity work.ioport
    port map(
      clk => clock,
      rst => rst,
      input0_en => input0_en,
      input1_en => input1_en,
      output0_en => output0_en,
      output1_en => output1_en,
      output0_rst => output0_rst,
      output1_rst => output1_rst,
      input0_out => input0_out_intermediate_to_externalBus,
      input1_out => input1_out_intermediate_to_externalBus,
      input0_in => input0_in,
      input1_in => input0_in,
      output0_out => output0_out,
      output1_out => output1_out,
      output0_in => external_bus_out,
      output1_in => external_bus_out
    );

  -- Connection between buses
  U_EXTERNAL_TO_INTERNAL : entity work.reg
    port map(
      clock => clock,
      rst => rst,
      d => external_bus_out,
      en => external_to_internal_en,
      q => internal_bus_reg_out
    );

  U_INTERNAL_TO_EXTERNAL : entity work.reg
    port map(
      clock => clock,
      rst => rst,
      d => internal_bus_out,
      en => internal_to_external_en,
      q => external_bus_reg_out
    );

  -- Data buses
  U_EXTERNAL_DATA_BUS : entity work.externaldatabus
    port map(
      reg_in => external_bus_reg_out,
      sel => external_bus_select,
      mem_d => ram_data_out, -- remember to change
      input0 => input0_out_intermediate_to_externalBus,
      input1 => input1_out_intermediate_to_externalBus,
      bus_out => external_bus_out
    );

  U_INTERNAL_DATA_BUS : entity work.internaldatabus
    port map(
      MULT_reg_low => multAD_low_to_D,
      MULT_reg_high => multAD_high_to_A,
      AR_reg_low => addr_low_reg_intermediate,
      AR_reg_high => addr_high_reg_intermediate,
      reg_in => internal_bus_reg_out,
      SP_reg_low => sp_low_reg_intermediate,
      SP_reg_high => sp_high_reg_intermediate,
      X_reg_low => x_low_reg_intermediate,
      X_reg_high => x_high_reg_intermediate,
      PC_reg_low => pc_low_reg_intermediate,
      PC_reg_high => pc_high_reg_intermediate,
      D_reg => d_reg_intermediate,
      A_reg => a_reg_intermediate,
      ALU_in => alu_output,
      sel => internal_bus_select,
      bus_out => internal_bus_out
    );

  -- instantiate all registers
  U_MULT_REG : entity work.reg_16_sepld
    port map(
      clock => clock,
      rst => rst,
      d0 => multAD(7 downto 0),
      d1 => multAD(15 downto 8),
      l_ld => mult_en(0),
      h_ld => mult_en(1),
      q0 => multAD_low_to_D,
      q1 => multAD_high_to_A
    );

  U_ADDR_REG : entity work.reg_16_sepld
    port map(
      clock => clock,
      rst => rst,
      d0 => internal_bus_out,
      d1 => internal_bus_out,
      l_ld => addr_en(0),
      h_ld => addr_en(1),
      q0 => addr_low_reg_intermediate,
      q1 => addr_high_reg_intermediate
    );

  U_PC_MUX : entity work.mux_2x1
    port map(
      in1 => internal_bus_out,
      in2 => internal_bus_out,
      in3 => pc_register_immediate_plusOne,
      sel => pc_mux_sel,
      output1 => pc_mux_out1,
      output2 => pc_mux_out2
    );
  U_PC_REG : entity work.reg_16_sepld
    port map(
      clock => clock,
      rst => rst,
      d0 => pc_mux_out1,
      d1 => pc_mux_out2,
      l_ld => pc_en(0),
      h_ld => pc_en(1),
      q0 => pc_low_reg_intermediate,
      q1 => pc_high_reg_intermediate
    );
  U_SP_MUX : entity work.mux_2x1
    port map(
      in1 => internal_bus_out,
      in2 => internal_bus_out,
      in3 => sp_register_immediate,
      sel => sp_mux_sel,
      output1 => sp_mux_out1,
      output2 => sp_mux_out2
    );
  U_SP_REG : entity work.reg_16_sepld
    port map(
      clock => clock,
      rst => rst,
      d0 => sp_mux_out1,
      d1 => sp_mux_out2,
      l_ld => sp_en(0),
      h_ld => sp_en(1),
      q0 => sp_low_reg_intermediate,
      q1 => sp_high_reg_intermediate
    );
  U_X_MUX : entity work.mux_2x1
    port map(
      in1 => internal_bus_out,
      in2 => internal_bus_out,
      in3 => x_register_immediate,
      sel => x_mux_sel,
      output1 => x_mux_out1,
      output2 => x_mux_out2
    );
  U_X_REG : entity work.reg_16_sepld
    port map(
      clock => clock,
      rst => rst,
      d0 => x_mux_out1,
      d1 => x_mux_out2,
      l_ld => x_en(0),
      h_ld => x_en(1),
      q0 => x_low_reg_intermediate,
      q1 => x_high_reg_intermediate
    );
  U_IR_REG : entity work.reg
    generic map(width => 8)
    port map(
      clock => clock,
      rst => rst,
      en => ir_en,
      d => internal_bus_out,
      q => ir_reg_intermediate_instruction
    );
  U_D_REG : entity work.reg
    generic map(width => 8)
    port map(
      clock => clock,
      rst => rst,
      en => d_en,
      d => internal_bus_out,
      q => d_reg_intermediate
    );
  U_A_REG : entity work.reg
    generic map(width => 8)
    port map(
      clock => clock,
      rst => rst,
      en => a_en,
      d => internal_bus_out,
      q => a_reg_intermediate
    );

  U_CVSZ_REG : entity work.reg_CVZS
    port map(
      clock => clock,
      rst => rst,
      setc => set_C,
      clrc => clr_C,
      cen => cvzs_en(3),
      ven => cvzs_en(2),
      zen => cvzs_en(1),
      sen => cvzs_en(0),
      ff_C => cin_toALU,
      ff_V => V_fromCVZS,
      ff_Z => Z_fromCZVS,
      ff_S => S_fromCZVS,
      C => cout,
      V => overflow,
      Z => zero,
      S => signb
    );

  -- instantiate the ALU
  U_ALU : entity work.alu
    port map(
      cin => cin_toALU, -- only status flag register?
      D => d_reg_intermediate,
      A => a_reg_intermediate,
      opcode => alu_opcode, -- opcode comes from controller?
      result => alu_output,
      C => cout,
      V => overflow,
      Z => zero,
      S => signb
    );

end architecture;
