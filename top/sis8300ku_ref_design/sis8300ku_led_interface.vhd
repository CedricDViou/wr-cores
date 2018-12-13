library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sis8300ku_led_interface is
  generic (
    FREQ     : integer  := 62500000;  -- in Hz
    BLINK_MS : integer  :=      400   -- in ms
  );
  port (
    clk_i           : in  std_logic;
    rst_i           : in  std_logic;

    frontpanel_a_i  : in  std_logic_vector(1 downto 0);
    frontpanel_u_i  : in  std_logic_vector(1 downto 0);
    frontpanel_l1_i : in  std_logic_vector(1 downto 0);
    frontpanel_l2_i : in  std_logic_vector(1 downto 0);
    smd_ready_i     : in  std_logic;
    smds_i          : in  std_logic_vector(7 downto 0);

    led_serial_o    : out std_logic
  );
end entity ; -- led_interface


architecture rtl of sis8300ku_led_interface is

  component sis8300ku_led_translator is
    generic (
      FREQ     : integer  := 62500000;  -- in Hz
      BLINK_MS : integer  :=      400   -- in ms
    );
    port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;

      led_on_i    : in  std_logic;
      led_blink_i : in  std_logic;

      led_o       : out std_logic
    );
  end component ; -- led_translator

  component sn74lv8153_interface is
    generic (
      g_clock_freq : integer := 62500000
    );
    port (
      clk_i    : in  std_logic;
      rst_n_i  : in  std_logic;
      d_i      : in  std_logic_vector (15 downto 0);
      serial_o : out std_logic
    );
  end component; -- sn74lv8153_interface

  type t_leds is array(integer range <>) of std_logic_vector(1 downto 0);

  signal rst_n     : std_logic                     := '0';
  signal s_leds_fp : t_leds(0 to 3)                := (others => (others => '0'));
  signal s_leds    : std_logic_vector(15 downto 0) := (others => '0');

begin

  b_data_smd   : s_leds(7 downto 0) <= smds_i;

  b_leds_fp_a  : s_leds_fp(0) <= frontpanel_a_i;
  b_leds_fp_u  : s_leds_fp(1) <= frontpanel_u_i;
  b_leds_fp_l1 : s_leds_fp(2) <= frontpanel_l1_i;
  b_leds_fp_l2 : s_leds_fp(3) <= frontpanel_l2_i;

  gen_led_frontpanel : for i in 0 to 3 generate

    u_led_translator : sis8300ku_led_translator
      generic map (
        FREQ        => FREQ,
        BLINK_MS    => BLINK_MS
      )
      port map (
        clk_i       => clk_i,
        rst_i       => rst_i,

        led_on_i    => s_leds_fp(i)(0),
        led_blink_i => s_leds_fp(i)(1),

        led_o       => s_leds(8 + i)
      );

  end generate ; -- gen_led_frontpanel

  b_data_empty : s_leds(14 downto 12) <= (others => '0');

  b_data_ready : s_leds(15) <= smd_ready_i;

  p_rst_n : rst_n <= not rst_i;

  u_interface : sn74lv8153_interface
    generic map (
      g_clock_freq => FREQ
    )
    port map (
      clk_i    => clk_i,
      rst_n_i  => rst_n,
      d_i      => s_leds,
      serial_o => led_serial_o
    );

end architecture ; -- rtl
