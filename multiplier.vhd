----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:51:09 01/18/2016 
-- Design Name: 
-- Module Name:    multiplier - Behavioral 
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

entity multiplier is
	port(
		  dinA: in std_logic_vector(31 downto 0); 
		  dinB: in std_logic_vector(31 downto 0);
		  op: in std_logic;
		  dout: out std_logic_vector(31 downto 0));
end multiplier;

architecture Behavioral of multiplier is

signal operacion: std_logic_vector(63 downto 0) ;

begin
process(dinA, dinB, op) 
begin

operacion <= std_logic_vector(unsigned(dinA) * unsigned(dinB));

if(op = '0') then
		dout <= std_logic_vector(unsigned(dinA) + unsigned(dinB));
elsif(op = '1') then 
		dout <= operacion(31 downto 0);
end if;
end process;	 
end Behavioral;

