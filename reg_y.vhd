----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:53:43 01/18/2016 
-- Design Name: 
-- Module Name:    reg_y - Behavioral 
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

entity registro is
	generic(N: natural);
	port(
		  clk: in std_logic;
		  reset: in std_logic;
		  load: in std_logic;
		  din: in std_logic_vector(N-1 downto 0);
		  dout: out std_logic_vector(N-1 downto 0));

end registro;

architecture Behavioral of registro is

signal registro: std_logic_vector(N-1 downto 0);

begin
process(clk, reset)
begin

if (reset = '1') then
	registro <= (others => '0');
elsif (clk'event and clk = '1') then
	if (load = '1') then
		registro <= din;
	else
		registro <= registro;
	end if;
end if;
end process;

dout <= registro;

end Behavioral;

