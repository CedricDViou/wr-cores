library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fixed_latency_ts_match is
  generic
    (g_clk_ref_rate : integer;
     g_simulation : integer := 0;
     g_sim_cycle_counter_range : integer := 125000000

     );
  port
    (
      clk_i   : in std_logic;
      rst_n_i : in std_logic;

      arm_i : in std_logic;

      ts_tai_i    : in std_logic_vector(39 downto 0);
      ts_cycles_i : in std_logic_vector(27 downto 0);
      ts_latency_i : in std_logic_vector(27 downto 0);
      ts_timeout_i : in std_logic_vector(27 downto 0);

      -- Time valid flag
      tm_time_valid_i : in std_logic := '0';

      -- TAI seconds
      tm_tai_i : in std_logic_vector(39 downto 0) := x"0000000000";

      -- Fractional part of the second (in clk_ref_i cycles)
      tm_cycles_i : in std_logic_vector(27 downto 0) := x"0000000";

      match_o : out std_logic;
      late_o  : out std_logic;
      timeout_o : out std_logic


      );

end entity;

architecture rtl of fixed_latency_ts_match is

  type t_state is (IDLE, WRAP_ADJ_TS, CHECK_LATE, WAIT_TRIG);

  impure function f_cycles_counter_range return integer is
  begin
    if g_simulation = 1 then
      if g_clk_ref_rate = 62500000 then
        return 2*g_sim_cycle_counter_range;
      else
        return g_sim_cycle_counter_range;
      end if;
      
    else
      return 125000000;
    end if;
  end function;

  signal ts_adjusted_cycles : unsigned(28 downto 0);
  signal ts_adjusted_tai    : unsigned(39 downto 0);
  signal ts_timeout_cycles  : unsigned(28 downto 0);
  signal ts_timeout_tai     : unsigned(39 downto 0);

  signal tm_cycles_scaled : unsigned(28 downto 0);
  signal ts_latency_scaled : unsigned(28 downto 0);
  signal ts_timeout_scaled : unsigned(28 downto 0);

  signal tm_cycles_scaled_d : unsigned(28 downto 0);
  signal tm_tai_d           : unsigned(39 downto 0);

  signal match, late, timeout : std_logic;
  signal state : t_state;
  signal trig                                : std_logic;


  signal wait_cnt : unsigned(23 downto 0);

  attribute mark_debug : string;

  attribute mark_debug of ts_adjusted_cycles : signal is "TRUE";
  attribute mark_debug of ts_adjusted_tai    : signal is "TRUE";
  attribute mark_debug of ts_timeout_cycles : signal is "TRUE";
  attribute mark_debug of ts_timeout_tai    : signal is "TRUE";
  attribute mark_debug of tm_cycles_scaled_d : signal is "TRUE";
  attribute mark_debug of tm_tai_d           : signal is "TRUE";
  attribute mark_debug of state              : signal is "TRUE";
  attribute mark_debug of match              : signal is "TRUE";
  attribute mark_debug of late               : signal is "TRUE";
  attribute mark_debug of timeout            : signal is "TRUE";
  attribute mark_debug of trig               : signal is "TRUE";


begin

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      tm_cycles_scaled_d <= tm_cycles_scaled;
      tm_tai_d           <= unsigned(tm_tai_i);
    end if;
  end process;


  process(tm_cycles_i, ts_latency_i, ts_timeout_i)
  begin
    if g_clk_ref_rate = 62500000 then
      tm_cycles_scaled <= unsigned(tm_cycles_i & '0');
      ts_latency_scaled <= unsigned(ts_latency_i & '0');
      ts_timeout_scaled <= unsigned(ts_timeout_i & '0');
    elsif g_clk_ref_rate = 125000000 then
      tm_cycles_scaled <= unsigned('0' & tm_cycles_i);
      ts_latency_scaled <= unsigned('0' & ts_latency_i);
      ts_timeout_scaled <= unsigned('0' & ts_timeout_i);
    else
      report "Unsupported g_clk_ref_rate (62.5 / 125 MHz)" severity failure;
    end if;
  end process;


  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        wait_cnt <= (others => '0');
        trig     <= '0';
      else

        case State is
          when IDLE =>
            wait_cnt <= (others => '0');
            trig     <= '0';

          when others =>
            wait_cnt <= wait_cnt + 1;

            if wait_cnt = 3000 then
              trig <= '1';
            end if;
        end case;
      end if;
    end if;
  end process;




  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        late <= '0';
        match  <= '0';
        State  <= IDLE;

      else

        case State is
          when IDLE =>
            match  <= '0';
            late  <= '0';
            timeout <= '0';

            if arm_i = '1' then
              ts_adjusted_cycles <= resize(unsigned(ts_cycles_i) + unsigned(ts_latency_scaled), 29);
              ts_adjusted_tai    <= resize(unsigned(ts_tai_i), 40);

              ts_timeout_cycles <= resize(unsigned(ts_cycles_i) + unsigned(ts_timeout_scaled), 29);
              ts_timeout_tai    <= resize(unsigned(ts_tai_i), 40);

              State <= WRAP_ADJ_TS;
            end if;

          when WRAP_ADJ_TS =>


            if ts_adjusted_cycles >= f_cycles_counter_range then
              ts_adjusted_cycles <= ts_adjusted_cycles - f_cycles_counter_range;
              ts_adjusted_tai    <= ts_adjusted_tai + 1;
            end if;

            if ts_timeout_cycles >= f_cycles_counter_range then
              ts_timeout_cycles <= ts_timeout_cycles - f_cycles_counter_range;
              ts_timeout_tai    <= ts_timeout_tai + 1;
            end if;

            state <= CHECK_LATE;

          when CHECK_LATE =>

            if tm_time_valid_i = '0' then
              late  <= '1';
              state <= IDLE;
            end if;


            if ts_adjusted_tai < tm_tai_d then
              late  <= '1';
              State <= IDLE;
            elsif ts_adjusted_tai = tm_tai_d and ts_adjusted_cycles <= tm_cycles_scaled_d then
              late  <= '1';
              State <= IDLE;
            else
              State <= WAIT_TRIG;
            end if;

          when WAIT_TRIG =>

            if tm_tai_d > ts_timeout_tai or
              (ts_timeout_tai = tm_tai_d and tm_cycles_scaled_d > ts_timeout_cycles) then
              timeout <= '1';
              State   <= IDLE;
            end if;


            if ts_adjusted_cycles = tm_cycles_scaled_d and ts_adjusted_tai = tm_tai_d then
              match <= '1';
              State <= IDLE;
            end if;

        end case;
      end if;
    end if;
  end process;

  match_o <= match;
  late_o  <= late;
  timeout_o <= timeout;

end rtl;
