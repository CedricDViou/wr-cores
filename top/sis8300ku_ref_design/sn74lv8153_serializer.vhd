library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sn74lv8153_serializer is
  generic (
    g_clock_freq : integer := 125000000
    );
  port (
    clk_i   : in  std_logic;
    rst_n_i : in  std_logic;
    req_o   : out std_logic;
    d_i     : in  std_logic_vector(6 downto 0);
    q_o     : out std_logic
    );
end entity; -- sn74lv8153_serializer


architecture rtl of sn74lv8153_serializer is

  constant c_bit_time : unsigned(15 downto 0) := to_unsigned(g_clock_freq / 10000, 16);

  signal div_cnt    : unsigned(15 downto 0)        := (others => '0');
  signal bit_cnt    : unsigned(3 downto 0)         := (others => '0');
  signal div_pulse  : std_logic                    := '0';
  signal req, req_d : std_logic                    := '0';
  signal dreg       : std_logic_vector(6 downto 0) := (others => '0');

begin

  p_gen_div_clock : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        div_pulse <= '0';
        div_cnt   <= (others => '0');
      else
        if div_cnt = c_bit_time then
          div_pulse <= '1';
          div_cnt   <= (others => '0');
        else
          div_pulse <= '0';
          div_cnt   <= div_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  p_serializer : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        bit_cnt <= (others => '0');
        req     <= '0';
        req_d   <= '0';
        dreg <= (others => '0');
        q_o <= '1';
      else
        req_d <= req;

        if (req_d = '1') then
          dreg <= d_i;
        end if;

        if(div_pulse = '1') then
          if bit_cnt = 9 then
            bit_cnt <= (others => '0');
            req     <= '1';
          else
            bit_cnt <= bit_cnt + 1;
            req     <= '0';
          end if;
        else
            req <= '0';
        end if;

        case bit_cnt is
          when "0000" => q_o <= '0';
          when "0001" => q_o <= '1';
          -- Address Bit A0 to A2
          when "0010" => q_o <= dreg(4);
          when "0011" => q_o <= dreg(5);
          when "0100" => q_o <= dreg(6);
          -- Data Bits D0 to D3 / D4 to D7
          when "0101" => q_o <= dreg(0);
          when "0110" => q_o <= dreg(1);
          when "0111" => q_o <= dreg(2);
          when "1000" => q_o <= dreg(3);
          when "1001" => q_o <= '1';
          when others => null;
        end case;
      end if;
    end if;
  end process;

  req_o <= req;

end architecture; -- rtl
