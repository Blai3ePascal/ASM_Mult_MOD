----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:47:31 01/17/2016 
-- Design Name: 
-- Module Name:    Data_Path - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DP is
generic(cntrl: natural; status: natural);
port(
		clk : in std_logic;
		reset : in std_logic;
		n : in std_logic_vector (4 downto 0);
		x : in std_logic_vector(15 downto 0);
		control : in std_logic_vector(cntrl - 1 downto 0);
		y : out std_logic_vector (31 downto 0);
		z : out std_logic_vector (31 downto 0);
		error :  out std_logic;
		status_sig : out std_logic_vector(status - 1 downto 0));
end DP;

architecture Behavioral of DP is

--Señales de control:
--Son todas las señales de control del diagrama del Data Path
--Por ejemplo si para cargar un valor X activamos cnt_ld pues esa señal se pone aqui con un alias
signal control_aux: std_logic_vector(cntrl - 1 downto 0);
--                                      
--       ld_reg_acumulador ---> -------------------
--                              |  REG_ACUMULADOR  |
--       rst_reg_acumulador --> |                  |
--                              |CLK_______________|
--
alias ld_reg_acumulador is control_aux(0);  
alias rst_reg_acumulador is control_aux(1);
--
--mux_acumulador->  --------------
--                  \   Mux_ac   /
--                   \__________/
--
alias mux_acumulador is control_aux(2);
--
--    we_ram---> -----------
--              |    RAM    |
--              |CLK________|
--
alias we_ram is control_aux(3);
--
--        				   ----    ----
--       				   \    \ /   /
--  multiplier_enable_-> \________/
--
alias multiplier_enable is control_aux(4);
--
--       ld_reg_y ---> -------------------
--                     |  REG_Y           |
--       rst_reg_y --> |                  |
--                     |CLK_______________|
--
alias ld_reg_y is control_aux(5);
alias rst_reg_y is control_aux(6);
--
--       ld_cont   ---> ------------------  <---- count_enable
--                     |  CONT_ASC_DESC   |
--       rst_cont  --> |                  | <---- up_ndn
--                     |CLK_______________|
--
alias ld_cont is control_aux(7);
alias rst_cont is control_aux(8);
alias cont_enable is control_aux(9);
alias up_ndn is control_aux(10);
--
--       ld_reg_n ---> -------------------
--                     |  REG_N           |
--       rst_reg_n --> |                  |
--                     |CLK_______________|
--
alias ld_reg_n is control_aux(11);
alias rst_reg_n is control_aux(12);
--
--       ld_error ---> -------------------
--                     |  ERROR           |
--       rst_error --> |                  |
--                     |CLK_______________|
--
alias ld_error is control_aux(13);
alias rst_error is control_aux(14);
--       ld_reg_y ---> -------------------
--                     |  REG_X           |
--       rst_reg_y --> |                  |
--                     |CLK_______________|
--
alias ld_reg_x is control_aux(15);
alias rst_reg_x is control_aux(16);
--       ld_reg_y ---> -------------------
--                     |  REG_Z           |
--       rst_reg_y --> |                  |
--                     |CLK_______________|
--
alias ld_reg_z is control_aux(17);
alias rst_reg_z is control_aux(18);
--
--mux_acumulador_dos->  --------------
--               		   \   Mux_ac_2 /
--                	    \__________/
--
alias mux_acumulador_dos is control_aux(19);





--Señales de Status:
--Todos los Status posibles como el de error se ponen aqui
signal status_aux: std_logic_vector(status - 1 downto 0);
alias error_st is status_aux(0);
alias cont_igual is status_aux(1);

--Señales internas:
signal salida_cont: std_logic_vector(4 downto 0);
signal salida_reg_y: std_logic_vector(31 downto 0);
signal salida_reg_z: std_logic_vector(31 downto 0);
signal salida_multiplicador: std_logic_vector(31 downto 0);
signal salida_n: std_logic_vector (4 downto 0);
signal salida_ram: std_logic_vector (15 downto 0);
signal salida_ram_ext: std_logic_vector (31 downto 0);
signal salida_mux: std_logic_vector(31 downto 0);
signal salida_acumulador: std_logic_vector(31 downto 0);
signal salida_reg_x: std_logic_vector(15 downto 0);
signal salida_mux_dos: std_logic_vector(31 downto 0);
--Resets internos

signal rst_cont_s: std_logic;
signal rst_reg_y_s: std_logic;
signal rst_reg_z_s: std_logic;
signal rst_reg_x_s: std_logic;
signal rst_reg_acumulador_s: std_logic;
signal rst_reg_n_s: std_logic;
signal rst_error_s: std_logic;


component registro is
	generic(N: natural);
	port(
		  clk: in std_logic;
		  reset: in std_logic;
		  load: in std_logic;
		  din: in std_logic_vector(N-1 downto 0);
		  dout: out std_logic_vector(N-1 downto 0));
end component;

component ram_memory is 
	port(
		 clk: in std_logic;
		 we: in std_logic;
		 addr: in std_logic_vector(4 downto 0);
		 din: in std_logic_vector(15 downto 0);
		 dout: out std_logic_vector(15 downto 0));
end component;

component multiplier is
	port(
		  dinA: in std_logic_vector(31 downto 0); 
		  dinB: in std_logic_vector(31 downto 0);
		  op: in std_logic;
		  dout: out std_logic_vector(31 downto 0));
	
end component;

component contador_asc_desc is
	generic(N: integer);
	port(
		  clk: in std_logic;
		  reset: in std_logic;
		  load: in std_logic;
		  ce: in std_logic;
		  up_ndn: in std_logic;
		  modulo: in std_logic_vector(N-1 downto 0);
		  din: in std_logic_vector(N-1 downto 0);
		  dout: out std_logic_vector(N-1 downto 0));
end component;

begin

rst_cont_s <= reset or rst_cont;
rst_reg_y_s <= reset or rst_reg_y;
rst_reg_acumulador_s <= reset or rst_reg_acumulador;
rst_reg_n_s <= reset or rst_reg_n;
rst_error_s <= reset or rst_error;
rst_reg_z_s <= reset or rst_reg_z;
rst_reg_x_s <= reset or rst_reg_x;
control_aux <= control;
status_sig <= status_aux;

RAM: ram_memory
    port map(
            clk => clk,
				we => we_ram,
				addr => salida_cont,
				din => "0000000000000000",
				dout => salida_ram);				
salida_ram_ext <= "0000000000000000" & salida_ram;

MULT: multiplier
	  port map(
				dinA => salida_acumulador,
				dinB => salida_ram_ext,
				op => multiplier_enable,
				dout => salida_multiplicador);
				
salida_mux <= "0000000000000000" & x when mux_acumulador = '0' else salida_multiplicador;
salida_mux_dos <= salida_mux when mux_acumulador_dos = '0' else "0000000000000000" & salida_reg_x;
salida_reg_y <= salida_mux_dos;
salida_reg_z <= salida_multiplicador;
 
REG_Y: registro
		generic map(N => 32)
		port map(
		      clk => clk,
				reset => rst_reg_y_s,
				load => ld_reg_y,
				din => salida_reg_y, 
				dout => y);
				
REG_Z: registro
		generic map(N => 32)
		port map(
		      clk => clk,
				reset => rst_reg_z_s,
				load => ld_reg_z,
				din => salida_reg_z,
				dout => z);
							
REG_X: registro
		generic map(N => 16)
		port map(
		      clk => clk,
				reset => rst_reg_x_s,
				load => ld_reg_x,
				din => x,
				dout => salida_reg_x);
				
REG_N: registro
		generic map(N => 5)
		port map(
		      clk => clk,
				reset => rst_reg_n_s,
				load => ld_reg_n,
				din => n,
				dout => salida_n);
				
ACUMULADOR: registro
	   generic map(N => 32)
		port map(
		      clk => clk,
				reset => rst_reg_acumulador_s,
				load => ld_reg_acumulador,
				din => salida_mux_dos,
				dout => salida_acumulador);

CONT_ASC_DESC: contador_asc_desc
		generic map(N => 5)
		port map(
				clk => clk,
				reset => rst_cont_s,
				load => ld_cont,
			   ce => cont_enable,
			   up_ndn => up_ndn,
			   modulo => salida_n,
			   din => "00000",
			   dout => salida_cont);
				
REG_ERROR: registro
	generic map(N => 1)
	port map(
				clk => clk,
				reset => rst_error_s,
				load => ld_error,
				din => "1",
				dout(0) => error);
				
error_st <= '1' when x = "0000000000000000" or n = "00000" else '0';
cont_igual <= '1' when salida_cont = std_logic_vector(unsigned(salida_n) - 1) else '0';
				
end Behavioral;

