library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package mips_pkg is

	-- Type Declaration (optional)
	type word_array is array (natural range<>) of std_logic_vector(31 downto 0);
	
	constant IMEM_SIZE	: integer := 1024;
	constant IMEM_ADDR	: integer := 8;
	constant WORD_SIZE 	: natural := 32;
	constant BREG_IDX 	: natural := 5;
	constant ZERO32 		: std_logic_vector(WORD_SIZE-1 downto 0) := (others=>'0');
	constant INC_PC		: std_logic_vector(WORD_SIZE-1 downto 0) := (2=>'1', others=>'0');
	
	-- Instrucoes do MIPs
	constant iRTYPE		: std_logic_vector(5 downto 0) := "000000";
	constant iLW			: std_logic_vector(5 downto 0) := "100011";
	constant iSW			: std_logic_vector(5 downto 0) := "101011";
	constant iADDI			: std_logic_vector(5 downto 0) := "001000";
	constant iORI			: std_logic_vector(5 downto 0) := "001101";
	constant iJ				: std_logic_vector(5 downto 0) := "000010";
	constant iBEQ			: std_logic_vector(5 downto 0) := "000100";
	constant iBNE			: std_logic_vector(5 downto 0) := "000101";
	constant iANDI			: std_logic_vector(5 downto 0) := "001100";
	constant iLB			: std_logic_vector(5 downto 0) := "100000";
	constant iLBU			: std_logic_vector(5 downto 0) := "100100";
	constant iLH			: std_logic_vector(5 downto 0) := "100001";
	constant iLHU			: std_logic_vector(5 downto 0) := "100101";
	constant iSB			: std_logic_vector(5 downto 0) := "101000";
	constant iSH			: std_logic_vector(5 downto 0) := "101001";
	
	-- Campo funct
	constant iADD			: std_logic_vector(5 downto 0) := "100000";
	constant iSUB			: std_logic_vector(5 downto 0) := "100010";
	constant iAND			: std_logic_vector(5 downto 0) := "100100";
	constant iOR			: std_logic_vector(5 downto 0) := "100101";
	constant iXOR			: std_logic_vector(5 downto 0) := "100110";
	constant iNOR			: std_logic_vector(5 downto 0) := "100111";
	constant iSLT			: std_logic_vector(5 downto 0) := "101010";
	constant iSLL			: std_logic_vector(5 downto 0) := "000000";
	constant iSRL			: std_logic_vector(5 downto 0) := "000010";
	constant iSRA			: std_logic_vector(5 downto 0) := "000011";
	
	-- Controle ULAmips
	constant ULA_ADD		: std_logic_vector(3 downto 0) := "0010"; -- 2
	constant ULA_SUB		: std_logic_vector(3 downto 0) := "0110"; -- 6
	constant ULA_AND		: std_logic_vector(3 downto 0) := "0000"; -- 0
	constant ULA_OR		: std_logic_vector(3 downto 0) := "0001"; -- 1
	constant ULA_NOP		: std_logic_vector(3 downto 0) := "1111"; -- 15
	constant ULA_NOR		: std_logic_vector(3 downto 0) := "1100"; -- 12
	constant ULA_SLT		: std_logic_vector(3 downto 0) := "0111"; -- 7
	constant ULA_SLL		: std_logic_vector(3 downto 0) := "1000"; -- 8
	constant ULA_SRL		: std_logic_vector(3 downto 0) := "0011"; -- 3
	constant ULA_SRA		: std_logic_vector(3 downto 0) := "0101"; -- 5
	
	component mips_multi is
	port 
	(
		clk		: in std_logic;
		clk_rom	: in std_logic;
		rst	   : in std_logic;
		data  	: out std_logic_vector(WORD_SIZE-1 downto 0)
	);
	end component;
	
	component reg is
	generic (
		SIZE : natural := 32
	);
	port 
	(
		clk		: in std_logic;
		enable	: in std_logic;
		rst		: in std_logic;
		sr_in	   : in std_logic_vector(WORD_SIZE-1 downto 0);
		sr_out	: out std_logic_vector(WORD_SIZE-1 downto 0)
	);
	end component; 
	
	component regbuf is
	generic (
		SIZE : natural := 32
	);
	port 
	(
		clk		: in std_logic;
		sr_in	   : in std_logic_vector(SIZE-1 downto 0);
		sr_out	: out std_logic_vector(SIZE-1 downto 0)
	);
end component;
	
	component mem_addr is
	generic (
		SIZE : natural := 32 );
	port (
	 	in0, in1	: in std_logic_vector(SIZE-1 downto 0);
		sel		: in std_logic;
		m_out		: out std_logic_vector(IMEM_ADDR-1 downto 0));
	end component;
	
	component mux_2 is
	generic (
		SIZE : natural := 32
	);
	port (	
		in0, in1	: in std_logic_vector(SIZE-1 downto 0);
		sel		: in std_logic;
		m_out		: out std_logic_vector(SIZE-1 downto 0)
	);
	end component;
	
	component mux_3 is
	generic (
		W_SIZE 	: natural := 32
			);
	port (
	 	in0, in1, in2	: in std_logic_vector(W_SIZE-1 downto 0);
		sel				: in std_logic_vector(1 downto 0);
		m_out				: out std_logic_vector(W_SIZE-1 downto 0));
	end component;	

	component mux_4 is
	generic (
		W_SIZE 	: natural := 32
			);
	port (
	 	in0, in1, in2, in3	: in std_logic_vector(W_SIZE-1 downto 0);
		sel						: in std_logic_vector(1 downto 0);
		m_out						: out std_logic_vector(W_SIZE-1 downto 0));
	end component;

	component adder is
	generic (
		DATA_WIDTH : natural := WORD_SIZE
	);
	port (
		a	 : in std_logic_vector ((DATA_WIDTH-1) downto 0);
		b	 : in std_logic_vector ((DATA_WIDTH-1) downto 0);
		res : out std_logic_vector ((DATA_WIDTH-1) downto 0)
	);
	end component;
	
	component inst_mem is
	generic (
		WIDTH : natural := WORD_SIZE;
		WADDR : natural := 8);
	port (
		address	: IN STD_LOGIC_VECTOR (WADDR-1 DOWNTO 0);
		clk		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0));
	end component;

	component ulamips is
	port (
		aluctl: 	in  std_logic_vector(3 downto 0);
		A, B:		in  std_logic_vector(WORD_SIZE-1 downto 0);
		aluout:	out std_logic_vector(WORD_SIZE-1 downto 0);
		zero:		out std_logic
		);
	end component;
	
	component breg is
	generic (
		SIZE : natural := WORD_SIZE;
		ADDR : natural := BREG_IDX
	);
	port 
	(
		clk		: in  std_logic;
		enable	: in  std_logic;
		idxA		: in  std_logic_vector(ADDR-1 downto 0);
		idxB		: in  std_logic_vector(ADDR-1 downto 0);
		idxwr		: in  std_logic_vector(ADDR-1 downto 0);
		data_in	: in  std_logic_vector(SIZE-1 downto 0);
		regA 		: out std_logic_vector(SIZE-1 downto 0);
		regB 		: out std_logic_vector(SIZE-1 downto 0)
	);
	end component;
	
	
	component alu_ctr is
	port (
		op_alu		: in std_logic_vector(1 downto 0);
		funct			: in std_logic_vector(5 downto 0);
		alu_ctr	   : out std_logic_vector(3 downto 0)
	);
	end component;
	
	component control is
	port (
		opcode : in std_logic_vector(5 downto 0);
		op_ula :	out std_logic_vector(1 downto 0);
		reg_dst,
		rd_mem,
		branch,
		jump,
		mem2reg,
		mem_wr,
		alu_src,
		breg_wr:	out std_logic
		);
end component;

component sig_ext is
	port (
		imm16	: in std_logic_vector(WORD_SIZE/2 - 1 downto 0);
		ext32 : out std_logic_vector(WORD_SIZE-1 downto 0)
		);
end component;

component data_mem is
	port
	(
		address	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;
	
--	procedure mux2x1 (signal x0, x1	: in std_logic_vector(WORD_SIZE-1 downto 0); 
--							signal sel	: in std_logic;
--							signal z 	: out std_logic_vector(WORD_SIZE-1 downto 0) );
	
	
end mips_pkg;


package body mips_pkg is

	-- Type Declaration (optional)

	-- Subtype Declaration (optional)

	-- Constant Declaration (optional)

	-- Function Declaration (optional)

	-- Function Body (optional)

	-- Procedures
	procedure mux2x1 (signal x0, x1	: in std_logic_vector(WORD_SIZE-1 downto 0); 
							signal sel		: in std_logic;
							signal z 		: out std_logic_vector(WORD_SIZE-1 downto 0) ) is
	begin	
		if (sel = '1') then	
			z <= x1;
		else	
			z <= x0;
		end if;
	end procedure;
	


end mips_pkg;
