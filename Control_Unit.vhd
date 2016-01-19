----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:49:44 01/17/2016 
-- Design Name: 
-- Module Name:    Control_Unit - Behavioral 
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

entity CU is
generic(cntrl: natural; status: natural);
port(
	clk : in std_logic;
	reset : in std_logic;
	inicio : in std_logic;
	status_sig : in std_logic_vector( status - 1 downto 0);
	control : out std_logic_vector(cntrl - 1 downto 0);
	fin: out std_logic);
end CU;

architecture Behavioral of CU is

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

type ESTADOS is (S0_INICIAL, S1_CARGA, S2_WAIT, S3_OPERACION, S4_ERROR, S5_RESETS, S6_LOADOS, S7_WAITPRIMA, S8_SUMA);
signal estado, estado_siguiente: ESTADOS;

begin

control <= control_aux;
status_aux <= status_sig;

SINCRONO: process(clk, reset)
begin
	if(reset = '1') then
		estado <= S0_INICIAL;
	elsif(clk'event and clk = '1') then
		estado <= estado_siguiente;
	end if;
end process SINCRONO;

COMBINACIONAL: process (ESTADO, error_st, cont_igual, inicio)
begin
control_aux <= (others => '0');
fin <= '0';

case ESTADO is
	when S0_INICIAL =>
			if(inicio = '0') then estado_siguiente <= S0_INICIAL;
			elsif(error_st = '0') then estado_siguiente <= S1_CARGA;
			else estado_siguiente <= S4_ERROR;  
			end if;
			fin <= '1'; 
			rst_cont <= '1';
			rst_reg_n <='1';
			rst_reg_x <='1';
			rst_reg_acumulador <= '1';
	when S1_CARGA =>
			ld_reg_n <= '1';
		   ld_reg_x <= '1';
			ld_reg_acumulador <= '1';
			rst_error <= '1';
			rst_reg_y <='1';
			rst_reg_z <= '1';
			estado_siguiente <= S2_WAIT;
	when S2_WAIT =>
			estado_siguiente <= S3_OPERACION;
	when S3_OPERACION =>
			ld_reg_acumulador <= '1';
			mux_acumulador <= '1';
			ld_reg_y <= '1';
			cont_enable <= '1';
			up_ndn <= '1';
			multiplier_enable <= '1';
			if(cont_igual = '1') then estado_siguiente <= S5_RESETS;
			else estado_siguiente <= S2_WAIT;
			end if;
	when S4_ERROR =>
			estado_siguiente <= S0_INICIAL;
			ld_error <= '1';
	when S5_RESETS =>
			rst_cont <= '1';
			rst_reg_acumulador <= '1';
			multiplier_enable <= '1';
			estado_siguiente <= S6_LOADOS;
	when S6_LOADOS =>
			mux_acumulador_dos <= '1';
			ld_reg_acumulador <= '1';
			estado_siguiente <= S7_WAITPRIMA; 
	when S7_WAITPRIMA =>
			estado_siguiente <= S8_SUMA;
	when S8_SUMA =>
			ld_reg_acumulador <= '1';
			ld_reg_z <= '1'; 
			mux_acumulador <= '1';
			cont_enable <= '1';
			up_ndn <= '1';
			if(cont_igual = '1') then estado_siguiente <= S0_INICIAL;
			else estado_siguiente <= S7_WAITPRIMA;
			end if;	

end case;
end process COMBINACIONAL;
end Behavioral;

