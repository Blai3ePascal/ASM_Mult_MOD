----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:33:02 01/17/2016 
-- Design Name: 
-- Module Name:    algorithmic - Behavioral 
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

entity algorithmic is
generic (control: natural := 20;
			status: natural := 2);
port (
		clk : in std_logic ;
		reset : in std_logic ;
		inicio : in std_logic ;
		n : in std_logic_vector ( 4 downto 0) ;
		x : in std_logic_vector (15 downto 0) ;
		y : out std_logic_vector (31 downto 0) ;
		z : out std_logic_vector (31 downto 0) ;
		fin : out std_logic ;
		error : out std_logic ) ;
end algorithmic ;
architecture Behavioral of algorithmic is

component DP is
generic(cntrl: natural; status: natural);
port(
		clk : in std_logic;
		reset : in std_logic;
		n : in std_logic_vector (4 downto 0);
		x : in std_logic_vector(15 downto 0);
		control : in std_logic_vector(cntrl - 1 downto 0);
		y : out std_logic_vector (31 downto 0);
		z : out std_logic_vector (31 downto 0) ;
		error :  out std_logic;
		status_sig : out std_logic_vector( status - 1 downto 0));
end component;

component CU is
generic(cntrl: natural; status: natural);
port(
	clk : in std_logic;
	reset : in std_logic;
	inicio : in std_logic;
	status_sig : in std_logic_vector( status - 1 downto 0);
	control : out std_logic_vector(cntrl - 1 downto 0);
	fin: out std_logic);
end component;

signal cntrl_aux: std_logic_vector(control - 1 downto 0);
signal status_aux: std_logic_vector(status - 1 downto 0);

begin

Data_Path: DP
generic map( cntrl => control, status => status)
port map(
  clk => clk,
  reset => reset,
  n => n,
  x => x,
  control => cntrl_aux,
  y => y,
  z => z,
  error => error,
  status_sig => status_aux
);

Control_Unit: CU
generic map( cntrl => control, status => status)
port map(
	clk => clk,
	reset => reset,
	inicio => inicio,
	status_sig => status_aux,
	control => cntrl_aux,
	fin => fin
);

end Behavioral;

