-- Jayson Salkey
-- DataPath Test Bench
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.libSM8.all;


entity datapath_tb is
end entity;

architecture arch of datapath_tb is

  signal clock : std_logic := '0';
  signal rst : std_logic := '1';

  signal opcode : std_logic_vector(CPU_WIDTH-1 downto 0) := (others => '0');
  signal cin : std_logic := '0';

  signal externalbus_sel : std_logic_vector(1 downto 0) := (others => '0');
  signal internalbus_sel : std_logic_vector(3 downto 0) := (others => '0');
  signal addr_bus_sel : std_logic_vector(1 downto 0) := "00";

  signal addr_en : std_logic_vector(1 downto 0) := (others => '0');
  signal pc_en : std_logic_vector(1 downto 0) := (others => '0');
  signal sp_en : std_logic_vector(1 downto 0) := (others => '0');
  signal x_en : std_logic_vector(1 downto 0) := (others => '0');
  signal ir_en : std_logic := '0';
  signal d_en : std_logic := '0';
  signal a_en : std_logic := '0';
  signal cvzs_en : std_logic_vector(3 downto 0) := (others => '0');

  signal stat_reg : std_logic_vector(3 downto 0) := (others => '0');
  signal instruction : std_logic_vector(CPU_WIDTH-1 downto 0) := (others => '0');

  signal input1 : std_logic_vector(CPU_WIDTH-1 downto 0) := (others => '0');
  signal input2 : std_logic_vector(CPU_WIDTH-1 downto 0) := (others => '0');
  signal input1_en : std_logic := '0';
  signal input2_en : std_logic := '0';

  signal output1 : std_logic_vector(CPU_WIDTH-1 downto 0) := (others => '0');
  signal output2 : std_logic_vector(CPU_WIDTH-1 downto 0) := (others => '0');
  signal output1_en : std_logic := '0';
  signal output2_en : std_logic := '0';

  signal addr_bus_low : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal addr_bus_high : std_logic_vector(CPU_WIDTH-1 downto 0);

  signal cin_toCTRL : std_logic;
  signal V_fromCVZS : std_logic;
  signal Z_fromCZVS : std_logic;
  signal S_fromCZVS : std_logic;


begin

  U_DATAPATH_TB : entity work.datapath
    port map(
      clock => clock,
      ram_clock => clock,
      rst => rst,
      internal_to_external_en => '1',
      external_to_internal_en => '1',
      mult_en => "00",
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
      input0_en => input1_en,
      input1_en => input2_en,
      output0_en => output1_en,
      output1_en => output2_en,
      output0_rst => rst,
      output1_rst => rst,
      alu_opcode => opcode,
      input0_in => input1,
      output0_out => output1,
      output1_out => output2,
      set_C => '0',
      clr_C => '0',
      output_address_bus_low => addr_bus_low,
      output_address_bus_high => addr_bus_high,
      wren => '0',
      pc_mux_sel => '0',
      x_mux_sel => '0',
      x_inc00_dec10_b11 => "00",
      sp_inc0_dec1 => '0',
      sp_mux_sel => '0',
      cin_toCTRL => cin_toCTRL,
      V_fromCVZS => V_fromCVZS,
      Z_fromCZVS => Z_fromCZVS,
      S_fromCZVS => S_fromCZVS,
      ir_reg_intermediate_instruction => instruction,
      addr_bus_sel => addr_bus_sel
    );

    clock <= not clock after 20 ns;

    process
      begin

        rst <= '0';
        wait for 20 ns;

        input1_en <= '1';
        input2_en <= '1';

        input1 <= "00001111";
        input2 <= "00001001";
        wait for 40 ns;

        externalbus_sel <= EXT_IN0_SEL;
        internalbus_sel <= EBUS_INTO_IBUS_SEL;

        wait until rising_edge(clock);

        a_en <= '1';
        d_en <= '1';
        cvzs_en <= "1111";
        addr_en <= "01";
        pc_en <= "01";
        sp_en <= "01";
        x_en <= "01";
        ir_en <= '1';

        wait until rising_edge(clock);

        internalbus_sel <= ALU_IN_SEL;
        externalbus_sel <= IBUS_INTO_EBUS_SEL;
        a_en <= '0';
        d_en <= '0';
        opcode <= ADCR;

        wait until rising_edge(clock);
        output1_en <= '1';
        output2_en <= '1';


    end process;
end architecture;
