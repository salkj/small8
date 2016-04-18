-- Jayson Salkey
-- Controller VHD

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.libSM8.all;


entity controller is
  port (
  clock : in std_logic;
  rst : in std_logic;

  C : in std_logic;
  V : in std_logic;
  Z : in std_logic;
  S : in std_logic;

  address_bus : in std_logic_vector(15 downto 0);

  instruction : in std_logic_vector(CPU_WIDTH-1 downto 0);
  opcode : out std_logic_vector(CPU_WIDTH-1 downto 0);

  mult_en : out std_logic_vector(1 downto 0);
  addr_en : out std_logic_vector(1 downto 0);
  pc_en : out std_logic_vector(1 downto 0);
  sp_en : out std_logic_vector(1 downto 0);
  x_en : out std_logic_vector(1 downto 0);
  ir_en : out std_logic;
  d_en : out std_logic;
  a_en : out std_logic;
  cvzs_en : out std_logic_vector(3 downto 0);
  internal_to_external_en : out std_logic;
  external_to_internal_en : out std_logic;

  -- Increment registers
  pc_inc : out std_logic;
  x_inc : out std_logic;
  x_inc00_dec10_b11 : out std_logic_vector(1 downto 0);
  sp_inc : out std_logic;
  sp_inc0_dec1 : out std_logic;

  -- Set for Carry from Controller?
  set_C : out std_logic;
  clr_C : out std_logic;

  -- Bus Selects
  internal_bus_select : out std_logic_vector(3 downto 0);
  external_bus_select : out std_logic_vector(1 downto 0);
  addr_bus_sel : out std_logic_vector(1 downto 0);

  -- i/o controls
  output0_en : out std_logic;
  output1_en : out std_logic;

  -- Read Write Horseshit
  wren : out std_logic;

  -- Global Reset
  reset_global : out std_logic
  );
end entity;

architecture arch of controller is

  type STATE_TYPE is (INIT_SMALL8, OPCODE_FETCH_0, OPCODE_FETCH_1, DECODE,
  LDAI_s0, LDAI_s1,
  LDAA_s0, LDAA_s1, LDAA_s2, LDAA_s4, LDAA_s5,
  LDAD_s0, LDAD_s1,
  LDSI_s0, LDSI_s1, LDSI_s2, LDSI_s4, LDSI_s5,
  LDXI_s0, LDXI_s1, LDXI_s2, LDXI_s4, LDXI_s5,
  LDAA_idx_s0, LDAA_idx_s1, LDAA_idx_s2,
  STAA_s0, STAA_s1, STAA_s2, STAA_s4, STAA_s5, STAA_s6,
  STAR_s0, STAR_s1,
  ADCR_s0, ADCR_s1,
  SBCR_s0, SBCR_s1,
  CMPR_s0, CMPR_s1,
  ANDR_s0, ANDR_s1,
  ORR_s0, ORR_s1,
  XORR_s0, XORR_s1,
  SLRL_s0, SLRL_s1,
  SRRL_s0, SRRL_s1,
  ROLC_s0, ROLC_s1,
  RORC_s0, RORC_s1,
  BCCA_s0,
  BCSA_s0,
  BEQA_s0, BEQA_taken_s0, BEQA_taken_s2, BEQA_taken_s3, BEQA_taken_s4, BEQA_taken_s0_wait, BEQA_MISSED_0, BEQA_MISSED_1,
  BMIA_s0,
  BNEA_s0,
  BPLA_s0,
  BVCA_s0,
  BVSA_s0,
  DECA_s0,
  INCA_s0,
  SETC_s0,
  CLRC_s0,
  STAA_idx_s0, STAA_idx_s1, STAA_idx_s6,
  DECX_s0,
  INCX_s0,
  RET_s0, RET_s1, RET_s2, RET_s3, RET_s4,
  CALL_s0, CALL_s1, CALL_s2, CALL_s3, CALL_s4, CALL_s5, CALL_s6, CALL_WAIT,
  MULT_s0, MULT_s1, MULT_s2
  );
  signal state, next_state : STATE_TYPE;
begin

    process(clock,rst)
    begin
      if(rst = '1') then
        state <= INIT_SMALL8;
      elsif (rising_edge(clock)) then
        state <= next_state;
      end if;
    end process;

    -- maybe along with instruction and status
    process(state, instruction)
    begin
      next_state <= state;

      internal_bus_select <= EBUS_INTO_IBUS_SEL;
      external_bus_select <= MEM_SEL;
      addr_bus_sel <= "11";

      internal_to_external_en <= '1';
      external_to_internal_en <= '1';
      addr_en <= "00";
      pc_en <= "00";
      sp_en <= "00";
      x_en <= "00";
      mult_en <= "00";
      ir_en <= '0';
      d_en <= '0';
      a_en <= '0';
      cvzs_en <= "0000";
      wren <= '0';
      set_C <= '0';
      clr_C <= '0';

      pc_inc <= '0';
      x_inc <= '0';
      x_inc00_dec10_b11 <= "00";
      sp_inc <= '0';
      sp_inc0_dec1 <= '0';

      output0_en <= '0';
      output1_en <= '0';

      opcode <= NO_OP;
      case state is
        when INIT_SMALL8 =>
          next_state <= OPCODE_FETCH_0;

        when OPCODE_FETCH_0 =>

          next_state <= OPCODE_FETCH_1;

        when OPCODE_FETCH_1 =>
          -- the enable is synchronous
          -- starts with instruction
          ir_en <= '1'; -- all others are not enabled so wont take in
          internal_bus_select <= EBUS_INTO_IBUS_SEL;
          pc_inc <= '1';
          pc_en <= "11";
          next_state <= DECODE;

        when DECODE =>
         -- mem[PC] means the value at the address PC
          case(instruction) is
            when (LDAI) =>
              next_state <= LDAI_s0;
            when (LDAA) =>
              next_state <= LDAA_s0;
            when (LDAD) =>
              next_state <= LDAD_s0;
            when (LDSI) =>
              next_state <= LDSI_s0;
            when (LDXI) =>
              next_state <= LDXI_s0;
            when (LDAA_idx) =>
              next_state <= LDAA_idx_s0;
            when (STAA) =>
              next_state <= STAA_s0;
            when (STAR) =>
              next_state <= STAR_s0;
            when (ADCR) =>
              next_state <= ADCR_s0;
            when (SBCR) =>
              next_state <= SBCR_s0;
            when (CMPR) =>
              next_state <= CMPR_s0;
            when (ANDR) =>
              next_state <= ANDR_s0;
            when (ORR) =>
              next_state <= ORR_s0;
            when (XORR) =>
              next_state <= XORR_s0;
            when (SLRL) =>
              next_state <= SLRL_s0;
            when (SRRL) =>
              next_state <= SRRL_s0;
            when (ROLC) =>
              next_state <= ROLC_s0;
            when (RORC) =>
              next_state <= RORC_s0;
            when (BCCA) =>
              next_state <= BCCA_s0;
            when (BCSA) =>
              next_state <= BCSA_s0;
            when (BEQA) =>
              next_state <= BEQA_s0;
            when (BMIA) =>
              next_state <= BMIA_s0;
            when (BNEA) =>
              next_state <= BNEA_s0;
            when (BPLA) =>
              next_state <= BPLA_s0;
            when (BVCA) =>
              next_state <= BVCA_s0;
            when (BVSA) =>
              next_state <= BVSA_s0;
            when (DECA) =>
              next_state <= DECA_s0;
            when (INCA) =>
              next_state <= INCA_s0;
            when (SETC) =>
              next_state <= SETC_s0;
            when (CLRC) =>
              next_state <= CLRC_s0;
            when (STAA_idx) =>
              next_state <= STAA_idx_s0;
            when (INCX) =>
              next_state <= INCX_s0;
            when (DECX) =>
              next_state <= DECX_s0;
            when (RET) =>
              next_state <= RET_s0;
            when (CALL) =>
              next_state <= CALL_s0;
            when (MULT) =>
              next_state <= MULT_s0;
            when others =>
              null;
          end case;

        when (ADCR_s0) =>
          opcode <= ADCR;
          cvzs_en <= "1111";
          internal_bus_select <= ALU_IN_SEL;
          a_en <= '1';
          next_state <= ADCR_s1;
        when (ADCR_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (SBCR_s0) =>
          opcode <= SBCR;
          cvzs_en <= "1111";
          internal_bus_select <= ALU_IN_SEL;
          a_en <= '1';
          next_state <= SBCR_s1;
        when (SBCR_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (CMPR_s0) =>
          opcode <= CMPR;
          cvzs_en <= "1111";
          internal_bus_select <= ALU_IN_SEL;
          a_en <= '0';
          next_state <= CMPR_s1;
        when (CMPR_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (ANDR_s0) =>
          a_en <= '1';
          internal_bus_select <= ALU_IN_SEL;
          opcode <= ANDR;
          cvzs_en <= "1111";
          next_state <= ANDR_s1;
        when (ANDR_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (ORR_s0) =>
          a_en <= '1';
          internal_bus_select <= ALU_IN_SEL;
          opcode <= ORR;
          cvzs_en <= "1111";
          next_state <= ORR_s1;
        when (ORR_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (XORR_s0) =>
          a_en <= '1';
          internal_bus_select <= ALU_IN_SEL;
          opcode <= XORR;
          cvzs_en <= "1111";
          next_state <= XORR_s1;
        when (XORR_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (SLRL_s0) =>
          a_en <= '1';
          internal_bus_select <= ALU_IN_SEL;
          opcode <= SLRL;
          cvzs_en <= "1111";
          next_state <= SLRL_s1;
        when (SLRL_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (SRRL_s0) =>
          a_en <= '1';
          internal_bus_select <= ALU_IN_SEL;
          opcode <= SRRL;
          cvzs_en <= "1111";
          next_state <= SRRL_s1;
        when (SRRL_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (ROLC_s0) =>
          a_en <= '1';
          internal_bus_select <= ALU_IN_SEL;
          opcode <= ROLC;
          cvzs_en <= "1111";
          next_state <= ROLC_s1;
        when (ROLC_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (RORC_s0) =>
          a_en <= '1';
          internal_bus_select <= ALU_IN_SEL;
          opcode <= RORC;
          cvzs_en <= "1111";
          next_state <= RORC_s1;
        when (RORC_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (LDAI_s0) =>
          pc_inc <= '1';
          pc_en <= "11";
          a_en <= '1';
          next_state <= LDAI_s1;
        when (LDAI_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (LDAD_s0) =>
          internal_bus_select <= D_SEL;
          a_en <= '1';
          next_state <= LDAD_s1;
        when (LDAD_s1) =>
          -- won't change cuz nothing is incrementing
          next_state <= OPCODE_FETCH_0;

        when (STAA_s0) =>
          -- low byte
          pc_inc <= '1';
          pc_en <= "11";
          addr_en <= "01";
          next_state <= STAA_s1;
        when (STAA_s1) =>
          -- high byte
          pc_inc <= '1';
          pc_en <= "11";
          next_state <= STAA_s2;
        when (STAA_s2) =>
          addr_en <= "10";
          next_state <= STAA_s4;
        when (STAA_s4) =>
          internal_bus_select <= A_SEL;
          next_state <= STAA_s5;
        when (STAA_s5) =>
          addr_bus_sel <= "00";
          external_bus_select <= IBUS_INTO_EBUS_SEL;
          if(address_bus = x"FFFE") then -- output 0
            wren <= '0';
            output0_en <= '1';
          elsif(address_bus = x"FFFF") then -- output 1
            wren <= '0';
            output1_en <= '1';
          else
            wren <= '1';
          end if;
          -- on this state a q is what we want since en is synchronous
          next_state <= STAA_s6;
        when (STAA_s6) =>
          next_state <= OPCODE_FETCH_0;

        when (LDAA_s0) =>
          -- low byte
          pc_inc <= '1';
          pc_en <= "11";
          addr_en <= "01";
          next_state <= LDAA_s1;
        when (LDAA_s1) =>
          -- high byte
          pc_inc <= '1';
          pc_en <= "11";
          next_state <= LDAA_s2;
        when (LDAA_s2) =>
          addr_en <= "10";
          next_state <= LDAA_s4;
        when (LDAA_s4) =>
          addr_bus_sel <= "00";
          -- asynchronous load for inports
          if(address_bus = x"FFFE") then -- inport 0, make sure enables are right?
            external_bus_select <= EXT_IN0_SEL;
          elsif(address_bus = x"FFFF") then -- inport 1, make sure enables are right?
            external_bus_select <= EXT_IN1_SEL;
          end if;
          next_state <= LDAA_s5;
        when (LDAA_s5) =>
          a_en <= '1';
          -- on this state a q is what we want since en is synchronous
          next_state <= OPCODE_FETCH_0;

        when (STAR_s0) =>
          internal_bus_select <= A_SEL;
          d_en <= '1';
          next_state <= STAR_s1;
        when (STAR_s1) =>
          next_state <= OPCODE_FETCH_0;

        when (BEQA_s0) =>
          if(Z = '1') then
            pc_inc <= '1';
            pc_en <= "11";
            addr_en <= "01";
            next_state <= BEQA_taken_s0;
          else
            pc_inc <= '1'; -- should this
            pc_en <= "11"; -- be here
            next_state <= BEQA_MISSED_0;
          end if;
        when (BEQA_MISSED_0) =>
          pc_inc <= '1'; -- should this
          pc_en <= "11"; -- be here
          next_state <= BEQA_MISSED_1;
        when (BEQA_MISSED_1) =>
          next_state <= OPCODE_FETCH_0;
        when (BEQA_taken_s0) =>
          next_state <= BEQA_taken_s0_wait;
        when (BEQA_taken_s0_wait) =>
          addr_en <= "10";
          next_state <= BEQA_taken_s2;
        when (BEQA_taken_s2) =>
          internal_bus_select <= AR_LOW_SEL;
          pc_en <= "01";
          next_state <= BEQA_taken_s3;
        when (BEQA_taken_s3) =>
          internal_bus_select <= AR_HIGH_SEL;
          pc_en <= "10";
          next_state <= BEQA_taken_s4;
        when (BEQA_taken_s4) =>
          next_state <= OPCODE_FETCH_0;

        when (BMIA_s0) =>
          if(S = '1') then
            pc_inc <= '1';
            pc_en <= "11";
            addr_en <= "01";
            next_state <= BEQA_taken_s0;
          else
            pc_inc <= '1'; -- should this
            pc_en <= "11"; -- be here
            next_state <= BEQA_MISSED_0;
          end if;

        when (BNEA_s0) =>
          if(Z = '0') then
            pc_inc <= '1';
            pc_en <= "11";
            addr_en <= "01";
            next_state <= BEQA_taken_s0;
          else
            pc_inc <= '1'; -- should this
            pc_en <= "11"; -- be here
            next_state <= BEQA_MISSED_0;
          end if;

        when (BPLA_s0) =>
          if(S = '0') then
            pc_inc <= '1';
            pc_en <= "11";
            addr_en <= "01";
            next_state <= BEQA_taken_s0;
          else
            pc_inc <= '1'; -- should this
            pc_en <= "11"; -- be here
            next_state <= BEQA_MISSED_0;
          end if;

        when (BVCA_s0) =>
          if(V = '0') then
            pc_inc <= '1';
            pc_en <= "11";
            addr_en <= "01";
            next_state <= BEQA_taken_s0;
          else
            pc_inc <= '1'; -- should this
            pc_en <= "11"; -- be here
            next_state <= BEQA_MISSED_0;
          end if;

        when (BVSA_s0) =>
          if(V = '1') then
            pc_inc <= '1';
            pc_en <= "11";
            addr_en <= "01";
            next_state <= BEQA_taken_s0;
          else
            pc_inc <= '1'; -- should this
            pc_en <= "11"; -- be here
            next_state <= BEQA_MISSED_0;
          end if;

        when (BCCA_s0) =>
          if(C = '0') then
            pc_inc <= '1';
            pc_en <= "11";
            addr_en <= "01";
            next_state <= BEQA_taken_s0;
          else
            pc_inc <= '1'; -- should this
            pc_en <= "11"; -- be here
            next_state <= BEQA_MISSED_0;
          end if;

        when (BCSA_s0) =>
          if(C = '1') then
            pc_inc <= '1';
            pc_en <= "11";
            addr_en <= "01";
            next_state <= BEQA_taken_s0;
          else
            pc_inc <= '1'; -- should this
            pc_en <= "11"; -- be here
            next_state <= BEQA_MISSED_0;
          end if;

        when (DECA_s0) =>
          a_en <= '1';
          opcode <= DECA;
          cvzs_en <= "1111";
          internal_bus_select <= ALU_IN_SEL;
          next_state <= OPCODE_FETCH_0;

        when (INCA_s0) =>
          a_en <= '1';
          opcode <= INCA;
          cvzs_en <= "1111";
          internal_bus_select <= ALU_IN_SEL;
          next_state <= OPCODE_FETCH_0;

        when (SETC_s0) =>
          set_C <= '1';
          next_state <= OPCODE_FETCH_0;

        when (CLRC_s0) =>
          clr_C <= '1';
          next_state <= OPCODE_FETCH_0;

        when (LDSI_s0) =>
          -- low byte
          pc_inc <= '1';
          pc_en <= "11";
          sp_en <= "01";
          next_state <= LDSI_s1;
        when (LDSI_s1) =>
          -- high byte
          pc_inc <= '1';
          pc_en <= "11";
          next_state <= LDSI_s2;
        when (LDSI_s2) =>
          sp_en <= "10";
          next_state <= LDSI_s4;
        when (LDSI_s4) =>
          next_state <= LDSI_s5;
        when (LDSI_s5) =>
          -- on this state a q is what we want since en is synchronous
          next_state <= OPCODE_FETCH_0;

        when (LDXI_s0) =>
          -- low byte
          pc_inc <= '1';
          pc_en <= "11";
          x_en <= "01";
          next_state <= LDXI_s1;
        when (LDXI_s1) =>
          -- high byte
          pc_inc <= '1';
          pc_en <= "11";
          next_state <= LDXI_s2;
        when (LDXI_s2) =>
          x_en <= "10";
          next_state <= LDXI_s4;
        when (LDXI_s4) =>
          next_state <= LDXI_s5;
        when (LDXI_s5) =>
          next_state <= OPCODE_FETCH_0;

        when (LDAA_idx_s0) =>
          pc_inc <= '1';
          pc_en <= "11";
          next_state <= LDAA_idx_s1;
        when (LDAA_idx_s1) =>
          internal_bus_select <= EBUS_INTO_IBUS_SEL;
          x_inc00_dec10_b11 <= "11";
          addr_bus_sel <= "01";
          if(address_bus = x"FFFE") then -- inport 0, make sure enables are right?
            external_bus_select <= EXT_IN0_SEL;
          elsif(address_bus = x"FFFF") then
            external_bus_select <= EXT_IN1_SEL;
          end if;
          next_state <= LDAA_idx_s2;
        when (LDAA_idx_s2) =>
          a_en <= '1';
          next_state <= OPCODE_FETCH_0;

        when (STAA_idx_s0) =>
          internal_bus_select <= A_SEL;
          pc_inc <= '1';
          pc_en <= "11";
          next_state <= STAA_idx_s1;
        when (STAA_idx_s1) =>
          internal_to_external_en <= '0';
          external_bus_select <= IBUS_INTO_EBUS_SEL;
          internal_bus_select <= EBUS_INTO_IBUS_SEL;
          x_inc00_dec10_b11 <= "11";
          addr_bus_sel <= "01";

          if (address_bus = x"FFFE") then
            wren <= '0';
            output0_en <= '1';
          elsif (address_bus = x"FFFF") then
            wren <= '0';
            output1_en <= '1';
          else
            wren <= '1';
          end if;

          next_state <= STAA_idx_s6;
        when (STAA_idx_s6) =>
          next_state <= OPCODE_FETCH_0;

        when (CALL_s0) =>
          addr_en <= "01";
          pc_inc <= '1';
          pc_en <= "11";
          next_state <= CALL_s1;
        when (CALL_s1) =>
          pc_inc <= '1';
          pc_en <= "11";
          sp_inc <= '1';
          sp_en <= "11";
          sp_inc0_dec1 <= '1';
          next_state <= CALL_s2;
        when (CALL_s2) =>
          addr_en <= "10";
          next_state <= CALL_WAIT;
        when (CALL_WAIT) =>
          internal_bus_select <= PC_LOW_SEL;
          next_state <= CALL_s3;
        when (CALL_s3) =>
          external_bus_select <= IBUS_INTO_EBUS_SEL;
          addr_bus_sel <= "10";
          wren <= '1';
          sp_inc <= '1';
          sp_en <= "11";
          sp_inc0_dec1 <= '1';
          next_state <= CALL_s4;
        when (CALL_s4) =>
          internal_bus_select <= PC_HIGH_SEL;
          next_state <= CALL_s5;
        when (CALL_s5) =>
          external_bus_select <= IBUS_INTO_EBUS_SEL;
          addr_bus_sel <= "10";
          wren <= '1';
          next_state <= CALL_s6;
        when (CALL_s6) =>
          next_state <= BEQA_taken_s2;


        when (RET_s0) =>
          addr_bus_sel <= "10";
          next_state <= RET_s1;
        when (RET_s1) =>
          internal_bus_select <= EBUS_INTO_IBUS_SEL;
          pc_en <= "10";
          sp_inc <= '1';
          sp_en <= "11";
          sp_inc0_dec1 <= '0';
          next_state <= RET_s2;
        when (RET_s2) =>
          addr_bus_sel <= "10";
          next_state <= RET_s3;
        when (RET_s3) =>
          internal_bus_select <= EBUS_INTO_IBUS_SEL;
          pc_en <= "01";
          sp_inc <= '1';
          sp_en <= "11";
          sp_inc0_dec1 <= '0';
          next_state <= RET_s4;
        when (RET_s4) =>
          next_state <= OPCODE_FETCH_0;

        when (INCX_s0) =>
          x_inc <= '1';
          x_en <= "11";
          x_inc00_dec10_b11 <= "00";
          next_state <= OPCODE_FETCH_0;

        when (DECX_s0) =>
          x_inc <= '1';
          x_en <= "11";
          x_inc00_dec10_b11 <= "01";
          next_state <= OPCODE_FETCH_0;

        -- already in internal, so I can do this
        when (MULT_s0) =>
          mult_en <= "11";
          next_state <= MULT_s1;
        when (MULT_s1) =>
          internal_bus_select <= MULTAD_LOW_SEL;
          d_en <= '1';
          next_state <= MULT_s2;
        when (MULT_s2) =>
          internal_bus_select <= MULTAD_HIGH_SEL;
          a_en <= '1';
          next_state <= OPCODE_FETCH_0;

        when others =>
          null;
      end case;
    end process;
end architecture;
