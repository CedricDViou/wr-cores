library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gtx_comma_detect is
  port (
    clk_rx_i : in std_logic;
    rst_i    : in std_logic;

    rx_k_i    : in std_logic_vector(1 downto 0);
    rx_data_i : in std_logic_vector(15 downto 0);

    link_up_o : out std_logic;
    aligned_o : out std_logic
    );

end gtx_comma_detect;

architecture rtl of gtx_comma_detect is

  type t_state is (SYNC_LOST, SYNC_CHECK, SYNC_ACQUIRED);

  constant c_IDLE_LENGTH_UP   : integer := 5;
  constant c_IDLE_LENGTH_LOSS : integer := 1000;

  constant c_COMMA_SHIFT_WE_WANT : std_logic_vector(5 downto 0) := "101001";
  signal comma                   : std_logic_vector(5 downto 0);
  signal first_comma             : std_logic_vector(5 downto 0);
  signal cnt                     : unsigned(15 downto 0);
  signal state                   : t_state;

begin

  process(clk_rx_i)
  begin
    if rising_edge(clk_rx_i) then
      if rst_i = '1' then
        comma <= (others => '0');
      else
        case (rx_k_i & rx_data_i) is
          when "00" & x"af21" => comma <= "100000";
          when "10" & x"5fa2" => comma <= "100001";
          when "10" & x"9484" => comma <= "100010";
          when "01" & x"4ae5" => comma <= "100011";
          when "01" & x"3728" => comma <= "100100";
          when "10" & x"e54a" => comma <= "100101";
          when "10" & x"2837" => comma <= "100110";
          when "01" & x"f912" => comma <= "100111";
          when "00" & x"21af" => comma <= "101000";
          when "10" & x"bc50" => comma <= "101001";
          when "01" & x"e5f2" => comma <= "101010";
          when "10" & x"f2e5" => comma <= "101011";
          when "01" & x"8494" => comma <= "101100";
          when "10" & x"ca15" => comma <= "101101";
          when "10" & x"12f9" => comma <= "101110";
          when "01" & x"be44" => comma <= "101111";
          when "01" & x"50bc" => comma <= "110000";
          when "01" & x"15ca" => comma <= "110001";
          when "10" & x"44be" => comma <= "110010";
          when "01" & x"a25f" => comma <= "110011";
          when others =>
            comma <= (others => '0');
        end case;
      end if;
    end if;
  end process;

  process(clk_rx_i)
  begin
    if rising_edge(clk_rx_i) then
      if rst_i = '1' then
        state <= SYNC_LOST;
      else
        case state is
          when SYNC_LOST =>
            link_up_o <= '0';
            aligned_o <= '0';

            if comma /= "000000" then
              first_comma <= comma;
              state       <= SYNC_CHECK;
              cnt         <= (others => '0');
            end if;

          when SYNC_CHECK =>
            if comma = first_comma then
              if cnt = c_IDLE_LENGTH_UP then
                state <= SYNC_ACQUIRED;
                cnt   <= (others => '0');
              else
                cnt <= cnt + 1;

              end if;
            else
              state <= SYNC_LOST;
            end if;

          when SYNC_ACQUIRED =>
            link_up_o <= '1';

            if(comma = c_COMMA_SHIFT_WE_WANT) then
              aligned_o <= '1';
            end if;

            if comma = first_comma then
              cnt <= (others => '0');
            else
              cnt <= cnt + 1;
              if cnt = c_IDLE_LENGTH_LOSS then
                state <= SYNC_LOST;
              end if;
            end if;
        end case;
      end if;
    end if;
  end process;


end rtl;

