library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gencores_pkg.all;
use work.disparity_gen_pkg.all;

entity wr_gthe3_phy_family7 is

  generic (
    -- set to non-zero value to speed up the simulation by reducing some delays
    g_simulation : integer := 0
    );

  port (
    -- Dedicated reference 125 MHz clock for the GTX transceiver
    clk_gth_p_i : in std_logic;
    clk_gth_n_i : in std_logic;

    clk_freerun_i : in std_logic;

    -- TX path, synchronous to tx_out_clk_o (62.5 MHz):
    tx_out_clk_o : out std_logic;
    tx_locked_o  : out std_logic;

    -- data input (8 bits, not 8b10b-encoded)
    tx_data_i : in std_logic_vector(15 downto 0);

    -- 1 when tx_data_i contains a control code, 0 when it's a data byte
    tx_k_i : in std_logic_vector(1 downto 0);

    -- disparity of the currently transmitted 8b10b code (1 = plus, 0 = minus).
    -- Necessary for the PCS to generate proper frame termination sequences.
    -- Generated for the 2nd byte (LSB) of tx_data_i.
    tx_disparity_o : out std_logic;

    -- Encoding error indication (1 = error, 0 = no error)
    tx_enc_err_o : out std_logic;

    -- RX path, synchronous to ch0_rx_rbclk_o.

    -- RX recovered clock
    rx_rbclk_o : out std_logic;

    -- 8b10b-decoded data output. The data output must be kept invalid before
    -- the transceiver is locked on the incoming signal to prevent the EP from
    -- detecting a false carrier.
    rx_data_o : out std_logic_vector(15 downto 0);

    -- 1 when the byte on rx_data_o is a control code
    rx_k_o : out std_logic_vector(1 downto 0);

    -- encoding error indication
    rx_enc_err_o : out std_logic;

    -- RX bitslide indication, indicating the delay of the RX path of the
    -- transceiver (in UIs). Must be valid when ch0_rx_data_o is valid.
    rx_bitslide_o : out std_logic_vector(4 downto 0);


    -- reset input, active hi
    rst_i    : in std_logic;
    loopen_i : in std_logic_vector(2 downto 0);

    debug_i : in  std_logic_vector(15 downto 0);
    debug_o : out std_logic_vector(15 downto 0);

    pad_txn_o : out std_logic;
    pad_txp_o : out std_logic;

    pad_rxn_i : in std_logic := '0';
    pad_rxp_i : in std_logic := '0';

    rdy_o : out std_logic);
end wr_gthe3_phy_family7;

architecture rtl of wr_gthe3_phy_family7 is

  component BUFG_GT_SYNC is
    port (
      CESYNC  : out std_ulogic;
      CLRSYNC : out std_ulogic;
      CE      : in  std_ulogic;
      CLK     : in  std_ulogic;
      CLR     : in  std_ulogic);
  end component BUFG_GT_SYNC;

  component BUFG_GT is
    port (
      O       : out std_ulogic;
      CE      : in  std_ulogic;
      CEMASK  : in  std_ulogic;
      CLR     : in  std_ulogic;
      CLRMASK : in  std_ulogic;
      DIV     : in  std_logic_vector(2 downto 0);
      I       : in  std_ulogic);
  end component BUFG_GT;


  component IBUFDS_GTE3 is
    generic (
      REFCLK_EN_TX_PATH  : bit;
      REFCLK_HROW_CK_SEL : std_logic_vector (1 downto 0);
      REFCLK_ICNTL_RX    : std_logic_vector (1 downto 0));
    port (
      O     : out std_ulogic;
      ODIV2 : out std_ulogic;
      CEB   : in  std_ulogic;
      I     : in  std_ulogic;
      IB    : in  std_ulogic);
  end component IBUFDS_GTE3;

  signal CPLLPD          : std_logic;
  signal CPLLLOCK        : std_logic;
  signal RXCDRLOCK       : std_logic;
  signal RXRESETDONE     : std_logic;
  signal GTRXRESET       : std_logic;
  signal GTTXRESET       : std_logic;
  signal TXRESETDONE     : std_logic;
  signal TXPROGDIVRESET  : std_logic;
  signal GTHTXN          : std_logic;
  signal GTHTXP          : std_logic;
  signal GTPOWERGOOD     : std_logic;
  signal RXBYTEISALIGNED : std_logic;
  signal RXCOMMADET      : std_logic;
  signal RXCTRL0         : std_logic_vector(15 downto 0);
  signal RXDATA          : std_logic_vector(127 downto 0);
  signal RXOUTCLK        : std_logic;
  signal RXPHALIGNDONE   : std_logic;
  signal RXPMARESETDONE  : std_logic;
  signal RXSYNCDONE      : std_logic;
  signal TXOUTCLK        : std_logic;
  signal TXPHALIGNDONE   : std_logic;
  signal TXPMARESETDONE  : std_logic;
  signal TXSYNCDONE      : std_logic;
  signal DRPCLK          : std_logic;
  signal GTHRXN          : std_logic;
  signal GTHRXP          : std_logic;
  signal GTREFCLK0       : std_logic;
  signal RXPROGDIVRESET  : std_logic;
  signal RXSLIDE         : std_logic;
  signal RXSYNCALLIN     : std_logic;
  signal RXUSERRDY       : std_logic;
  signal RXUSRCLK2       : std_logic;
  signal TXCTRL2         : std_logic_vector(7 downto 0);
  signal TXDATA          : std_logic_vector(127 downto 0);
  signal TXDLYSRESET     : std_logic;
  signal TXSYNCALLIN     : std_logic;
  signal TXUSERRDY       : std_logic;
  signal TXUSRCLK2       : std_logic;
  signal RXDLYSRESET     : std_logic;

  signal serdes_ready, rx_comma_det, rx_byte_is_aligned, rx_slide : std_logic;
  signal rx_synced, rst_rxclk                                     : std_logic;

  signal rx_data_int : std_logic_vector(15 downto 0);
  signal rx_k_int    : std_logic_vector(1 downto 0);

  signal ready_txusrclk, ready_rxusrclk : std_logic;

   signal cur_disp : t_8b10b_disparity;

  signal rx_active  : std_logic;
  signal tx_active  : std_logic;
  signal reset_done : std_logic;

  signal TXPMARESETDONE_n, RXPMARESETDONE_n : std_logic;
  signal tx_clk_CESYNC, rx_clk_CESYNC       : std_logic;
  signal tx_clk_CLRSYNC, rx_clk_CLRSYNC     : std_logic;

  signal rst_master_n : std_logic;

  signal tx_buffer_bypass_done : std_logic;
  signal rx_buffer_bypass_done : std_logic;

  function f_is_synthesis return boolean is
  begin
    -- synthesis translate_off
    return false;
    -- synthesis translate_on
    return true;
  end function;



begin

  rst_master_n <= not rst_i;

  TXCTRL2(7 downto 2) <= (others => '0');
  TXCTRL2(1)          <= tx_k_i(1);
  TXCTRL2(0)          <= tx_k_i(0);

  TXDATA(15 downto 0)   <= tx_data_i;
  TXDATA(127 downto 16) <= (others => '0');

  rx_k_int    <= RXCTRL0(1 downto 0);
  rx_data_int <= RXDATA(15 downto 0);


  RXSLIDE <= '0';


  --  U_Bitslide : gtp_bitslide
  --    generic map (
  --      g_simulation => g_simulation,
  --      g_target     => "virtex6")
  --    port map (
  --      gtp_rst_i                => rst_i,
  --      gtp_rx_clk_i             => rx_clk,
  --      gtp_rx_comma_det_i       => rx_comma_det,
  --      gtp_rx_byte_is_aligned_i => rx_byte_is_aligned,
  --      serdes_ready_i           => serdes_ready,
  --      gtp_rx_slide_o           => rx_slide,
  --      gtp_rx_cdr_rst_o         => open,
  --      bitslide_o               => rx_bitslide_o,
  --      synced_o                 => rx_synced);

  -- tx_is_k_swapped <=  tx_k_i(0) & tx_k_i(1);
  --  tx_data_swapped <= tx_data_i(7 downto 0) & tx_data_i(15 downto 8);

  -- U_Wrapped_GTH : wr_gth_wrapper_example_top
  --   port map (
  --     ch0_gthrxn_in  => pad_rxn_i,
  --     ch0_gthrxp_in  => pad_rxp_i,
  --     ch0_gthtxn_out => pad_txn_o,
  --     ch0_gthtxp_out => pad_txp_o,

  --     hb_gtwiz_reset_all_in         => rst_i,
  --     hb_gtwiz_reset_clk_freerun_in => clk_freerun_i,

  --     mgtrefclk0_x0y2_n    => clk_gth_n_i,
  --     mgtrefclk0_x0y2_p    => clk_gth_p_i,
  --     rx_byte_is_aligned_o => rx_byte_is_aligned,
  --     rx_clk_o             => rx_clk,
  --     rx_comma_det_o       => rx_comma_det,
  --     rx_data_o            => rx_data_int,
  --     rx_k_o               => rx_k_int,
  --     rx_slide_i           => rx_slide,
  --     tx_clk_o             => tx_clk,
  --     tx_data_i            => tx_data_swapped,
  --     tx_k_i               => tx_is_k_swapped,
  --     ready_o              => serdes_ready);


  U_Ref_Clock_Buffer : IBUFDS_GTE3
    generic map (
      REFCLK_EN_TX_PATH  => '0',
      REFCLK_HROW_CK_SEL => "00",
      REFCLK_ICNTL_RX    => "00")
    port map (
      O     => GTREFCLK0,
      ODIV2 => open,
      CEB   => '0',
      I     => clk_gth_p_i,
      IB    => clk_gth_n_i);

  U_Sync_TX_Clock_Reset : BUFG_GT_SYNC
    port map (
      CESYNC  => tx_clk_CESYNC,
      CLRSYNC => tx_clk_CLRSYNC,
      CE      => '1',
      CLK     => TXOUTCLK,
      CLR     => TXPMARESETDONE_n);

  TXPMARESETDONE_n <= not TXPMARESETDONE;
  U_TX_Clock_Buffer : BUFG_GT port map
    (
      CE      => tx_clk_CESYNC,
      CEMASK  => '0',
      CLR     => tx_clk_CLRSYNC,
      CLRMASK => '0',
      DIV     => "001",
      I       => TXOUTCLK,
      O       => TXUSRCLK2
      );

  U_Sync_RX_Clock_Reset : BUFG_GT_SYNC
    port map (
      CESYNC  => rx_clk_CESYNC,
      CLRSYNC => rx_clk_CLRSYNC,
      CE      => '1',
      CLK     => RXOUTCLK,
      CLR     => RXPMARESETDONE_n);

  RXPMARESETDONE_n <= not RXPMARESETDONE;
  U_RX_Clock_Buffer : BUFG_GT port map
    (
      CE      => rx_clk_CESYNC,
      CEMASK  => '0',
      CLR     => rx_clk_CLRSYNC,
      CLRMASK => '0',
      DIV     => "000",
      I       => RXOUTCLK,
      O       => RXUSRCLK2
      );

  U_GenRXActive_Reset : gc_sync_ffs
    port map (
      clk_i    => RXUSRCLK2,
      rst_n_i  => rst_master_n,
      data_i   => '1',
      synced_o => rx_active);

  U_GenTXActive_Reset : gc_sync_ffs
    port map (
      clk_i    => TXUSRCLK2,
      rst_n_i  => rst_master_n,
      data_i   => '1',
      synced_o => tx_active);


  U_TX_Buffer_Bypass : entity work.wr_gthe3_tx_buffer_bypass
    port map (
      clk_free_i    => clk_freerun_i,
      rst_i         => rst_i,
      TXUSRCLK2_i   => TXUSRCLK2,
      TXRESETDONE_i => TXRESETDONE,
      TXDLYSRESET_o => TXDLYSRESET,
      TXSYNCDONE_i  => TXSYNCDONE,
      done_o        => tx_buffer_bypass_done);

  U_RX_Buffer_Bypass : entity work.wr_gthe3_rx_buffer_bypass
    port map (
      clk_free_i    => clk_freerun_i,
      rst_i         => rst_i,
      RXUSRCLK2_i   => RXUSRCLK2,
      RXRESETDONE_i => RXRESETDONE,
      RXDLYSRESET_o => RXDLYSRESET,
      RXSYNCDONE_i  => RXSYNCDONE,
      done_o        => rx_buffer_bypass_done);


  -- tx_active -> userclk_tx_reset and deassert tx_active on rst master, deassert after few cycles of
  -- txusrclk2. same for rx_active.

  U_Reset_FSM : entity work.wr_gthe3_reset
    port map (
      rst_i            => rst_i,
      clk_free_i       => clk_freerun_i,
      CPLLPD_o         => CPLLPD,
      CPLLLOCK_i       => CPLLLOCK,
      RXCDRLOCK_i      => RXCDRLOCK,
      RXRESETDONE_i    => RXRESETDONE,
      GTRXRESET_o      => GTRXRESET,
      TXUSERRDY_o      => TXUSERRDY,
      RXPROGDIVRESET_o => RXPROGDIVRESET,
      GTTXRESET_o      => GTTXRESET,
      TXRESETDONE_i    => TXRESETDONE,
      TXPROGDIVRESET_o => TXPROGDIVRESET,
      RXUSERRDY_o      => RXUSERRDY,
      rx_active_i      => rx_active,
      tx_active_i      => tx_active,
      done_o           => reset_done);

  U_Wrapped_GTHE3 : entity work.wr_gthe3_wrapper
    port map (
      CPLLPD          => CPLLPD,
      CPLLLOCK        => CPLLLOCK,
      RXCDRLOCK       => RXCDRLOCK,
      RXRESETDONE     => RXRESETDONE,
      GTRXRESET       => GTRXRESET,
      RXPROGDIVRESET  => RXPROGDIVRESET,
      GTTXRESET       => GTTXRESET,
      TXRESETDONE     => TXRESETDONE,
      TXPROGDIVRESET  => TXPROGDIVRESET,
      GTHTXN          => GTHTXN,
      GTHTXP          => GTHTXP,
      GTPOWERGOOD     => GTPOWERGOOD,
      RXBYTEISALIGNED => RXBYTEISALIGNED,
      RXCOMMADET      => RXCOMMADET,
      RXCTRL0         => RXCTRL0,
      RXDATA          => RXDATA,
      RXOUTCLK        => RXOUTCLK,
      RXPHALIGNDONE   => RXPHALIGNDONE,
      RXPMARESETDONE  => RXPMARESETDONE,
      RXSYNCDONE      => RXSYNCDONE,
      TXOUTCLK        => TXOUTCLK,
      TXPHALIGNDONE   => TXPHALIGNDONE,
      TXPMARESETDONE  => TXPMARESETDONE,
      TXSYNCDONE      => TXSYNCDONE,
      DRPCLK          => DRPCLK,
      GTHRXN          => GTHRXN,
      GTHRXP          => GTHRXP,
      GTREFCLK0       => GTREFCLK0,
      RXDLYSRESET     => RXDLYSRESET,
      RXSLIDE         => RXSLIDE,
      RXSYNCALLIN     => RXSYNCALLIN,
      RXUSERRDY       => RXUSERRDY,
      RXUSRCLK2       => RXUSRCLK2,
      TXCTRL2         => TXCTRL2,
      TXDATA          => TXDATA,
      TXDLYSRESET     => TXDLYSRESET,
      TXSYNCALLIN     => TXSYNCALLIN,
      TXUSERRDY       => TXUSERRDY,
      TXUSRCLK2       => TXUSRCLK2);

  DRPCLK <= clk_freerun_i;

  TXSYNCALLIN <= TXPHALIGNDONE;
  RXSYNCALLIN <= RXPHALIGNDONE;

  pad_txn_o <= GTHTXN;
  pad_txp_o <= GTHTXP;

  GTHRXN <= pad_rxn_i;
  GTHRXP <= pad_rxp_i;

  rx_synced <= '1';

   p_gen_rx_outputs : process(RXUSRCLK2, ready_rxusrclk)
   begin
     if(ready_rxusrclk = '0') then
       rx_data_o    <= (others => '0');
       rx_k_o       <= (others => '0');
       rx_enc_err_o <= '0';
     elsif rising_edge(RXUSRCLK2) then
       if(ready_rxusrclk = '1' and rx_synced = '1') then
         rx_data_o    <= rx_data_int(7 downto 0) & rx_data_int(15 downto 8);
         rx_k_o       <= rx_k_int(0) & rx_k_int(1);
         rx_enc_err_o <= '0';  --rx_disp_err(0) or rx_disp_err(1) or rx_code_err(0) or rx_code_err(1);
       else
         rx_data_o    <= (others => '1');
         rx_k_o       <= (others => '1');
         rx_enc_err_o <= '1';
       end if;
     end if;
   end process;

  p_gen_tx_disparity : process(TXUSRCLK2)
  begin
    if rising_edge(TXUSRCLK2) then
      if ready_txusrclk = '0' then
        cur_disp <= RD_MINUS;
      else
        cur_disp <= f_next_8b10b_disparity16(cur_disp, tx_k_i, tx_data_i);
      end if;
    end if;
  end process;

  tx_disparity_o <= to_std_logic(cur_disp);

  gen_simulation : if not f_is_synthesis generate
    tx_out_clk_o <= TXUSRCLK2 after 0.5 ns;
    rx_rbclk_o   <= RXUSRCLK2 after 0.5 ns;
  end generate gen_simulation;

  gen_synthesis : if f_is_synthesis generate
    tx_out_clk_o <= TXUSRCLK2;
    rx_rbclk_o   <= RXUSRCLK2;
  end generate gen_synthesis;


  -- rdy_o <= serdes_ready and rx_synced;
  -- tx_locked_o <= '1';
  -- tx_enc_err_o <= '0';


end rtl;


