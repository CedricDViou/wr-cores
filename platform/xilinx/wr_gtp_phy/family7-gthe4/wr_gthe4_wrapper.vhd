library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity wr_gthe4_wrapper is
  generic(
    g_use_gclk_as_refclk : boolean := true
    );
  port (
    CPLLPD   : in  std_logic;
    CPLLLOCK : out std_logic;

    RXCDRLOCK      : out std_logic;
    RXRESETDONE    : out std_logic;
    GTRXRESET      : in  std_logic;
    RXPROGDIVRESET : in  std_logic;

    GTTXRESET      : in  std_logic;
    TXRESETDONE    : out std_logic;
    TXPROGDIVRESET : in  std_logic;

    RXPCSRESET : in std_logic;


    GTHTXN          : out std_logic;
    GTHTXP          : out std_logic;
    GTPOWERGOOD     : out std_logic;
    RXBYTEISALIGNED : out std_logic;
    RXCOMMADET      : out std_logic;
    RXCTRL0         : out std_logic_vector(15 downto 0);
    RXCTRL1              : out std_logic_vector(15 downto 0);
    RXCTRL2              : out std_logic_vector(7 downto 0);
    RXCTRL3              : out std_logic_vector(7 downto 0);
    RXDATA          : out std_logic_vector(127 downto 0);
    RXOUTCLK        : out std_logic;
    RXPHALIGNDONE   : out std_logic;
    RXPMARESETDONE  : out std_logic;
    RXSYNCDONE      : out std_logic;

    TXOUTCLK       : out std_logic;
    TXPHALIGNDONE  : out std_logic;
    TXPMARESETDONE : out std_logic;
    TXSYNCDONE     : out std_logic;
    RXDLYSRESET    : in  std_logic;
    DRPCLK         : in  std_logic;
    GTHRXN         : in  std_logic;
    GTHRXP         : in  std_logic;
    GTREFCLK0      : in  std_logic;
    GTGREFCLK : in std_logic;
    RXSLIDE        : in  std_logic;
    RXSYNCALLIN    : in  std_logic;
    RXUSERRDY      : in  std_logic;
    RXUSRCLK2      : in  std_logic;
    TXCTRL2        : in  std_logic_vector(7 downto 0);
    TXDATA         : in  std_logic_vector(127 downto 0);
    TXDLYSRESET    : in  std_logic;
    TXSYNCALLIN    : in  std_logic;
    TXUSERRDY      : in  std_logic;
    TXUSRCLK2      : in  std_logic
    );
end wr_gthe4_wrapper;

architecture rtl of wr_gthe4_wrapper is

  function f_choose_cpll_ref_clock return std_logic_vector is
  begin
    if g_use_gclk_as_refclk then
      return "111"; -- CPLL uses GTGREFCLK
    else
      return "001"; -- CPLL uses GTREFCLK0
    end if;
  end function;

begin


  U_The_GTHE4 : GTHE4_CHANNEL
    generic map (
      ACJTAG_DEBUG_MODE            => '0',
      ACJTAG_MODE                  => '0',
      ACJTAG_RESET                 => '0',
      ADAPT_CFG0                   => X"1000",
      ADAPT_CFG1                   => X"C800",
      ADAPT_CFG2                   => X"0000",
      ALIGN_COMMA_DOUBLE           => "FALSE",
      ALIGN_COMMA_ENABLE           => "1111111111",
      ALIGN_COMMA_WORD             => 2,
      ALIGN_MCOMMA_DET             => "TRUE",
      ALIGN_MCOMMA_VALUE           => "1010000011",
      ALIGN_PCOMMA_DET             => "TRUE",
      ALIGN_PCOMMA_VALUE           => "0101111100",
      A_RXOSCALRESET               => '0',
      A_RXPROGDIVRESET             => '0',
      A_RXTERMINATION              => '1',
      A_TXDIFFCTRL                 => B"01100",
      A_TXPROGDIVRESET             => '0',
      CAPBYPASS_FORCE              => '0',
      CBCC_DATA_SOURCE_SEL         => "DECODED",
      CDR_SWAP_MODE_EN             => '0',
      CFOK_PWRSVE_EN               => '1',
      CHAN_BOND_KEEP_ALIGN         => "FALSE",
      CHAN_BOND_MAX_SKEW           => 1,
      CHAN_BOND_SEQ_1_1            => "0000000000",
      CHAN_BOND_SEQ_1_2            => "0000000000",
      CHAN_BOND_SEQ_1_3            => "0000000000",
      CHAN_BOND_SEQ_1_4            => "0000000000",
      CHAN_BOND_SEQ_1_ENABLE       => "1111",
      CHAN_BOND_SEQ_2_1            => "0000000000",
      CHAN_BOND_SEQ_2_2            => "0000000000",
      CHAN_BOND_SEQ_2_3            => "0000000000",
      CHAN_BOND_SEQ_2_4            => "0000000000",
      CHAN_BOND_SEQ_2_ENABLE       => "1111",
      CHAN_BOND_SEQ_2_USE          => "FALSE",
      CHAN_BOND_SEQ_LEN            => 1,
      CH_HSPMUX                    => X"3C3C",
      CKCAL1_CFG_0                 => B"1100000011000000",
      CKCAL1_CFG_1                 => B"0101000011000000",
      CKCAL1_CFG_2                 => B"0000000000001010",
      CKCAL1_CFG_3                 => B"0000000000000000",
      CKCAL2_CFG_0                 => B"1100000011000000",
      CKCAL2_CFG_1                 => B"1000000011000000",
      CKCAL2_CFG_2                 => B"0000000000000000",
      CKCAL2_CFG_3                 => B"0000000000000000",
      CKCAL2_CFG_4                 => B"0000000000000000",
      CKCAL_RSVD0                  => X"0000",
      CKCAL_RSVD1                  => X"0400",
      CLK_CORRECT_USE              => "FALSE",
      CLK_COR_KEEP_IDLE            => "FALSE",
      CLK_COR_MAX_LAT              => 20,
      CLK_COR_MIN_LAT              => 18,
      CLK_COR_PRECEDENCE           => "TRUE",
      CLK_COR_REPEAT_WAIT          => 0,
      CLK_COR_SEQ_1_1              => "0100000000",
      CLK_COR_SEQ_1_2              => "0100000000",
      CLK_COR_SEQ_1_3              => "0100000000",
      CLK_COR_SEQ_1_4              => "0100000000",
      CLK_COR_SEQ_1_ENABLE         => "1111",
      CLK_COR_SEQ_2_1              => "0100000000",
      CLK_COR_SEQ_2_2              => "0100000000",
      CLK_COR_SEQ_2_3              => "0100000000",
      CLK_COR_SEQ_2_4              => "0100000000",
      CLK_COR_SEQ_2_ENABLE         => "1111",
      CLK_COR_SEQ_2_USE            => "FALSE",
      CLK_COR_SEQ_LEN              => 1,
      CPLL_CFG0                    => X"01FA",
      CPLL_CFG1                    => X"0023",
      CPLL_CFG2                    => X"0002",
      CPLL_CFG3                    => X"0000",
      CPLL_FBDIV                   => 5,
      CPLL_FBDIV_45                => 4,
      CPLL_INIT_CFG0               => X"02B2",
      CPLL_LOCK_CFG                => X"01E8",
      CPLL_REFCLK_DIV              => 1,
      CTLE3_OCAP_EXT_CTRL          => B"000",
      CTLE3_OCAP_EXT_EN            => '0',
      DDI_CTRL                     => B"00",
      DDI_REALIGN_WAIT             => 15,
      DEC_MCOMMA_DETECT            => "TRUE",
      DEC_PCOMMA_DETECT            => "TRUE",
      DEC_VALID_COMMA_ONLY         => "FALSE",
      DELAY_ELEC                   => '0',
      DMONITOR_CFG0                => B"00" & X"00",
      DMONITOR_CFG1                => X"00",
      ES_CLK_PHASE_SEL             => '0',
      ES_CONTROL                   => B"000000",
      ES_ERRDET_EN                 => "FALSE",
      ES_EYE_SCAN_EN               => "FALSE",
      ES_HORZ_OFFSET               => X"000",
      ES_PRESCALE                  => B"00000",
      ES_QUALIFIER0                => X"0000",
      ES_QUALIFIER1                => X"0000",
      ES_QUALIFIER2                => X"0000",
      ES_QUALIFIER3                => X"0000",
      ES_QUALIFIER4                => X"0000",
      ES_QUALIFIER5                => X"0000",
      ES_QUALIFIER6                => X"0000",
      ES_QUALIFIER7                => X"0000",
      ES_QUALIFIER8                => X"0000",
      ES_QUALIFIER9                => X"0000",
      ES_QUAL_MASK0                => X"0000",
      ES_QUAL_MASK1                => X"0000",
      ES_QUAL_MASK2                => X"0000",
      ES_QUAL_MASK3                => X"0000",
      ES_QUAL_MASK4                => X"0000",
      ES_QUAL_MASK5                => X"0000",
      ES_QUAL_MASK6                => X"0000",
      ES_QUAL_MASK7                => X"0000",
      ES_QUAL_MASK8                => X"0000",
      ES_QUAL_MASK9                => X"0000",
      ES_SDATA_MASK0               => X"0000",
      ES_SDATA_MASK1               => X"0000",
      ES_SDATA_MASK2               => X"0000",
      ES_SDATA_MASK3               => X"0000",
      ES_SDATA_MASK4               => X"0000",
      ES_SDATA_MASK5               => X"0000",
      ES_SDATA_MASK6               => X"0000",
      ES_SDATA_MASK7               => X"0000",
      ES_SDATA_MASK8               => X"0000",
      ES_SDATA_MASK9               => X"0000",
      EYE_SCAN_SWAP_EN             => '0',
      FTS_DESKEW_SEQ_ENABLE        => B"1111",
      FTS_LANE_DESKEW_CFG          => B"1111",
      FTS_LANE_DESKEW_EN           => "FALSE",
      GEARBOX_MODE                 => B"00000",
      ISCAN_CK_PH_SEL2             => '0',
      LOCAL_MASTER                 => '1',
      LPBK_BIAS_CTRL               => B"100",
      LPBK_EN_RCAL_B               => '0',
      LPBK_EXT_RCAL                => B"1000",
      LPBK_IND_CTRL0               => B"000",
      LPBK_IND_CTRL1               => B"000",
      LPBK_IND_CTRL2               => B"000",
      LPBK_RG_CTRL                 => B"1110",
      OOBDIVCTL                    => B"00",
      OOB_PWRUP                    => '0',
      PCI3_AUTO_REALIGN            => "OVR_1K_BLK",
      PCI3_PIPE_RX_ELECIDLE        => '0',
      PCI3_RX_ASYNC_EBUF_BYPASS    => B"00",
      PCI3_RX_ELECIDLE_EI2_ENABLE  => '0',
      PCI3_RX_ELECIDLE_H2L_COUNT   => B"000000",
      PCI3_RX_ELECIDLE_H2L_DISABLE => B"000",
      PCI3_RX_ELECIDLE_HI_COUNT    => B"000000",
      PCI3_RX_ELECIDLE_LP4_DISABLE => '0',
      PCI3_RX_FIFO_DISABLE         => '0',
      PCIE3_CLK_COR_EMPTY_THRSH    => B"00000",
      PCIE3_CLK_COR_FULL_THRSH     => B"010000",
      PCIE3_CLK_COR_MAX_LAT        => B"00100",
      PCIE3_CLK_COR_MIN_LAT        => B"00000",
      PCIE3_CLK_COR_THRSH_TIMER    => B"001000",
      PCIE_BUFG_DIV_CTRL           => X"1000",
      PCIE_PLL_SEL_MODE_GEN12      => B"00",
      PCIE_PLL_SEL_MODE_GEN3       => B"11",
      PCIE_PLL_SEL_MODE_GEN4       => B"10",
      PCIE_RXPCS_CFG_GEN3          => X"0AA5",
      PCIE_RXPMA_CFG               => X"280A",
      PCIE_TXPCS_CFG_GEN3          => X"2CA4",
      PCIE_TXPMA_CFG               => X"280A",
      PCS_PCIE_EN                  => "FALSE",
      PCS_RSVD0                    => B"0000000000000000",
      PD_TRANS_TIME_FROM_P2        => X"03C",
      PD_TRANS_TIME_NONE_P2        => X"19",
      PD_TRANS_TIME_TO_P2          => X"64",
      PREIQ_FREQ_BST               => 0,
      PROCESS_PAR                  => B"010",
      RATE_SW_USE_DRP              => '1',
      RCLK_SIPO_DLY_ENB            => '0',
      RCLK_SIPO_INV_EN             => '0',
      RESET_POWERSAVE_DISABLE      => '0',
      RTX_BUF_CML_CTRL             => B"010",
      RTX_BUF_TERM_CTRL            => B"00",
      RXBUFRESET_TIME              => B"00011",
      RXBUF_ADDR_MODE              => "FAST",
      RXBUF_EIDLE_HI_CNT           => B"1000",
      RXBUF_EIDLE_LO_CNT           => B"0000",
      RXBUF_EN                     => "FALSE",
      RXBUF_RESET_ON_CB_CHANGE     => "TRUE",
      RXBUF_RESET_ON_COMMAALIGN    => "FALSE",
      RXBUF_RESET_ON_EIDLE         => "FALSE",
      RXBUF_RESET_ON_RATE_CHANGE   => "TRUE",
      RXBUF_THRESH_OVFLW           => 0,
      RXBUF_THRESH_OVRD            => "FALSE",
      RXBUF_THRESH_UNDFLW          => 4,
      RXCDRFREQRESET_TIME          => B"00001",
      RXCDRPHRESET_TIME            => B"00001",
      RXCDR_CFG0                   => X"0003",
      RXCDR_CFG0_GEN3              => X"0003",
      RXCDR_CFG1                   => X"0000",
      RXCDR_CFG1_GEN3              => X"0000",
      RXCDR_CFG2                   => X"0249",
      RXCDR_CFG2_GEN2              => B"10" & X"49",
      RXCDR_CFG2_GEN3              => X"0249",
      RXCDR_CFG2_GEN4              => X"0164",
      RXCDR_CFG3                   => X"0012",
      RXCDR_CFG3_GEN2              => B"01" & X"2",
      RXCDR_CFG3_GEN3              => X"0012",
      RXCDR_CFG3_GEN4              => X"0012",
      RXCDR_CFG4                   => X"5CF6",
      RXCDR_CFG4_GEN3              => X"5CF6",
      RXCDR_CFG5                   => X"B46B",
      RXCDR_CFG5_GEN3              => X"146B",
      RXCDR_FR_RESET_ON_EIDLE      => '0',
      RXCDR_HOLD_DURING_EIDLE      => '0',
      RXCDR_LOCK_CFG0              => X"2201",
      RXCDR_LOCK_CFG1              => X"9FFF",
      RXCDR_LOCK_CFG2              => X"77C3",
      RXCDR_LOCK_CFG3              => X"0001",
      RXCDR_LOCK_CFG4              => X"0000",
      RXCDR_PH_RESET_ON_EIDLE      => '0',
      RXCFOK_CFG0                  => X"0000",
      RXCFOK_CFG1                  => X"8015",
      RXCFOK_CFG2                  => X"02AE",
      RXCKCAL1_IQ_LOOP_RST_CFG     => X"0004",
      RXCKCAL1_I_LOOP_RST_CFG      => X"0004",
      RXCKCAL1_Q_LOOP_RST_CFG      => X"0004",
      RXCKCAL2_DX_LOOP_RST_CFG     => X"0004",
      RXCKCAL2_D_LOOP_RST_CFG      => X"0004",
      RXCKCAL2_S_LOOP_RST_CFG      => X"0004",
      RXCKCAL2_X_LOOP_RST_CFG      => X"0004",
      RXDFELPMRESET_TIME           => B"0001111",
      RXDFELPM_KL_CFG0             => X"0000",
      RXDFELPM_KL_CFG1             => X"A0E2",
      RXDFELPM_KL_CFG2             => X"0100",
      RXDFE_CFG0                   => X"0A00",
      RXDFE_CFG1                   => X"0000",
      RXDFE_GC_CFG0                => X"0000",
      RXDFE_GC_CFG1                => X"8000",
      RXDFE_GC_CFG2                => X"FFE0",
      RXDFE_H2_CFG0                => X"0000",
      RXDFE_H2_CFG1                => X"0002",
      RXDFE_H3_CFG0                => X"0000",
      RXDFE_H3_CFG1                => X"8002",
      RXDFE_H4_CFG0                => X"0000",
      RXDFE_H4_CFG1                => X"8002",
      RXDFE_H5_CFG0                => X"0000",
      RXDFE_H5_CFG1                => X"8002",
      RXDFE_H6_CFG0                => X"0000",
      RXDFE_H6_CFG1                => X"8002",
      RXDFE_H7_CFG0                => X"0000",
      RXDFE_H7_CFG1                => X"8002",
      RXDFE_H8_CFG0                => X"0000",
      RXDFE_H8_CFG1                => X"8002",
      RXDFE_H9_CFG0                => X"0000",
      RXDFE_H9_CFG1                => X"8002",
      RXDFE_HA_CFG0                => X"0000",
      RXDFE_HA_CFG1                => X"8002",
      RXDFE_HB_CFG0                => X"0000",
      RXDFE_HB_CFG1                => X"8002",
      RXDFE_HC_CFG0                => X"0000",
      RXDFE_HC_CFG1                => X"8002",
      RXDFE_HD_CFG0                => X"0000",
      RXDFE_HD_CFG1                => X"8002",
      RXDFE_HE_CFG0                => X"0000",
      RXDFE_HE_CFG1                => X"8002",
      RXDFE_HF_CFG0                => X"0000",
      RXDFE_HF_CFG1                => X"8002",
      RXDFE_KH_CFG0                => X"0000",
      RXDFE_KH_CFG1                => X"8000",
      RXDFE_KH_CFG2                => X"2613",
      RXDFE_KH_CFG3                => X"411C",
      RXDFE_OS_CFG0                => X"0000",
      RXDFE_OS_CFG1                => X"8002",
      RXDFE_PWR_SAVING             => '1',
      RXDFE_UT_CFG0                => X"0000",
      RXDFE_UT_CFG1                => X"0003",
      RXDFE_UT_CFG2                => X"0000",
      RXDFE_VP_CFG0                => X"0000",
      RXDFE_VP_CFG1                => X"8033",
      RXDLY_CFG                    => X"0010",
      RXDLY_LCFG                   => X"0030",
      RXELECIDLE_CFG               => "SIGCFG_4",
      RXGBOX_FIFO_INIT_RD_ADDR     => 4,
      RXGEARBOX_EN                 => "FALSE",
      RXISCANRESET_TIME            => B"00001",
      RXLPM_CFG                    => X"0000",
      RXLPM_GC_CFG                 => X"8000",
      RXLPM_KH_CFG0                => X"0000",
      RXLPM_KH_CFG1                => X"0002",
      RXLPM_OS_CFG0                => X"0000",
      RXLPM_OS_CFG1                => X"8002",
      RXOOB_CFG                    => B"000000110",
      RXOOB_CLK_CFG                => "PMA",
      RXOSCALRESET_TIME            => B"00011",
      RXOUT_DIV                    => 4,
      RXPCSRESET_TIME              => B"00011",
      RXPHBEACON_CFG               => X"0000",
      RXPHDLY_CFG                  => X"2070",
      RXPHSAMP_CFG                 => X"2100",
      RXPHSLIP_CFG                 => X"9933",
      RXPH_MONITOR_SEL             => B"00000",
      RXPI_AUTO_BW_SEL_BYPASS      => '0',
      RXPI_CFG0                    => X"1300",
      RXPI_CFG1                    => B"0000000011111101",
      RXPI_LPM                     => '0',
      RXPI_SEL_LC                  => B"00",
      RXPI_STARTCODE               => B"00",
      RXPI_VREFSEL                 => '0',
      RXPMACLK_SEL                 => "DATA",
      RXPMARESET_TIME              => B"00011",
      RXPRBS_ERR_LOOPBACK          => '0',
      RXPRBS_LINKACQ_CNT           => 15,
      RXREFCLKDIV2_SEL             => '0',
      RXSLIDE_AUTO_WAIT            => 7,
      RXSLIDE_MODE                 => "PCS",
      RXSYNC_MULTILANE             => '0',
      RXSYNC_OVRD                  => '0',
      RXSYNC_SKIP_DA               => '0',
      RX_AFE_CM_EN                 => '0',
      RX_BIAS_CFG0                 => X"1554",
      RX_BUFFER_CFG                => B"000000",
      RX_CAPFF_SARC_ENB            => '0',
      RX_CLK25_DIV                 => 5,
      RX_CLKMUX_EN                 => '1',
      RX_CLK_SLIP_OVRD             => B"00000",
      RX_CM_BUF_CFG                => B"1010",
      RX_CM_BUF_PD                 => '0',
      RX_CM_SEL                    => 3,
      RX_CM_TRIM                   => 10,
      RX_CTLE3_LPF                 => B"11111111",
      RX_DATA_WIDTH                => 20,
      RX_DDI_SEL                   => B"000000",
      RX_DEFER_RESET_BUF_EN        => "TRUE",
      RX_DEGEN_CTRL                => B"011",
      RX_DFELPM_CFG0               => 6,
      RX_DFELPM_CFG1               => '1',
      RX_DFELPM_KLKH_AGC_STUP_EN   => '1',
      RX_DFE_AGC_CFG0              => B"10",
      RX_DFE_AGC_CFG1              => 4,
      RX_DFE_KL_LPM_KH_CFG0        => 1,
      RX_DFE_KL_LPM_KH_CFG1        => 4,
      RX_DFE_KL_LPM_KL_CFG0        => B"01",
      RX_DFE_KL_LPM_KL_CFG1        => 4,
      RX_DFE_LPM_HOLD_DURING_EIDLE => '0',
      RX_DISPERR_SEQ_MATCH         => "TRUE",
      RX_DIV2_MODE_B               => '0',
      RX_DIVRESET_TIME             => B"00001",
      RX_EN_CTLE_RCAL_B            => '0',
      RX_EN_HI_LR                  => '1',
      RX_EXT_RL_CTRL               => B"000000000",
      RX_EYESCAN_VS_CODE           => B"0000000",
      RX_EYESCAN_VS_NEG_DIR        => '0',
      RX_EYESCAN_VS_RANGE          => B"00",
      RX_EYESCAN_VS_UT_SIGN        => '0',
      RX_FABINT_USRCLK_FLOP        => '0',
      RX_INT_DATAWIDTH             => 0,
      RX_PMA_POWER_SAVE            => '0',
      RX_PMA_RSV0                  => X"0000",
      RX_PROGDIV_CFG               => 0.000000,
      RX_PROGDIV_RATE              => X"0001",
      RX_RESLOAD_CTRL              => B"0000",
      RX_RESLOAD_OVRD              => '0',
      RX_SAMPLE_PERIOD             => B"111",
      RX_SIG_VALID_DLY             => 11,
      RX_SUM_DFETAPREP_EN          => '0',
      RX_SUM_IREF_TUNE             => B"0100",
      RX_SUM_RESLOAD_CTRL          => B"0011",
      RX_SUM_VCMTUNE               => B"0110",
      RX_SUM_VCM_OVWR              => '0',
      RX_SUM_VREF_TUNE             => B"100",
      RX_TUNE_AFE_OS               => B"00",
      RX_VREG_CTRL                 => B"101",
      RX_VREG_PDB                  => '1',
      RX_WIDEMODE_CDR              => B"00",
      RX_WIDEMODE_CDR_GEN3         => B"00",
      RX_WIDEMODE_CDR_GEN4         => B"01",
      RX_XCLK_SEL                  => "RXUSR",
      RX_XMODE_SEL                 => '0',
      SAMPLE_CLK_PHASE             => '0',
      SAS_12G_MODE                 => '0',
      SATA_BURST_SEQ_LEN           => B"1111",
      SATA_BURST_VAL               => B"100",
      SATA_CPLL_CFG                => "VCO_3000MHZ",
      SATA_EIDLE_VAL               => B"100",
      SHOW_REALIGN_COMMA           => "TRUE",
      SIM_DEVICE                   => "ULTRASCALE_PLUS",
      SIM_MODE                     => "FAST",
      SIM_RECEIVER_DETECT_PASS     => "TRUE",
      SIM_RESET_SPEEDUP            => "TRUE",
      SIM_TX_EIDLE_DRIVE_LEVEL     => "Z",
      SRSTMODE                     => '0',
      TAPDLY_SET_TX                => B"00",
      TEMPERATURE_PAR              => B"0010",
      TERM_RCAL_CFG                => B"100001000010001",
      TERM_RCAL_OVRD               => B"000",
      TRANS_TIME_RATE              => X"0E",
      TST_RSV0                     => X"00",
      TST_RSV1                     => X"00",
      TXBUF_EN                     => "FALSE",
      TXBUF_RESET_ON_RATE_CHANGE   => "TRUE",
      TXDLY_CFG                    => X"8010",
      TXDLY_LCFG                   => X"0030",
      TXDRVBIAS_N                  => B"1010",
      TXFIFO_ADDR_CFG              => "LOW",
      TXGBOX_FIFO_INIT_RD_ADDR     => 4,
      TXGEARBOX_EN                 => "FALSE",
      TXOUT_DIV                    => 4,
      TXPCSRESET_TIME              => B"00011",
      TXPHDLY_CFG0                 => X"6070",
      TXPHDLY_CFG1                 => X"000F",
      TXPH_CFG                     => X"0723",
      TXPH_CFG2                    => X"0000",
      TXPH_MONITOR_SEL             => B"00000",
      TXPI_CFG                     => X"03DF",
      TXPI_CFG0                    => B"00",
      TXPI_CFG1                    => B"00",
      TXPI_CFG2                    => B"00",
      TXPI_CFG3                    => '1',
      TXPI_CFG4                    => '1',
      TXPI_CFG5                    => B"000",
      TXPI_GRAY_SEL                => '0',
      TXPI_INVSTROBE_SEL           => '0',
      TXPI_LPM                     => '0',
      TXPI_PPM                     => '0',
      TXPI_PPMCLK_SEL              => "TXUSRCLK2",
      TXPI_PPM_CFG                 => B"00000000",
      TXPI_SYNFREQ_PPM             => B"001",
      TXPI_VREFSEL                 => '0',
      TXPMARESET_TIME              => B"00011",
      TXREFCLKDIV2_SEL             => '0',
      TXSYNC_MULTILANE             => '0',
      TXSYNC_OVRD                  => '0',
      TXSYNC_SKIP_DA               => '0',
      TX_CLK25_DIV                 => 5,
      TX_CLKMUX_EN                 => '1',
      TX_DATA_WIDTH                => 20,
      TX_DCC_LOOP_RST_CFG          => X"0004",
      TX_DEEMPH0                   => B"000000",
      TX_DEEMPH1                   => B"000000",
      TX_DEEMPH2                   => B"000000",
      TX_DEEMPH3                   => B"000000",
      TX_DIVRESET_TIME             => B"00001",
      TX_DRIVE_MODE                => "DIRECT",
      TX_DRVMUX_CTRL               => 2,
      TX_EIDLE_ASSERT_DELAY        => B"100",
      TX_EIDLE_DEASSERT_DELAY      => B"011",
      TX_FABINT_USRCLK_FLOP        => '0',
      TX_FIFO_BYP_EN               => '1',
      TX_IDLE_DATA_ZERO            => '0',
      TX_INT_DATAWIDTH             => 0,
      TX_LOOPBACK_DRIVE_HIZ        => "FALSE",
      TX_MAINCURSOR_SEL            => '0',
      TX_MARGIN_FULL_0             => B"1011111",
      TX_MARGIN_FULL_1             => B"1011110",
      TX_MARGIN_FULL_2             => B"1011100",
      TX_MARGIN_FULL_3             => B"1011010",
      TX_MARGIN_FULL_4             => B"1011000",
      TX_MARGIN_LOW_0              => B"1000110",
      TX_MARGIN_LOW_1              => B"1000101",
      TX_MARGIN_LOW_2              => B"1000011",
      TX_MARGIN_LOW_3              => B"1000010",
      TX_MARGIN_LOW_4              => B"1000000",
      TX_PHICAL_CFG0               => X"0000",
      TX_PHICAL_CFG1               => X"7E00",
      TX_PHICAL_CFG2               => X"0200",
      TX_PI_BIASSET                => 0,
      TX_PI_IBIAS_MID              => B"00",
      TX_PMADATA_OPT               => '0',
      TX_PMA_POWER_SAVE            => '0',
      TX_PMA_RSV0                  => X"0008",
      TX_PREDRV_CTRL               => 2,
      TX_PROGCLK_SEL               => "PREPI",
      TX_PROGDIV_CFG               => 0.000000,
      TX_PROGDIV_RATE              => X"0001",
      TX_QPI_STATUS_EN             => '0',
      TX_RXDETECT_CFG              => B"00" & X"032",
      TX_RXDETECT_REF              => 4,
      TX_SAMPLE_PERIOD             => B"111",
      TX_SARC_LPBK_ENB             => '0',
      TX_SW_MEAS                   => B"00",
      TX_VREG_CTRL                 => B"000",
      TX_VREG_PDB                  => '0',
      TX_VREG_VREFSEL              => B"00",
      TX_XCLK_SEL                  => "TXUSR",
      USB_BOTH_BURST_IDLE          => '0',
      USB_BURSTMAX_U3WAKE          => B"1111111",
      USB_BURSTMIN_U3WAKE          => B"1100011",
      USB_CLK_COR_EQ_EN            => '0',
      USB_EXT_CNTL                 => '1',
      USB_IDLEMAX_POLLING          => B"1010111011",
      USB_IDLEMIN_POLLING          => B"0100101011",
      USB_LFPSPING_BURST           => B"000000101",
      USB_LFPSPOLLING_BURST        => B"000110001",
      USB_LFPSPOLLING_IDLE_MS      => B"000000100",
      USB_LFPSU1EXIT_BURST         => B"000011101",
      USB_LFPSU2LPEXIT_BURST_MS    => B"001100011",
      USB_LFPSU3WAKE_BURST_MS      => B"111110011",
      USB_LFPS_TPERIOD             => B"0011",
      USB_LFPS_TPERIOD_ACCURATE    => '1',
      USB_MODE                     => '0',
      USB_PCIE_ERR_REP_DIS         => '0',
      USB_PING_SATA_MAX_INIT       => 21,
      USB_PING_SATA_MIN_INIT       => 12,
      USB_POLL_SATA_MAX_BURST      => 8,
      USB_POLL_SATA_MIN_BURST      => 4,
      USB_RAW_ELEC                 => '0',
      USB_RXIDLE_P0_CTRL           => '1',
      USB_TXIDLE_TUNE_ENABLE       => '1',
      USB_U1_SATA_MAX_WAKE         => 7,
      USB_U1_SATA_MIN_WAKE         => 4,
      USB_U2_SAS_MAX_COM           => 64,
      USB_U2_SAS_MIN_COM           => 36,
      USE_PCS_CLK_PHASE_SEL        => '0',
      Y_ALL_MODE                   => '0')
    port map (

      BUFGTCE      => open,
      BUFGTCEMASK  => open,
      BUFGTDIV     => open,
      BUFGTRESET   => open,
      BUFGTRSTMASK => open,

      CDRSTEPDIR                => '0',
      CDRSTEPSQ                 => '0',
      CDRSTEPSX                 => '0',
      CFGRESET                  => '0',
      CLKRSVD0                  => '0',
      CLKRSVD1                  => '0',
      CPLLFBCLKLOST             => open,
      CPLLFREQLOCK              => '0',
      CPLLLOCK                  => CPLLLOCK,
      CPLLLOCKDETCLK            => '0',
      CPLLLOCKEN                => '1',
      CPLLPD                    => CPLLPD,
      CPLLREFCLKLOST            => open,
      CPLLREFCLKSEL(2 downto 0) => f_choose_cpll_ref_clock,
      CPLLRESET                 => '0',


      DMONFIFORESET            => '0',
      DMONITORCLK              => '0',
      DMONITOROUT => open,
      DMONITOROUTCLK           => open,


      DRPADDR => "0000000000",
      DRPCLK  => DRPCLK,
      DRPDI   => x"0000",
      DRPDO   => open,
      DRPEN   => '0',
      DRPRDY  => open,
      DRPRST  => '0',
      DRPWE   => '0',


      EYESCANDATAERROR => open,
      EYESCANRESET     => '0',
      EYESCANTRIGGER   => '0',
      FREQOS           => '0',
      GTGREFCLK        => GTGREFCLK,
      GTHRXN           => GTHRXN,
      GTHRXP           => GTHRXP,
      GTHTXN           => GTHTXN,
      GTHTXP           => GTHTXP,

      GTNORTHREFCLK0  => '0',
      GTNORTHREFCLK1  => '0',
      GTPOWERGOOD     => GTPOWERGOOD,
      GTREFCLK0       => GTREFCLK0,
      GTREFCLK1       => '0',
      GTREFCLKMONITOR => open,
      GTRSVD          => x"0000",

      GTRXRESET      => GTRXRESET,
      GTRXRESETSEL   => '0',
      GTSOUTHREFCLK0 => '0',
      GTSOUTHREFCLK1 => '0',
      GTTXRESET      => GTTXRESET,
      GTTXRESETSEL   => '0',

      INCPCTRL             => '0',
      LOOPBACK             => "000",
      PCIEEQRXEQADAPTDONE  => '0',
      PCIERATEGEN3         => open,
      PCIERATEIDLE         => open,
      PCIERATEQPLLPD       => open,
      PCIERATEQPLLRESET    => open,
      PCIERSTIDLE          => '0',
      PCIERSTTXSYNCSTART   => '0',
      PCIESYNCTXSYNCDONE   => open,
      PCIEUSERGEN3RDY      => open,
      PCIEUSERPHYSTATUSRST => open,
      PCIEUSERRATEDONE     => '0',
      PCIEUSERRATESTART    => open,


      PCSRSVDIN               => x"0000",
      PCSRSVDOUT              => open,
      PHYSTATUS               => open,
      PINRSRVDAS => open,
      POWERPRESENT            => open,

      QPLL0CLK      => '0',
      QPLL0REFCLK   => '0',
      QPLL0FREQLOCK => '0',
      QPLL1CLK      => '0',
      QPLL1REFCLK   => '0',
      QPLL1FREQLOCK => '0',

      RESETEXCEPTION => open,
      RESETOVRD      => '0',

      RX8B10BEN       => '1',
      RXAFECFOKEN     => '1',
      RXBUFRESET      => '0',
      RXBUFSTATUS     => open,
      RXBYTEISALIGNED => RXBYTEISALIGNED,
      RXBYTEREALIGN   => open,
      RXCDRFREQRESET  => '0',
      RXCDRHOLD       => '0',
      RXCDRLOCK       => RXCDRLOCK,
      RXCDROVRDEN     => '0',
      RXCDRPHDONE     => open,
      RXCDRRESET      => '0',
--      RXCDRRESETRSV   => '0',
      RXCHANBONDSEQ   => open,
      RXCHANISALIGNED => open,
      RXCHANREALIGN   => open,

      RXCHBONDEN     => '0',
      RXCHBONDI      => "00000",
      RXCHBONDLEVEL  => "000",
      RXCHBONDMASTER => '0',
      RXCHBONDO      => open,
      RXCHBONDSLAVE  => '0',

      RXCKCALDONE              => open,
      RXCKCALRESET             => '0',
      RXCKCALSTART(6 downto 0) => "0000000",

      RXCLKCORCNT  => open,
      RXCOMINITDET => open,
      RXCOMMADETEN => '1',
      RXCOMMADET   => RXCOMMADET,
      RXCOMSASDET  => open,
      RXCOMWAKEDET => open,

      RXCTRL0          => RXCTRL0,
      RXCTRL1          => RXCTRL1,
      RXCTRL2          => RXCTRL2,
      RXCTRL3          => RXCTRL3,
      RXDATAEXTENDRSVD => open,
      RXDATA           => RXDATA,
      RXDATAVALID      => open,

      RXDFEAGCCTRL   => "01",
      RXDFEAGCHOLD   => '0',
      RXDFEAGCOVRDEN => '0',

      RXDFECFOKFCNUM(3 downto 0) => "1101",
      RXDFECFOKFEN               => '0',
      RXDFECFOKFPULSE            => '0',
      RXDFECFOKHOLD              => '0',
      RXDFECFOKOVREN             => '0',
      RXDFEKHHOLD                => '0',
      RXDFEKHOVRDEN              => '0',


      RXDFELFHOLD   => '0',
      RXDFELFOVRDEN => '0',
      RXDFELPMRESET => '0',

      RXDFETAP10HOLD   => '0',
      RXDFETAP10OVRDEN => '0',
      RXDFETAP11HOLD   => '0',
      RXDFETAP11OVRDEN => '0',
      RXDFETAP12HOLD   => '0',
      RXDFETAP12OVRDEN => '0',
      RXDFETAP13HOLD   => '0',
      RXDFETAP13OVRDEN => '0',
      RXDFETAP14HOLD   => '0',
      RXDFETAP14OVRDEN => '0',
      RXDFETAP15HOLD   => '0',
      RXDFETAP15OVRDEN => '0',
      RXDFETAP2HOLD    => '0',
      RXDFETAP2OVRDEN  => '0',
      RXDFETAP3HOLD    => '0',
      RXDFETAP3OVRDEN  => '0',
      RXDFETAP4HOLD    => '0',
      RXDFETAP4OVRDEN  => '0',
      RXDFETAP5HOLD    => '0',
      RXDFETAP5OVRDEN  => '0',
      RXDFETAP6HOLD    => '0',
      RXDFETAP6OVRDEN  => '0',
      RXDFETAP7HOLD    => '0',
      RXDFETAP7OVRDEN  => '0',
      RXDFETAP8HOLD    => '0',
      RXDFETAP8OVRDEN  => '0',
      RXDFETAP9HOLD    => '0',
      RXDFETAP9OVRDEN  => '0',
      RXDFEUTHOLD      => '0',
      RXDFEUTOVRDEN    => '0',
      RXDFEVPHOLD      => '0',
      RXDFEVPOVRDEN    => '0',
--      RXDFEVSEN        => '0',
      RXDFEXYDEN       => '1',
      RXDLYBYPASS      => '0',
      RXDLYEN          => '0',
      RXDLYOVRDEN      => '0',
      RXDLYSRESETDONE  => open,
      RXDLYSRESET      => RXDLYSRESET,
      RXELECIDLEMODE   => "11",
      RXELECIDLE       => open,
      RXEQTRAINING     => '0',
      RXGEARBOXSLIP    => '0',
      RXHEADER         => open,
      RXHEADERVALID    => open,
      RXLATCLK         => '0',

      RXLPMEN         => '1',
      RXLPMGCHOLD     => '0',
      RXLPMGCOVRDEN   => '0',
      RXLPMHFHOLD     => '0',
      RXLPMHFOVRDEN   => '0',
      RXLPMLFHOLD     => '0',
      RXLPMLFKLOVRDEN => '0',
      RXLPMOSHOLD     => '0',
      RXLPMOSOVRDEN   => '0',

      RXMCOMMAALIGNEN => '0',
      RXMONITOROUT    => open,
      RXMONITORSEL    => "00",
      RXOOBRESET      => '0',
      RXOSCALRESET    => '0',


      RXOSHOLD             => '0',
      RXOSINTDONE          => open,
      RXOSINTSTARTED       => open,
      RXOSINTSTROBEDONE    => open,
      RXOSINTSTROBESTARTED => open,

      RXOSOVRDEN => '0',

      RXOUTCLKFABRIC    => open,
      RXOUTCLKPCS       => open,
      RXOUTCLK          => RXOUTCLK,
      RXOUTCLKSEL       => "010",
      RXPCOMMAALIGNEN   => '0',
      RXPCSRESET           => RXPCSRESET,
      RXPD              => "00",
      RXPHALIGN         => '0',
      RXPHALIGNDONE     => RXPHALIGNDONE,
      RXPHALIGNEN       => '0',
      RXPHALIGNERR      => open,
      RXPHDLYPD         => '0',
      RXPHDLYRESET      => '0',
      RXPHOVRDEN        => '0',
      RXPLLCLKSEL       => "00",
      RXPMARESET        => '0',
      RXPMARESETDONE    => RXPMARESETDONE,
      RXPOLARITY        => '0',
      RXPRBSCNTRESET    => '0',
      RXPRBSERR         => open,
      RXPRBSLOCKED      => open,
      RXPRBSSEL         => "0000",
      RXPRGDIVRESETDONE => open,
      RXPROGDIVRESET    => RXPROGDIVRESET,
      RXQPIEN           => '0',
      RXQPISENN         => open,
      RXQPISENP         => open,
      RXRATE            => "000",
      RXRATEDONE        => open,
      RXRATEMODE        => '0',
      RXRECCLKOUT       => open,
      RXRESETDONE       => RXRESETDONE,
      RXSLIDERDY        => open,
      RXSLIDE           => RXSLIDE,
      RXSLIPDONE        => open,
      RXSLIPOUTCLK      => '0',
      RXSLIPOUTCLKRDY   => open,
      RXSLIPPMA         => '0',
      RXSLIPPMARDY      => open,
      RXSTARTOFSEQ      => open,
      RXSTATUS          => open,
      RXSYNCALLIN       => RXSYNCALLIN,
      RXSYNCDONE        => RXSYNCDONE,
      RXSYNCIN          => '0',
      RXSYNCMODE        => '1',
      RXSYNCOUT         => open,
      RXSYSCLKSEL       => "00",
      RXTERMINATION     => '0',
      RXUSERRDY         => RXUSERRDY,
      RXUSRCLK2         => RXUSRCLK2,
      RXUSRCLK          => RXUSRCLK2,
      RXVALID           => open,
      SIGVALIDCLK       => '0',
      TSTIN             => x"00000",
      TX8B10BBYPASS     => x"00",
      TX8B10BEN         => '1',
      TXBUFSTATUS       => open,

      TXCOMFINISH      => open,
      TXCOMINIT        => '0',
      TXCOMSAS         => '0',
      TXCOMWAKE        => '0',
      TXCTRL0          => x"0000",
      TXCTRL1          => x"0000",
      TXCTRL2          => TXCTRL2,
      TXDATAEXTENDRSVD => "00000000",
      TXDATA           => TXDATA,

      TXDCCDONE       => open,
      TXDCCFORCESTART => '0',
      TXDCCRESET      => '0',
      TXDEEMPH        => "00",
      TXDETECTRX      => '0',
      TXDIFFCTRL      => "01100",

      TXDLYBYPASS     => '0',
      TXDLYEN         => '0',
      TXDLYHOLD       => '0',
      TXDLYOVRDEN     => '0',
      TXDLYSRESETDONE => open,
      TXDLYSRESET     => TXDLYSRESET,
      TXDLYUPDOWN     => '0',

      TXELECIDLE     => '0',
      TXHEADER       => "000000",
      TXINHIBIT      => '0',
      TXLATCLK       => '0',
      TXLFPSTRESET   => '0',
      TXLFPSU2LPEXIT => '0',
      TXLFPSU3WAKE   => '0',
      TXMAINCURSOR   => "1000000",
      TXMARGIN       => "000",
      TXMUXDCDEXHOLD => '0',
      TXMUXDCDORWREN => '0',
      TXONESZEROS    => '0',

      TXOUTCLKFABRIC    => open,
      TXOUTCLKPCS       => open,
      TXOUTCLKSEL       => "011",
      TXOUTCLK          => TXOUTCLK,
      TXPCSRESET        => '0',
      TXPD              => "00",
      TXPDELECIDLEMODE  => '0',
      TXPHALIGN         => '0',
      TXPHALIGNDONE     => TXPHALIGNDONE,
      TXPHALIGNEN       => '0',
      TXPHDLYPD         => '0',
      TXPHDLYRESET      => '0',
      TXPHDLYTSTCLK     => '0',
      TXPHINIT          => '0',
      TXPHINITDONE      => open,
      TXPHOVRDEN        => '0',
      TXPIPPMEN         => '0',
      TXPIPPMOVRDEN     => '0',
      TXPIPPMPD         => '0',
      TXPIPPMSEL        => '0',
      TXPIPPMSTEPSIZE   => "00000",
      TXPISOPD          => '0',
      TXPLLCLKSEL       => "00",
      TXPMARESET        => '0',
      TXPMARESETDONE    => TXPMARESETDONE,
      TXPOLARITY        => '0',
      TXPOSTCURSOR      => "00000",
      TXPRBSFORCEERR    => '0',
      TXPRBSSEL         => "0000",
      TXPRECURSOR       => "00000",
      TXPRGDIVRESETDONE => open,
      TXPROGDIVRESET    => TXPROGDIVRESET,
      TXQPIBIASEN       => '0',

      TXQPISENN    => open,
      TXQPISENP    => open,
      TXQPIWEAKPUP => '0',
      TXRATE       => "000",
      TXRATEDONE   => open,
      TXRATEMODE   => '0',
      TXRESETDONE  => TXRESETDONE,
      TXSEQUENCE   => "0000000",
      TXSWING      => '0',
      TXSYNCALLIN  => TXSYNCALLIN,
      TXSYNCDONE   => TXSYNCDONE,
      TXSYNCIN     => '0',
      TXSYNCMODE   => '1',
      TXSYNCOUT    => open,
      TXSYSCLKSEL  => "00",
      TXUSERRDY    => TXUSERRDY,
      TXUSRCLK2    => TXUSRCLK2,
      TXUSRCLK     => TXUSRCLK2);

end rtl;
