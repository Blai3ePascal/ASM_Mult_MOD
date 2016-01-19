----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:55:27 01/18/2016 
-- Design Name: 
-- Module Name:    contador_asc_desc - Behavioral 
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

entity contador_asc_desc is
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
	
end contador_asc_desc;

architecture Behavioral of contador_asc_desc is

signal cuenta: std_logic_vector(N-1 downto 0);
signal aux: std_logic_vector(N - 1 downto 0);
signal modulo_aux: std_logic_vector(N -1 downto 0);

begin

modulo_aux <= std_logic_vector(unsigned(modulo) - 1);
aux <= (others => '0');

process(clk, reset)
begin

if (reset = '1') then
	cuenta <= (others => '0');
elsif (clk'event and clk = '1') then
		if (load = '1') then
			cuenta <= din;
		elsif (ce = '1') then
			if (up_ndn = '1') then
				if (cuenta < modulo_aux) then
					cuenta <= std_logic_vector(unsigned(cuenta) + 1);
				else
					cuenta <= (others => '0');
				end if;
			elsif (up_ndn = '0') then
				if (cuenta = aux) then
					cuenta <= modulo_aux;
				else
					cuenta <= std_logic_vector(unsigned(cuenta) - 1);
				end if;
			end if;
		end if;
end if;
end process;
dout <= cuenta;


end Behavioral;

