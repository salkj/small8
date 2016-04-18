-- Jayson Salkey
-- small8 ALU
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.libSM8.all;

entity alu_tb is
end alu_tb;


architecture alu_arch_tb of alu_tb is

  signal cin : std_logic;
  signal S : std_logic;
  signal C : std_logic;
  signal V : std_logic;
  signal Z : std_logic;
  signal opcode : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal D : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal A : std_logic_vector(CPU_WIDTH-1 downto 0);
  signal result : std_logic_vector(CPU_WIDTH-1 downto 0);

begin  -- TB

    UUT : entity work.alu
        port map (
            cin   => cin,
            D   => D,
            A      => A,
            opcode   => opcode,
            result => result,
            C => C,
            V => V,
            Z => Z,
            S => S);


    process
    begin

        cin <= '0';
        wait for 40 ns;
        -- Many of these test cases are testing for edge cases. Thus will only work as intended with this 8-bit ALU.
        -- test 2+6 (no overflow)
        opcode    <= ADCR;
        A <= conv_std_logic_vector(2, A'length);
        D <= conv_std_logic_vector(6, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(8, result'length)) report "Error : 2+6 = " & integer'image(conv_integer(result)) & " instead of 8" severity warning;

        -- test -6+50 (with overflow)
        opcode    <= ADCR;
        A <= conv_std_logic_vector(-6, A'length);
        D <= conv_std_logic_vector(50, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(44, result'length)) report "Error : -6+50 = " & integer'image(conv_integer(result)) & " instead of 300" severity warning;

        -- test 5+6
        opcode    <= ADCR;
        A <= conv_std_logic_vector(5, A'length);
        D <= conv_std_logic_vector(6, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(11, result'length)) report "Error : 5+6 = " & integer'image(conv_integer(result)) & " instead of 11" severity warning;

        -- test -1+-1
        opcode    <= ADCR;
        A <= conv_std_logic_vector(-1, A'length);
        D <= conv_std_logic_vector(-1, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(-2, result'length)) report "Error : -1+-1 = " & integer'image(conv_integer(result)) & " instead of 510" severity warning;

        -- test 127+127
        opcode    <= ADCR;
        A <= conv_std_logic_vector(127, A'length);
        D <= conv_std_logic_vector(127, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(254, result'length)) report "Error : 127+127 = " & integer'image(conv_integer(result)) & " instead of 254" severity warning;


        -- test -7+7
        opcode    <= ADCR;
        A <= conv_std_logic_vector(-7, A'length);
        D <= conv_std_logic_vector(7, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(0, result'length)) report "Error : 255+255 = " & integer'image(conv_integer(result)) & " instead of 0" severity warning;

        -- case where V goes up

        cin <= '1';
        wait for 40 ns;

    
        -- test 60-50
        opcode    <= SBCR;
        A <= conv_std_logic_vector(60, A'length);
        D <= conv_std_logic_vector(50, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(10, result'length)) report "Error : 60-50 = " & integer'image(conv_integer(result)) & " instead of 10" severity warning;

        -- add many more tests
        -- test 8-6
        opcode <= SBCR;
        A <= conv_std_logic_vector(8, A'length);
        D <= conv_std_logic_vector(6, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(2, result'length)) report "Error : 8-6 = " & integer'image(conv_integer(result)) severity warning;

        -- test compare 8 , 6
        opcode <= CMPR;
        A <= conv_std_logic_vector(8, A'length);
        D <= conv_std_logic_vector(6, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(0, result'length)) report "Error : 8 compare 6 = " & integer'image(conv_integer(result)) severity warning;


        cin <= '0';
        wait for 40 ns;

        -- test 8 and 6
        opcode <= ANDR;
        A <= conv_std_logic_vector(8, A'length);
        D <= conv_std_logic_vector(6, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(0, result'length)) report "Error : 8 and 6 = " & integer'image(conv_integer(result)) severity warning;

        -- test 8 or 6
        opcode <= ORR;
        A <= conv_std_logic_vector(8, A'length);
        D <= conv_std_logic_vector(6, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(14, result'length)) report "Error : 8 or 6 = " & integer'image(conv_integer(result)) severity warning;

        -- test 8 xor 6
        opcode <= XORR;
        A <= conv_std_logic_vector(8, A'length);
        D <= conv_std_logic_vector(6, D'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(14, result'length)) report "Error : 8 xor 6 = " & integer'image(conv_integer(result)) severity warning;

        -- test shift left 8
        opcode <= SLRL;
        A <= conv_std_logic_vector(8, A'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(16, result'length)) report "Error : shift left 8 1 bit = " & integer'image(conv_integer(result)) severity warning;

        -- test shift left 128
        opcode <= SLRL;
        A <= conv_std_logic_vector(128, A'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(0, result'length)) report "Error : shift left 128 1 bit = " & integer'image(conv_integer(result)) severity warning;

        -- test shift right 1
        opcode <= SRRL;
        A <= conv_std_logic_vector(1, A'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(0, result'length)) report "Error : shift right 1 1 bit = " & integer'image(conv_integer(result)) severity warning;

        -- Rotate left
        opcode <= ROLC;
        A <= conv_std_logic_vector(1, A'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(2, result'length)) report "Error : rotate left 1 1 bit = " & integer'image(conv_integer(result)) severity warning;

        -- Rotate right
        opcode <= RORC;
        A <= conv_std_logic_vector(17, A'length);
        wait for 40 ns;
        assert(result = conv_std_logic_vector(8, result'length)) report "Error : rotate right 1 1 bit = " & integer'image(conv_integer(result)) severity warning;



        report "SIMULATION FINISHED!";
        wait;

    end process;



end alu_arch_tb;
