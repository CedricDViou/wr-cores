library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity clock_reset_gen is
  port (
    clk_i : in std_logic;
    gpio_o : out std_logic_vector(7 downto 0)
    );

end entity;

architecture rtl of clock_reset_gen is

  signal cnt      : unsigned(23 downto 0);


begin


  process(clk_i)
  begin
    if rising_edge(clk_i) then
      cnt <= cnt + 1;

      case cnt(23 downto 21) is
        when "000"  => gpio_o <= "10000000";
        when "001"  => gpio_o <= "01000000";
        when "010"  => gpio_o <= "00100000";
        when "011"  => gpio_o <= "00010000";
        when "100"  => gpio_o <= "00001000";
        when "101"  => gpio_o <= "00000100";
        when "110"  => gpio_o <= "00000010";
        when others => gpio_o <= "00000001";
      end case;
    end if;
  end process;


end rtl;
