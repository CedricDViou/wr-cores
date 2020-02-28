-------------------------------------------------------------------------------
-- Title      : Deterministic Xilinx GTX wrapper - kintex-7 top module
-- Project    : White Rabbit Switch
-------------------------------------------------------------------------------
-- File       : wr_gtx_phy_family7.vhd
-- Author     : Peter Jansweijer, Tomasz Wlostowski
-- Company    : CERN BE-CO-HT
-- Created    : 2013-04-08
-- Last update: 2013-04-08
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Dual channel wrapper for Xilinx Kintex-7 GTX adapted for
-- deterministic delays at 1.25 Gbps.
-------------------------------------------------------------------------------
--
-- Copyright (c) 2010 CERN
--
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.gnu.org/licenses/lgpl-2.1.html
-- 
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author    Description
-- 2013-04-08  0.1      PeterJ    Initial release based on "wr_gtx_phy_virtex6.vhd"
-- 2013-08-19  0.2      PeterJ    Implemented a small delay before a rx_cdr_lock is propgated
-- 2014-02_19  0.3      Peterj    Added tx_locked_o to indicate that the cpll reached the lock status
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gencores_pkg.all;

library unisim;
use unisim.vcomponents.all;

library work;
--use work.gencores_pkg.all;
use work.disparity_gen_pkg.all;

entity wr_gtx_phy_family7 is

  generic (
    -- set to non-zero value to speed up the simulation by reducing some delays
    g_simulation         : integer := 0
    );

  port (
    -- Dedicated reference 125 MHz clock for the GTX transceiver
    clk_gtx_i : in std_logic;

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
    rst_i         : in std_logic;
    loopen_i      : in std_logic_vector(2 downto 0);
    tx_prbs_sel_i : in std_logic_vector(2 downto 0);
    pad_txn_o : out std_logic;
    pad_txp_o : out std_logic;

    pad_rxn_i : in std_logic := '0';
    pad_rxp_i : in std_logic := '0';

    rdy_o     : out std_logic);
end wr_gtx_phy_family7;

architecture rtl of wr_gtx_phy_family7 is

  component WHITERABBIT_GTXE2_CHANNEL_WRAPPER_GT is
    generic
    (
        -- Simulation attributes
        GT_SIM_GTRESET_SPEEDUP    : string     :=  "TRUE";        -- Set to "TRUE" to speed up sim reset (Need Capital Letters!)
        RX_DFE_KL_CFG2_IN         : bit_vector :=   X"3010D90C";
        PMA_RSV_IN                : bit_vector :=   X"00018480";
        PCS_RSVD_ATTR_IN          : bit_vector :=   X"000000000000"
    );
    port 
    (
    --------------------------------- CPLL Ports -------------------------------
    CPLLFBCLKLOST_OUT                       : out  std_logic;
    CPLLLOCK_OUT                            : out  std_logic;
    CPLLLOCKDETCLK_IN                       : in   std_logic;
    CPLLREFCLKLOST_OUT                      : out  std_logic;
    CPLLRESET_IN                            : in   std_logic;
    -------------------------- Channel - Clocking Ports ------------------------
    GTREFCLK0_IN                            : in   std_logic;
    ---------------------------- Channel - DRP Ports  --------------------------
    DRPADDR_IN                              : in   std_logic_vector(8 downto 0);
    DRPCLK_IN                               : in   std_logic;
    DRPDI_IN                                : in   std_logic_vector(15 downto 0);
    DRPDO_OUT                               : out  std_logic_vector(15 downto 0);
    DRPEN_IN                                : in   std_logic;
    DRPRDY_OUT                              : out  std_logic;
    DRPWE_IN                                : in   std_logic;
    ------------------------------- Clocking Ports -----------------------------
    QPLLCLK_IN                              : in   std_logic;
    QPLLREFCLK_IN                           : in   std_logic;
    ------------------------------- Loopback Ports -----------------------------
    LOOPBACK_IN                             : in   std_logic_vector(2 downto 0);
    --------------------- RX Initialization and Reset Ports --------------------
    RXUSERRDY_IN                            : in   std_logic;
    -------------------------- RX Margin Analysis Ports ------------------------
    EYESCANDATAERROR_OUT                    : out  std_logic;
    ------------------------- Receive Ports - CDR Ports ------------------------
    RXCDRLOCK_OUT                           : out  std_logic;
    RXCDRRESET_IN                           : in   std_logic;
    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    RXUSRCLK_IN                             : in   std_logic;
    RXUSRCLK2_IN                            : in   std_logic;
    ------------------ Receive Ports - FPGA RX interface Ports -----------------
    RXDATA_OUT                              : out  std_logic_vector(15 downto 0);
    ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
    RXDISPERR_OUT                           : out  std_logic_vector(1 downto 0);
    RXNOTINTABLE_OUT                        : out  std_logic_vector(1 downto 0);
    --------------------------- Receive Ports - RX AFE -------------------------
    GTXRXP_IN                               : in   std_logic;
    ------------------------ Receive Ports - RX AFE Ports ----------------------
    GTXRXN_IN                               : in   std_logic;
    -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
    RXBYTEISALIGNED_OUT                     : out  std_logic;
    RXCOMMADET_OUT                          : out  std_logic;
    --------------------- Receive Ports - RX Equilizer Ports -------------------
    RXLPMHFHOLD_IN                          : in   std_logic;
    RXLPMLFHOLD_IN                          : in   std_logic;
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    RXOUTCLK_OUT                            : out  std_logic;
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    GTRXRESET_IN                            : in   std_logic;
    RXPMARESET_IN                           : in   std_logic;
    ---------------------- Receive Ports - RX gearbox ports --------------------
    RXSLIDE_IN                              : in   std_logic;
    ------------------- Receive Ports - RX8B/10B Decoder Ports -----------------
    RXCHARISK_OUT                           : out  std_logic_vector(1 downto 0);
    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    RXRESETDONE_OUT                         : out  std_logic;
    --------------------- TX Initialization and Reset Ports --------------------
    GTTXRESET_IN                            : in   std_logic;
    TXUSERRDY_IN                            : in   std_logic;
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    TXUSRCLK_IN                             : in   std_logic;
    TXUSRCLK2_IN                            : in   std_logic;
    ------------------ Transmit Ports - TX Buffer Bypass Ports -----------------
    TXDLYEN_IN                              : in   std_logic;
    TXDLYSRESET_IN                          : in   std_logic;
    TXDLYSRESETDONE_OUT                     : out  std_logic;
    TXPHALIGN_IN                            : in   std_logic;
    TXPHALIGNDONE_OUT                       : out  std_logic;
    TXPHALIGNEN_IN                          : in   std_logic;
    TXPHDLYRESET_IN                         : in   std_logic;
    TXPHINIT_IN                             : in   std_logic;
    TXPHINITDONE_OUT                        : out  std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TXDATA_IN                               : in   std_logic_vector(15 downto 0);
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GTXTXN_OUT                              : out  std_logic;
    GTXTXP_OUT                              : out  std_logic;
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    TXOUTCLK_OUT                            : out  std_logic;
    TXOUTCLKFABRIC_OUT                      : out  std_logic;
    TXOUTCLKPCS_OUT                         : out  std_logic;
    --------------------- Transmit Ports - TX Gearbox Ports --------------------
    TXCHARISK_IN                            : in   std_logic_vector(1 downto 0);
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    TXRESETDONE_OUT                         : out  std_logic;
    ------------------ Transmit Ports - pattern Generator Ports ----------------
    TXPRBSSEL_IN                            : in   std_logic_vector(2 downto 0)
	);
  end component WHITERABBIT_GTXE2_CHANNEL_WRAPPER_GT;

  component BUFG
    port (
      O : out std_ulogic;
      I : in  std_ulogic);
  end component;

  component gtp_bitslide
    generic (
      g_simulation : integer;
      g_target     : string := "virtex6");
    port (
      gtp_rst_i                : in  std_logic;
      gtp_rx_clk_i             : in  std_logic;
      gtp_rx_comma_det_i       : in  std_logic;
      gtp_rx_byte_is_aligned_i : in  std_logic;
      serdes_ready_i           : in  std_logic;
      gtp_rx_slide_o           : out std_logic;
      gtp_rx_cdr_rst_o         : out std_logic;
      bitslide_o               : out std_logic_vector(4 downto 0);
      synced_o                 : out std_logic);
  end component;

  component whiterabbitgtx_wrapper_TX_STARTUP_FSM
    generic(
      EXAMPLE_SIMULATION       : integer := 0;
      STABLE_CLOCK_PERIOD      : integer range 4 to 250 := 8; --Period of the stable clock driving this state-machine, unit is [ns]
      RETRY_COUNTER_BITWIDTH   : integer range 2 to 8  := 8; 
      TX_QPLL_USED             : boolean := False;           -- the TX and RX Reset FSMs must
      RX_QPLL_USED             : boolean := False;           -- share these two generic values
      PHASE_ALIGNMENT_MANUAL   : boolean := True             -- Decision if a manual phase-alignment is necessary or the automatic 
                                                             -- is enough. For single-lane applications the automatic alignment is 
                                                             -- sufficient              
      );     
    port (
	  STABLE_CLOCK             : in  STD_LOGIC;              --Stable Clock, either a stable clock from the PCB
                                                             --or reference-clock present at startup.
      TXUSERCLK                : in  STD_LOGIC;              --TXUSERCLK as used in the design
      SOFT_RESET               : in  STD_LOGIC;              --User Reset, can be pulled any time
      QPLLREFCLKLOST           : in  STD_LOGIC;              --QPLL Reference-clock for the GT is lost
      CPLLREFCLKLOST           : in  STD_LOGIC;              --CPLL Reference-clock for the GT is lost
      QPLLLOCK                 : in  STD_LOGIC;              --Lock Detect from the QPLL of the GT
      CPLLLOCK                 : in  STD_LOGIC;              --Lock Detect from the CPLL of the GT
      TXRESETDONE              : in  STD_LOGIC;      
      MMCM_LOCK                : in  STD_LOGIC;      
      GTTXRESET                : out STD_LOGIC:='0';      
      MMCM_RESET               : out STD_LOGIC:='0';      
      QPLL_RESET               : out STD_LOGIC:='0';        --Reset QPLL
      CPLL_RESET               : out STD_LOGIC:='0';        --Reset CPLL
      TX_FSM_RESET_DONE        : out STD_LOGIC:='0';        --Reset-sequence has sucessfully been finished.
      TXUSERRDY                : out STD_LOGIC:='0';
      RUN_PHALIGNMENT          : out STD_LOGIC:='0';
      RESET_PHALIGNMENT        : out STD_LOGIC:='0';
      PHALIGNMENT_DONE         : in  STD_LOGIC;
      RETRY_COUNTER            : out STD_LOGIC_VECTOR (RETRY_COUNTER_BITWIDTH-1 downto 0):=(others=>'0')-- Number of 
                                                       -- Retries it took to get the transceiver up and running
      );
  end component;
  
  component whiterabbitgtx_wrapper_AUTO_PHASE_ALIGN     
    port (
	  STABLE_CLOCK             : in  STD_LOGIC;              --Stable Clock, either a stable clock from the PCB
                                                                --or reference-clock present at startup.
      RUN_PHALIGNMENT          : in  STD_LOGIC;              --Signal from the main Reset-FSM to run the auto phase-alignment procedure
      PHASE_ALIGNMENT_DONE     : out STD_LOGIC;              -- Auto phase-alignment performed sucessfully
      PHALIGNDONE              : in  STD_LOGIC;              --\ Phase-alignment signals from and to the
      DLYSRESET                : out STD_LOGIC;              -- |transceiver.
      DLYSRESETDONE            : in  STD_LOGIC;              --/
      RECCLKSTABLE             : in  STD_LOGIC               --/on the RX-side.
           
      );
  end component;

  constant c_rxcdrlock_max            : integer := 3;
  constant c_reset_cnt_max            : integer := 64;	-- Reset pulse width 64 * 8 = 512 ns
  
  signal rst_synced                   : std_logic;
  signal rst_int                      : std_logic;
--  signal trig0, trig1, trig2, trig3   : std_logic_vector(31 downto 0);

  signal rx_rec_clk_bufin             : std_logic;
  signal rx_rec_clk                   : std_logic;
  signal tx_out_clk_bufin             : std_logic;
  signal tx_out_clk                   : std_logic;
  signal rx_cdr_lock                  : std_logic;
  signal rx_cdr_lock_filtered         : std_logic;

  signal tx_rst_done, rx_rst_done     : std_logic;
  signal txpll_lockdet, rxpll_lockdet : std_logic;
  signal pll_lockdet                  : std_logic;
  signal cpll_lockdet                 : std_logic;
  signal gtreset                      : std_logic;

  signal rx_comma_det                 : std_logic;
  signal rx_byte_is_aligned           : std_logic;

  signal everything_ready             : std_logic;
  signal rx_slide                     : std_logic;
  signal rx_cdr_rst                   : std_logic;
  signal rx_synced                    : std_logic;
  signal rst_done                     : std_logic;
  signal rst_done_n                   : std_logic;
 
  signal rx_k_int                     : std_logic_vector(1 downto 0);
  signal rx_data_int                  : std_logic_vector(15 downto 0);

  signal rx_disp_err, rx_code_err     : std_logic_vector(1 downto 0);

  signal tx_is_k_swapped              : std_logic_vector(1 downto 0);
  signal tx_data_swapped              : std_logic_vector(15 downto 0);

  signal cur_disp                     : t_8b10b_disparity;
  
  signal cpllreset                    : std_logic;
  signal txuserrdy                    : std_logic;
  signal run_tx_phalignment           : std_logic;
  signal tx_phalignment_done          : std_logic;
  signal txphaligndone                : std_logic;
  signal txdlysreset                  : std_logic;
  signal txdlysresetdone              : std_logic;
  signal tx_fsm_rst_done              : std_logic;

begin  -- rtl

  -- There is a hen and egg problem with the reset in wr_core. Some reset signals are
  -- synchronized by rx_rbclk_o but this signal is de-asserted by the same reset.
  -- Therefore the rst_i is made edge sensitive and an internal reset pulse is generated for the PHY.
  -- After this reset pulse signal rx_rbclk_o starts clocking again and the (still asserted) system
  -- wide reset signal can by synchronized with this clock.

  -- Note that the rst_i originates from the clk_sys domain. Synchronisation is not needed
  -- when the clk_sys is phase locked with clk_gtx_i (which is usually the case) but is a safety
  -- measure. Add a false path for U_EdgeDet_rst_i_reg_sync0 to the timing constraints.
  U_EdgeDet_rst_i : gc_sync_ffs port map (
    clk_i    => clk_gtx_i,
    rst_n_i  => '1',
    data_i   => rst_i,
    ppulse_o => rst_synced);

  p_reset_pulse : process(clk_gtx_i, rst_synced)
    variable reset_cnt      : integer range 0 to c_reset_cnt_max;
  begin
    if(rst_synced = '1') then
      reset_cnt := 0;
      rst_int <= '1';
    elsif rising_edge(clk_gtx_i) then
      if reset_cnt /= c_reset_cnt_max then
        reset_cnt := reset_cnt + 1;
		rst_int <= '1';
      else
        rst_int <= '0';
      end if;
    end if;
  end process;  

  tx_enc_err_o <= '0';

  U_BUF_TxOutClk : BUFG
    port map (
      I => tx_out_clk_bufin,
      O => tx_out_clk);

   tx_out_clk_o <= tx_out_clk;
   tx_locked_o  <= cpll_lockdet;

      U_BUF_RxRecClk : BUFG
    port map (
      I => rx_rec_clk_bufin,
      O => rx_rec_clk);

  rx_rbclk_o <= rx_rec_clk;
    
  tx_is_k_swapped <= tx_k_i(0) & tx_k_i(1);
  tx_data_swapped <= tx_data_i(7 downto 0) & tx_data_i(15 downto 8);
  
U_GTX_INST : WHITERABBIT_GTXE2_CHANNEL_WRAPPER_GT
    generic map
    (
       -- Simulation attributes
       GT_SIM_GTRESET_SPEEDUP    =>  "TRUE"        -- Set to "true" to speed up sim reset
    )
    port map
    (
		--------------------------------- CPLL Ports -------------------------------
		CPLLFBCLKLOST_OUT          => open,
		CPLLLOCK_OUT               => cpll_lockdet,
		CPLLLOCKDETCLK_IN          => '0',
		CPLLREFCLKLOST_OUT         => open,
		CPLLRESET_IN               => cpllreset,
		-------------------------- Channel - Clocking Ports ------------------------
		GTREFCLK0_IN               => clk_gtx_i,
		---------------------------- Channel - DRP Ports  --------------------------
		DRPADDR_IN                 => (Others => '0'),
		DRPCLK_IN                  => '0',
		DRPDI_IN                   => (Others => '0'),
		DRPDO_OUT                  => open,
		DRPEN_IN                   => '0',
		DRPRDY_OUT                 => open,
		DRPWE_IN                   => '0',
		------------------------------- Clocking Ports -----------------------------
		QPLLCLK_IN                 => '0',
		QPLLREFCLK_IN              => '0',
		------------------------------- Loopback Ports -----------------------------
		LOOPBACK_IN                => loopen_i,
		--------------------- RX Initialization and Reset Ports --------------------
--		RXUSERRDY_IN               => rx_cdr_lock,
		RXUSERRDY_IN               => rx_cdr_lock_filtered,
		-------------------------- RX Margin Analysis Ports ------------------------
		EYESCANDATAERROR_OUT       => open,
		------------------------- Receive Ports - CDR Ports ------------------------
		RXCDRLOCK_OUT              => rx_cdr_lock,
		RXCDRRESET_IN              => rx_cdr_rst,   -- this port cannot be generated by the CoreGen GUI, it cannot be turnes "on"                           : in   std_logic;
		------------------ Receive Ports - FPGA RX Interface Ports -----------------
		RXUSRCLK_IN                => rx_rec_clk,
		RXUSRCLK2_IN               => rx_rec_clk,
		------------------ Receive Ports - FPGA RX interface Ports -----------------
		RXDATA_OUT                 => rx_data_int,
		------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
		RXDISPERR_OUT              => rx_disp_err,
		RXNOTINTABLE_OUT           => rx_code_err,
		--------------------------- Receive Ports - RX AFE -------------------------
		GTXRXP_IN                  => pad_rxp_i,
		------------------------ Receive Ports - RX AFE Ports ----------------------
		GTXRXN_IN                  => pad_rxn_i,
		-------------- Receive Ports - RX Byte and Word Alignment Ports ------------
		RXBYTEISALIGNED_OUT        => rx_byte_is_aligned,
		RXCOMMADET_OUT             => rx_comma_det,
		--------------------- Receive Ports - RX Equilizer Ports -------------------
		RXLPMHFHOLD_IN             => '0',          -- this port is always generated by the CoreGen GUI and cannot be turned "off"
		RXLPMLFHOLD_IN             => '0',          -- this port is always generated by the CoreGen GUI and cannot be turned "off"
		--------------- Receive Ports - RX Fabric Output Control Ports -------------
		RXOUTCLK_OUT               => rx_rec_clk_bufin,
		------------- Receive Ports - RX Initialization and Reset Ports ------------
		GTRXRESET_IN               => gtreset,
		RXPMARESET_IN              => '0',
		---------------------- Receive Ports - RX gearbox ports --------------------
		RXSLIDE_IN                 => rx_slide,
		------------------- Receive Ports - RX8B/10B Decoder Ports -----------------
		RXCHARISK_OUT              => rx_k_int,
		-------------- Receive Ports -RX Initialization and Reset Ports ------------
		RXRESETDONE_OUT            => rx_rst_done,
		--------------------- TX Initialization and Reset Ports --------------------
		GTTXRESET_IN               => gtreset,
		TXUSERRDY_IN               => txuserrdy,
		------------------ Transmit Ports - FPGA TX Interface Ports ----------------
		TXUSRCLK_IN                => tx_out_clk,
		TXUSRCLK2_IN               => tx_out_clk,
		------------------ Transmit Ports - TX Buffer Bypass Ports -----------------
		TXDLYEN_IN                 => '0',
		TXDLYSRESET_IN             => txdlysreset,
		TXDLYSRESETDONE_OUT        => txdlysresetdone,
		TXPHALIGN_IN               => '0',
		TXPHALIGNDONE_OUT          => txphaligndone,
		TXPHALIGNEN_IN             => '0',
		TXPHDLYRESET_IN            => '0',
		TXPHINIT_IN                => '0',
		TXPHINITDONE_OUT           => open,
		------------------ Transmit Ports - TX Data Path interface -----------------
		TXDATA_IN                  => tx_data_swapped,
--       TXDATA_IN                  => tx_data_i,
		---------------- Transmit Ports - TX Driver and OOB signaling --------------
		GTXTXN_OUT                 => pad_txn_o,
		GTXTXP_OUT                 => pad_txp_o,
		----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
		TXOUTCLK_OUT               => tx_out_clk_bufin,
		TXOUTCLKFABRIC_OUT         => open,
		TXOUTCLKPCS_OUT            => open,
		--------------------- Transmit Ports - TX Gearbox Ports --------------------
		TXCHARISK_IN               => tx_is_k_swapped,
--       TXCHARISK_IN               => tx_k_i,
		------------- Transmit Ports - TX Initialization and Reset Ports -----------
		TXRESETDONE_OUT            => tx_rst_done,
                ------------------ Transmit Ports - pattern Generator Ports ----------------
        TXPRBSSEL_IN               => tx_prbs_sel_i
    );
  
  U_txresetfsm_i:  whiterabbitgtx_wrapper_TX_STARTUP_FSM 

    generic map(
      EXAMPLE_SIMULATION           => g_simulation,
      STABLE_CLOCK_PERIOD          => 8,                     -- Period of the stable clock driving this state-machine, unit is [ns]
      RETRY_COUNTER_BITWIDTH       => 8,                  
      TX_QPLL_USED                 => FALSE,                 -- the TX and RX Reset FSMs must
      RX_QPLL_USED                 => FALSE,                 -- share these two generic values
      PHASE_ALIGNMENT_MANUAL       => TRUE                   -- Decision if a manual phase-alignment is necessary or the automatic 
                                                             -- is enough. For single-lane applications the automatic alignment is 
                                                             -- sufficient              
      )     
    port map ( 
      STABLE_CLOCK                 => clk_gtx_i,  			 --	in
      TXUSERCLK                    => tx_out_clk,            -- in
      SOFT_RESET                   => rst_int,               -- in
      QPLLREFCLKLOST               => '0',                   -- in
      --CPLLREFCLKLOST               => cpllrefclklost,        -- in
      CPLLREFCLKLOST               => '0',        -- in
      QPLLLOCK                     => '1',                   -- in
      CPLLLOCK                     => cpll_lockdet,          -- in
      TXRESETDONE                  => tx_rst_done,           -- in
      MMCM_LOCK                    => '1',                   -- in
      GTTXRESET                    => gtreset,               -- out
      MMCM_RESET                   => open,                  -- out
      QPLL_RESET                   => open,                  -- out
      CPLL_RESET                   => cpllreset,             -- out
      TX_FSM_RESET_DONE            => tx_fsm_rst_done,       -- out
      TXUSERRDY                    => txuserrdy,             -- out
      RUN_PHALIGNMENT              => run_tx_phalignment,    -- out
      RESET_PHALIGNMENT            => open,                  -- out
      PHALIGNMENT_DONE             => tx_phalignment_done,   -- in
      RETRY_COUNTER                => open                   -- out
      );

  U_tx_auto_phase_align_i : whiterabbitgtx_wrapper_AUTO_PHASE_ALIGN    
    port map ( 
      STABLE_CLOCK                 => clk_gtx_i,             -- in
      RUN_PHALIGNMENT              => run_tx_phalignment,    -- in
      PHASE_ALIGNMENT_DONE         => tx_phalignment_done,   -- out
      PHALIGNDONE                  => txphaligndone,         -- in
      DLYSRESET                    => txdlysreset,           -- out
      DLYSRESETDONE                => txdlysresetdone,       -- in
      RECCLKSTABLE                 => '1'                    -- in
    );

  U_Bitslide : gtp_bitslide
    generic map (
      g_simulation => g_simulation,
      g_target     => "kintex7")
    port map (
      gtp_rst_i                => rst_done_n,
      gtp_rx_clk_i             => rx_rec_clk,
      gtp_rx_comma_det_i       => rx_comma_det,
      gtp_rx_byte_is_aligned_i => rx_byte_is_aligned,
      serdes_ready_i           => everything_ready,
      gtp_rx_slide_o           => rx_slide,
      gtp_rx_cdr_rst_o         => rx_cdr_rst,
      bitslide_o               => rx_bitslide_o,
      synced_o                 => rx_synced);

  txpll_lockdet    <= cpll_lockdet;
--  rxpll_lockdet    <= rx_cdr_lock;
  rxpll_lockdet    <= rx_cdr_lock_filtered;
  rst_done         <= rx_rst_done and tx_rst_done and tx_fsm_rst_done;
  rst_done_n       <= not rst_done;
  pll_lockdet      <= txpll_lockdet and rxpll_lockdet;
  everything_ready <= rst_done and pll_lockdet;
  rdy_o            <= everything_ready;

--  trig2(3) <= rx_rst_done;
--  trig2(4) <= tx_rst_done;
--  trig2(5) <= txpll_lockdet;
--  trig2(6) <= rxpll_lockdet;
--  trig2(7) <= '1';

  -- 2013 August 19: Peterj
  -- The family 7 GTX seem to have an artifact in rx_cdr_lock. For no reason lock may be lost for a clock cycle
  -- There is not much information on the web but examples of "Series-7 Integrated Block for PCI Express" (pipe_user.v)
  -- show that Xilinx itself implements a small delay before an rx_cdr_lock is propagated.
  p_rx_cdr_lock_filter : process(rx_rec_clk, rst_int)
    variable rxcdrlock_cnt      : integer range 0 to c_rxcdrlock_max;
  begin
    if(rst_int = '1') then  
      rxcdrlock_cnt := 0;
      rx_cdr_lock_filtered <= '0';
    elsif rising_edge(rx_rec_clk) then
      if rx_cdr_lock = '0' then
        if rxcdrlock_cnt /= c_rxcdrlock_max then
           rxcdrlock_cnt := rxcdrlock_cnt + 1;
        else
           rx_cdr_lock_filtered <= '0';
        end if;
      else
        rxcdrlock_cnt := 0;
        rx_cdr_lock_filtered <= '1';
      end if;
    end if;
  end process;

  p_gen_rx_outputs : process(rx_rec_clk, rst_done_n)
  begin
    if(rst_done_n = '1') then
      rx_data_o    <= (others => '0');
      rx_k_o       <= (others => '0');
      rx_enc_err_o <= '0';
    elsif rising_edge(rx_rec_clk) then
      if(everything_ready = '1' and rx_synced = '1') then
        rx_data_o    <= rx_data_int(7 downto 0) & rx_data_int(15 downto 8);
        rx_k_o       <= rx_k_int(0) & rx_k_int(1);
        rx_enc_err_o <= rx_disp_err(0) or rx_disp_err(1) or rx_code_err(0) or rx_code_err(1);
      else
        rx_data_o    <= (others => '1');
        rx_k_o       <= (others => '1');
        rx_enc_err_o <= '1';
      end if;
    end if;
  end process;

  p_gen_tx_disparity : process(tx_out_clk, rst_done_n)
  begin
    if rising_edge(tx_out_clk) then
      if rst_done_n = '1' then
        cur_disp <= RD_MINUS;
      else
        cur_disp <= f_next_8b10b_disparity16(cur_disp, tx_k_i, tx_data_i);
      end if;
    end if;
  end process;

  tx_disparity_o <= to_std_logic(cur_disp);
end rtl;
