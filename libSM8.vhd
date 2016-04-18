library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package libSM8 is
  constant CPU_WIDTH : natural := 8;
  -- internal bus select lines
  constant A_SEL : std_logic_vector(3 downto 0) := x"0";
  constant D_SEL : std_logic_vector(3 downto 0) := x"1";
  constant PC_LOW_SEL : std_logic_vector(3 downto 0) := x"2";
  constant PC_HIGH_SEL : std_logic_vector(3 downto 0) := x"3";
  constant X_LOW_SEL : std_logic_vector(3 downto 0) := x"4";
  constant X_HIGH_SEL : std_logic_vector(3 downto 0) := x"5";
  constant SP_LOW_SEL : std_logic_vector(3 downto 0) := x"6";
  constant SP_HIGH_SEL : std_logic_vector(3 downto 0) := x"7";
  constant ALU_IN_SEL : std_logic_vector(3 downto 0) := x"8";
  constant EBUS_INTO_IBUS_SEL : std_logic_vector(3 downto 0) := x"9";
  constant IR_SEL : std_logic_vector(3 downto 0) := x"A";
  constant AR_LOW_SEL : std_logic_vector(3 downto 0) := x"B";
  constant AR_HIGH_SEL : std_logic_vector(3 downto 0) := x"C";
  constant MULTAD_LOW_SEL : std_logic_vector(3 downto 0) := x"D";
  constant MULTAD_HIGH_SEL : std_logic_vector(3 downto 0) := x"E";

  -- external bus select lines
  constant IBUS_INTO_EBUS_SEL : std_logic_vector(1 downto 0) := "00";
  constant MEM_SEL : std_logic_vector(1 downto 0) := "01";
  constant EXT_IN0_SEL : std_logic_vector(1 downto 0) := "10";
  constant EXT_IN1_SEL : std_logic_vector(1 downto 0) := "11";

  -- Instruction Set
  constant LDAI : std_logic_vector(CPU_WIDTH-1 downto 0) := x"84";
  constant LDAA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"88";
  constant LDAD : std_logic_vector(CPU_WIDTH-1 downto 0) := x"81";
  constant STAA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"F6";
  constant STAR : std_logic_vector(CPU_WIDTH-1 downto 0) := x"F1";
  constant ADCR : std_logic_vector(CPU_WIDTH-1 downto 0) := x"01";
  constant SBCR : std_logic_vector(CPU_WIDTH-1 downto 0) := x"11";
  constant CMPR : std_logic_vector(CPU_WIDTH-1 downto 0) := x"91";
  constant ANDR : std_logic_vector(CPU_WIDTH-1 downto 0) := x"21";
  constant ORR : std_logic_vector(CPU_WIDTH-1 downto 0) := x"31";
  constant XORR : std_logic_vector(CPU_WIDTH-1 downto 0) := x"41";
  constant SLRL : std_logic_vector(CPU_WIDTH-1 downto 0) := x"51";
  constant SRRL : std_logic_vector(CPU_WIDTH-1 downto 0) := x"61";
  constant ROLC : std_logic_vector(CPU_WIDTH-1 downto 0) := x"52";
  constant RORC : std_logic_vector(CPU_WIDTH-1 downto 0) := x"62";
  constant BCCA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"B0";
  constant BCSA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"B1";
  constant BEQA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"B2";
  constant BMIA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"B3";
  constant BNEA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"B4";
  constant BPLA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"B5";
  constant BVCA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"B6";
  constant BVSA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"B7";
  constant DECA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"FB";
  constant INCA : std_logic_vector(CPU_WIDTH-1 downto 0) := x"FA";
  constant SETC : std_logic_vector(CPU_WIDTH-1 downto 0) := x"F8";
  constant CLRC : std_logic_vector(CPU_WIDTH-1 downto 0) := x"F9";
  constant NO_OP : std_logic_vector(CPU_WIDTH-1 downto 0) := x"00";
  -- Addendum
  constant LDSI : std_logic_vector(CPU_WIDTH-1 downto 0) := x"89";
  constant CALL : std_logic_vector(CPU_WIDTH-1 downto 0) := x"C8";
  constant RET : std_logic_vector(CPU_WIDTH-1 downto 0) := x"C0";
  constant LDXI : std_logic_vector(CPU_WIDTH-1 downto 0) := x"8A";
  constant LDAA_idx : std_logic_vector(CPU_WIDTH-1 downto 0) := x"BC";
  constant STAA_idx : std_logic_vector(CPU_WIDTH-1 downto 0) := x"EC";
  constant INCX : std_logic_vector(CPU_WIDTH-1 downto 0) := x"FC";
  constant DECX : std_logic_vector(CPU_WIDTH-1 downto 0) := x"FD";
  constant MULT : std_logic_vector(CPU_WIDTH-1 downto 0) := x"FE";

end libSM8;
