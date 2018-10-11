library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gencores_pkg.all;

entity gc_async_counter_diff is
  generic (
    g_bits         : integer := 8;
    g_output_clock : string  := "inc"
    );
  port
    (
      -- reset (g_output_clock clock domain)
      rst_n_i : in std_logic;

      -- increment clock
      clk_inc_i : in std_logic;
      -- decrement clock
      clk_dec_i : in std_logic;

      -- increment enable (clk_inc_i clock domain)
      inc_i : in std_logic;

      -- decrement enable (clk_inc_i clock domain)
      dec_i : in std_logic;

      -- current counter value, signed (g_output_clock clock domain)
      counter_o : out std_logic_vector(g_bits downto 0)

      );
end gc_async_counter_diff;

architecture rtl of gc_async_counter_diff is

  signal cnt1_bin, cnt2_bin   : unsigned(g_bits downto 0);
  signal cnt1_gray, cnt2_gray : std_logic_vector(g_bits downto 0);

  signal cnt1_gray_out : std_logic_vector(g_bits downto 0);
  signal cnt2_gray_out : std_logic_vector(g_bits downto 0);

  signal rst_n_inc, rst_n_dec : std_logic;

begin

  U_SyncReset_to_IncClk : gc_sync_ffs
    port map (
      clk_i    => clk_inc_i,
      rst_n_i  => '1',
      data_i   => rst_n_i,
      synced_o => rst_n_inc);

  U_SyncReset_to_DecClk : gc_sync_ffs
    port map (
      clk_i    => clk_dec_i,
      rst_n_i  => '1',
      data_i   => rst_n_i,
      synced_o => rst_n_dec);


  p_count_up : process(clk_inc_i)
  begin
    if rising_edge(clk_inc_i) then
      if rst_n_inc = '0' then
        cnt1_bin  <= (others => '0');
        cnt1_gray <= (others => '0');
      else
        if inc_i = '1' then
          cnt1_bin <= cnt1_bin + 1;
        end if;

        cnt1_gray <= f_gray_encode(std_logic_vector(cnt1_bin));
      end if;
    end if;
  end process;

  p_count_down : process(clk_dec_i)
  begin
    if rising_edge(clk_dec_i) then
      if rst_n_dec = '0' then
        cnt2_bin  <= (others => '0');
        cnt2_gray <= (others => '0');
      else
        if dec_i = '1' then
          cnt2_bin <= cnt2_bin + 1;
        end if;

        cnt2_gray <= f_gray_encode(std_logic_vector(cnt2_bin));
      end if;
    end if;
  end process;

  gen_out_clock_is_inc : if g_output_clock = "inc" generate

    cnt1_gray_out <= cnt1_gray;

    U_Sync : gc_sync_register
      generic map (
        g_width => g_bits+1)
      port map (
        clk_i     => clk_inc_i,
        rst_n_a_i => rst_n_i,
        d_i       => cnt2_gray,
        q_o       => cnt2_gray_out);

  end generate gen_out_clock_is_inc;

  gen_out_clock_is_dec : if g_output_clock = "dec" generate
    cnt2_gray_out <= cnt2_gray;

    U_Sync : gc_sync_register
      generic map (
        g_width => g_bits+1)
      port map (
        clk_i     => clk_dec_i,
        rst_n_a_i => rst_n_i,
        d_i       => cnt1_gray,
        q_o       => cnt1_gray_out);
  end generate gen_out_clock_is_dec;

  counter_o <= std_logic_vector(unsigned(cnt2_gray_out) - unsigned(cnt1_gray_out));


end rtl;

