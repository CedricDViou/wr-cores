library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gencores_pkg.all;

entity gtx_tx_reset is

  port (
    -- uncorrelated clock (we use DDMTD here) to ensure repeated resetting of
    -- the TX path will sooner or later get to the TX divider bin we want
    clk_dmtd_i : in std_logic;

    -- TX clock
    clk_tx_i : in std_logic;

    -- Master reset (clk_tx_i domain)
    rst_i : in std_logic;

    -- Sw reset (treat as async)
    rst_sw_i : in std_logic;

    -- TX PLL lock detect
    txpll_lockdet_i : in std_logic;

    -- GTX TX divider reset
    gtx_test_o : out std_logic_vector(12 downto 0);

    -- GTX TX path reset (async)
    gtx_tx_reset_o : out std_logic;

    -- GTX TX reset done (also async)
    gtx_tx_reset_done_i : in std_logic;

    -- DOne indication
    done_o : out std_logic
    );

end gtx_tx_reset;


architecture behavioral of gtx_tx_reset is

  type t_state is (MASTER_RST, WAIT_MASTER_RST1, WAIT_MASTER_RST2, START_DOUBLE_RESET, PAUSE, FIRST_RST, PAUSE2, SECOND_RST, DONE);

  signal state   : t_state;
  signal counter : unsigned(15 downto 0);

  signal master_reset, master_reset_n            : std_logic;
  signal txpll_lockdet_txclk     : std_logic;
  signal gtx_tx_reset_done_txclk : std_logic;
  signal rst_txclk, rst_sw_txclk : std_logic;
  signal trigger_tx_reset_p : std_logic;

begin  -- behavioral

  U_SyncReset : gc_sync_ffs
    port map
    (
      clk_i    => clk_tx_i,
      rst_n_i  => '1',
      data_i   => rst_i,
      synced_o => rst_txclk);

  U_SyncResetSW : gc_sync_ffs
    port map
    (
      clk_i    => clk_tx_i,
      rst_n_i  => '1',
      data_i   => rst_sw_i,
      synced_o => rst_sw_txclk);

  master_reset <= rst_sw_txclk or rst_txclk;

  U_SyncTxPLLLockDet : gc_sync_ffs
    port map
    (
      clk_i    => clk_tx_i,
      rst_n_i  => '1',
      data_i   => txpll_lockdet_i,
      synced_o => txpll_lockdet_txclk);

  U_SyncTxResetDone : gc_sync_ffs
    port map
    (
      clk_i    => clk_tx_i,
      rst_n_i  => '1',
      data_i   => gtx_tx_reset_done_i,
      synced_o => gtx_tx_reset_done_txclk);


  master_reset_n <= not master_reset;
  
  U_SyncTxReset : gc_pulse_synchronizer
    port map (
      clk_in_i  => clk_tx_i,
      clk_out_i => clk_dmtd_i,
      rst_n_i   => master_reset_n,
      d_ready_o => open,
      d_p_i     => trigger_tx_reset_p,
      q_p_o     => gtx_tx_reset_o);

  process(clk_tx_i)
  begin
    if rising_edge(clk_tx_i) then
      if master_reset = '1' then
        state   <= MASTER_RST;
        counter <= (others => '0');
        trigger_tx_reset_p <= '0';
        gtx_test_o <= "1000000000000";
        done_o <= '0';
        
      else
        case state is
          when MASTER_RST =>
            trigger_tx_reset_p <= '1';
            counter <= (others => '0');
            state <= WAIT_MASTER_RST1;

          when WAIT_MASTER_RST1 =>
            trigger_tx_reset_p <= '0';
            counter <= counter + 1;
            
            if ( counter = 1024 ) then
              state <= WAIT_MASTER_RST2;
            end if;

          when WAIT_MASTER_RST2 =>
            if gtx_tx_reset_done_txclk = '1' then
              state <= START_DOUBLE_RESET;
            end if;
          
          when START_DOUBLE_RESET =>
            counter    <= (others => '0');
            gtx_test_o <= "1000000000000";

            if(txpll_lockdet_txclk = '1') then
              state <= PAUSE;
            end if;

          when PAUSE =>
            counter    <= counter + 1;
            gtx_test_o <= "1000000000000";
            if(counter = 1024) then
              state <= FIRST_RST;
            end if;

          when FIRST_RST =>
            counter    <= counter + 1;
--            gtx_test_o <= "1000000000010";
            if(counter = 1024 + 256) then
              state <= PAUSE2;
            end if;
          when PAUSE2 =>
            counter    <= counter + 1;
            gtx_test_o <= "1000000000000";
            if(counter = 1024 + 2*256) then
              state <= SECOND_RST;
            end if;
          when SECOND_RST =>
            counter    <= counter + 1;
--            gtx_test_o <= "1000000000010";
            if(counter = 1024 + 3*256) then
              state <= DONE;
            end if;

          when DONE =>
            gtx_test_o <= "1000000000000";
            done_o <= '1';

            if txpll_lockdet_txclk = '0' then
              state <= MASTER_RST;
            end if;

            

            
        end case;
      end if;
    end if;
  end process;



end behavioral;
