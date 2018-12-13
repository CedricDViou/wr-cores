library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sis8300ku_led_translator is
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
end entity ; -- led_translator


architecture rtl of sis8300ku_led_translator is

  type t_state is (ST_RESET, ST_OFF, ST_ON);

  signal s_state_a, s_state : t_state               := ST_RESET;
  signal s_rst_cnt          : std_logic             := '0';
  signal cnt_c, cnt_c_a     : unsigned(31 downto 0) := (others => '0');

  constant c_ZERO       : unsigned(cnt_c'range) := (others => '0');
  constant c_PERIOD_ON  : unsigned(cnt_c'range) := to_unsigned( 6250000, cnt_c'length);  -- 1 * FREQ * BLINK_MS / 4000 - 1;
  constant c_PERIOD_OFF : unsigned(cnt_c'range) := to_unsigned(18750000, cnt_c'length);  -- 3 * FREQ * BLINK_MS / 4000 - 1;

begin

  crnt_state : process( clk_i )
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        s_state <= ST_RESET;
      else
        s_state <= s_state_a;
      end if;
    end if;
  end process ; -- crnt_state

  next_state : process( s_state, led_blink_i, led_on_i, cnt_c )
  begin
    s_state_a <= s_state;
    s_rst_cnt <= '0';

    case s_state is

      when ST_RESET =>
        s_state_a <= ST_OFF;
        s_rst_cnt <= '1';

      when ST_OFF =>
        if (led_blink_i = '1' or (led_blink_i = '0' and led_on_i = '1')) and cnt_c = c_PERIOD_OFF then
          s_state_a <= ST_ON;
          s_rst_cnt <= '1';
        end if;

      when ST_ON =>
        if (led_blink_i = '1' or (led_blink_i = '0' and led_on_i = '0')) and cnt_c = c_PERIOD_ON then
          s_state_a <= ST_OFF;
          s_rst_cnt <= '1';
        end if;

    end case;
  end process ; -- next_state

  p_reg : process( clk_i )
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' or s_rst_cnt = '1' then
        cnt_c <= c_ZERO;
      else
        cnt_c <= cnt_c_a;
      end if;
    end if;
  end process ; -- p_nsl

  b_cnt   : cnt_c_a <= cnt_c + 1    when s_state_a = ST_OFF and cnt_c /= c_PERIOD_OFF else
                       c_PERIOD_OFF when s_state_a = ST_OFF and cnt_c = c_PERIOD_OFF else
                       cnt_c + 1    when s_state_a = ST_ON and cnt_c /= c_PERIOD_ON else
                       c_PERIOD_ON  when s_state_a = ST_ON and cnt_c = c_PERIOD_ON else
                       c_ZERO;

  b_led_o : led_o   <= '1' when s_state = ST_ON else '0';

end architecture ; -- rtl
