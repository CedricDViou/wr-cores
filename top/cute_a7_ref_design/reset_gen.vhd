library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;

use work.gencores_pkg.all;

entity reset_gen is
  
  port (
    clk_i : in std_logic;

    rst_pll_locked_i : in std_logic := '1';
    rst_button_n_a_i : in std_logic := '1';

    rst_n_o : out std_logic
    );

end reset_gen;

architecture behavioral of reset_gen is

  signal powerup_cnt         : unsigned(7 downto 0) := x"00";
  signal button_synced_n     : std_logic;
  signal pll_locked_synced   : std_logic;
  signal powerup_n           : std_logic            := '0';

begin  -- behavioral

  U_EdgeDet_pll_locked : gc_sync_ffs port map (
    clk_i    => clk_i,
    rst_n_i  => '1',
    data_i   => rst_pll_locked_i,
    synced_o => pll_locked_synced);

  U_Sync_Button : gc_sync_ffs port map (
    clk_i    => clk_i,
    rst_n_i  => '1',
    data_i   => rst_button_n_a_i,
    synced_o => button_synced_n);

  p_powerup_reset : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if(powerup_cnt /= x"ff") then
        powerup_cnt <= powerup_cnt + 1;
        powerup_n   <= '0';
      else
        powerup_n <= '1';
      end if;
    end if;
  end process;

  rst_n_o <= powerup_n and button_synced_n and pll_locked_synced;

end behavioral;
