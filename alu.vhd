-- Jayson Salkey
-- small8 ALU
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.libSM8.all;

entity alu is
  port(
    cin : in std_logic;
    D : in std_logic_vector(CPU_WIDTH-1 downto 0);
    A : in std_logic_vector(CPU_WIDTH-1 downto 0);
    opcode  : in std_logic_vector(CPU_WIDTH-1 downto 0);
    result  : out std_logic_vector(CPU_WIDTH-1 downto 0);
    C : out std_logic;
    V : out std_logic;
    Z : out std_logic;
    S : out std_logic
  );
end alu;



architecture alu_bhv of alu is

begin

  process(cin,D,A,opcode)
    variable t1 : std_logic_vector(CPU_WIDTH-1 downto 0);
    variable t2 : std_logic_vector(CPU_WIDTH downto 0);
    variable t_sub : signed(CPU_WIDTH downto 0);
  begin
    case (opcode) is
      when ANDR =>
        t1 := A and D;
        result <= t1;
        C <= '0';
        V <= '0';
        S <= t1(CPU_WIDTH-1);
        if(unsigned(t1) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when ORR =>
        t1 := A or D;
        result <= t1;
        C <= '0';
        V <= '0';
        S <= t1(CPU_WIDTH-1);
        if(unsigned(t1) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when XORR =>
        t1 := A xor D;
        result <= t1;
        C <= '0';
        V <= '0';
        S <= t1(CPU_WIDTH-1);
        if(unsigned(t1) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when SLRL =>
        C <= A(CPU_WIDTH-1);
        t1 := A(CPU_WIDTH-2 downto 0) & "0";
        result <= t1;
        V <= '0';
        S <= t1(CPU_WIDTH-1);
        if(unsigned(t1) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when SRRL =>
        C <= A(0);
        t1 := "0" & A(CPU_WIDTH-1 downto 1);
        result <= t1;
        V <= '0';
        S <= t1(CPU_WIDTH-1);
        if(unsigned(t1) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when ROLC =>
        C <= A(CPU_WIDTH-1);
        t1 := A(CPU_WIDTH-2 downto 0) & cin;
        result <= t1;
        V <= '0';
        S <= t1(CPU_WIDTH-1);
        if(unsigned(t1) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when RORC =>
        C <= A(0);
        t1 := cin & A(CPU_WIDTH-1 downto 1);
        result <= t1;
        V <= '0';
        S <= t1(CPU_WIDTH-1);
        if(unsigned(t1) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when ADCR => -- verify this works
        t2 := std_logic_vector(unsigned("0"&A) + unsigned("0"&D) + unsigned'(""&cin));
        result <= t2(CPU_WIDTH-1 downto 0);
        C <= t2(CPU_WIDTH); -- just to store the carry
        S <= t2(CPU_WIDTH-1);
        if((D(CPU_WIDTH-1)='0' and A(CPU_WIDTH-1)='0' and t2(CPU_WIDTH-1)='1') or (D(CPU_WIDTH-1)='1' and A(CPU_WIDTH-1)='1' and t2(CPU_WIDTH-1)='0')) then
          V <= '1';
        else
          V <= '0';
        end if;
        if(unsigned(t2) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when SBCR => -- verify this works
        t2 := std_logic_vector(unsigned("0"&A) + unsigned(not("0"&D)) + unsigned'(""&cin));
        result <= t2(CPU_WIDTH-1 downto 0);
        C <= t2(CPU_WIDTH);
        S <= t2(CPU_WIDTH-1);
        if((D(CPU_WIDTH-1)='0' and A(CPU_WIDTH-1)='0' and t2(CPU_WIDTH-1)='1') or (D(CPU_WIDTH-1)='1' and A(CPU_WIDTH-1)='1' and t2(CPU_WIDTH-1)='0')) then
          V <= '1';
        else
          V <= '0';
        end if;
        if(unsigned(t2) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when CMPR =>
        t2 := std_logic_vector(unsigned("0"&A) + unsigned(not("0"&D)) + unsigned'(""&cin));
        result <= (others => '0');
        C <= t2(CPU_WIDTH);
        S <= t2(CPU_WIDTH-1);
        if((D(CPU_WIDTH-1)='0' and A(CPU_WIDTH-1)='0' and t2(CPU_WIDTH-1)='1') or (D(CPU_WIDTH-1)='1' and A(CPU_WIDTH-1)='1' and t2(CPU_WIDTH-1)='0')) then
          V <= '1';
        else
          V <= '0';
        end if;
        if(unsigned(t2) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when DECA =>
        t1 := std_logic_vector(unsigned(A) - 1);
        S <= t1(CPU_WIDTH-1);
        C <= '0';
        V <= '0';
        result <= t1;
        if(unsigned(t1) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when INCA =>
        t1 := std_logic_vector(unsigned(A) + 1);
        S <= t1(CPU_WIDTH-1);
        C <= '0';
        V <= '0';
        result <= t1;
        if(unsigned(t1) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

      when (STAA or STAR or LDSI or CALL or RET or LDXI or LDAA_idx or STAA_idx or INCX or DECX) =>
        S <= '0';
        V <= '0';
        Z <= '0';
        C <= '0';
        result <= (others => '0');

      when others =>
        result <= (others => '0');
        S <= A(CPU_WIDTH-1);
        V <= '0';
        C <= '0';
        if(unsigned(A) = 0) then
          Z <= '1';
        else
          Z <= '0';
        end if;

    end case;
  end process;
end alu_bhv;
