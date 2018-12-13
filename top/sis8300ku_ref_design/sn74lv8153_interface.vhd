library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sn74lv8153_interface is
  generic (
    g_clock_freq : integer := 125000000
  );
  port (
    clk_i    : in  std_logic;
    rst_n_i  : in  std_logic;
    d_i      : in  std_logic_vector(15 downto 0);
    serial_o : out std_logic
  );
end entity; -- sn74lv8153_interface


architecture rtl of sn74lv8153_interface is

  component sn74lv8153_serializer is
    generic (
      g_clock_freq : integer
    );
    port (
      clk_i   : in  std_logic;
      rst_n_i : in  std_logic;
      req_o   : out std_logic;
      d_i     : in  std_logic_vector(6 downto 0);
      q_o     : out std_logic
    );
  end component; -- sn74lv8153_serializer

  type t_state is (LATCH_DATA, WORD0, WORD1, WORD2, WORD3);

  signal state : t_state                       := LATCH_DATA;
  signal dreg  : std_logic_vector(15 downto 0) := (others => '0');
  signal dout  : std_logic_vector(6 downto 0)  := (others => '0');
  signal req   : std_logic                     := '0';

begin

  U_Serializer : sn74lv8153_serializer
    generic map (
      g_clock_freq => g_clock_freq
    )
    port map (
      clk_i   => clk_i,
      rst_n_i => rst_n_i,
      req_o   => req,
      d_i     => dout,
      q_o     => serial_o
    );

  p_fsm : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        state <= LATCH_DATA;
        dout <= (others => '0');
      else
        case state is
          when LATCH_DATA =>
            dreg  <= d_i;
            state <= WORD0;
          -- first chip (address "000")
          when WORD0 =>
            if(req = '1') then
              dout  <= "000" & dreg(3 downto 0);
              state <= WORD1;
            end if;
          when WORD1 =>
            if(req = '1') then
              dout  <= "000" & dreg(7 downto 4);
              state <= WORD2;
            end if;
          -- second chip (address "001")
          when WORD2 =>
            if(req = '1') then
              dout  <= "001" & dreg(11 downto 8);
              state <= WORD3;
            end if;
          when WORD3 =>
            if(req = '1') then
              dout  <= "001" & dreg(15 downto 12);
              state <= LATCH_DATA;
            end if;
        end case;
      end if;
    end if;
  end process;

end rtl;
