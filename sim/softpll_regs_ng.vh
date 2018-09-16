`define ADDR_SPLL_CSR                  8'h0
`define SPLL_CSR_UNUSED0_OFFSET 8
`define SPLL_CSR_UNUSED0 32'h00003f00
`define SPLL_CSR_N_REF_OFFSET 16
`define SPLL_CSR_N_REF 32'h003f0000
`define SPLL_CSR_N_OUT_OFFSET 24
`define SPLL_CSR_N_OUT 32'h07000000
`define SPLL_CSR_DBG_SUPPORTED_OFFSET 27
`define SPLL_CSR_DBG_SUPPORTED 32'h08000000
`define ADDR_SPLL_ECCR                 8'h4
`define SPLL_ECCR_EXT_EN_OFFSET 0
`define SPLL_ECCR_EXT_EN 32'h00000001
`define SPLL_ECCR_EXT_SUPPORTED_OFFSET 1
`define SPLL_ECCR_EXT_SUPPORTED 32'h00000002
`define SPLL_ECCR_EXT_REF_LOCKED_OFFSET 2
`define SPLL_ECCR_EXT_REF_LOCKED 32'h00000004
`define SPLL_ECCR_EXT_REF_STOPPED_OFFSET 3
`define SPLL_ECCR_EXT_REF_STOPPED 32'h00000008
`define SPLL_ECCR_EXT_REF_PLLRST_OFFSET 31
`define SPLL_ECCR_EXT_REF_PLLRST 32'h80000000
`define ADDR_SPLL_AL_CR                8'h8
`define SPLL_AL_CR_VALID_OFFSET 0
`define SPLL_AL_CR_VALID 32'h000001ff
`define SPLL_AL_CR_REQUIRED_OFFSET 9
`define SPLL_AL_CR_REQUIRED 32'h0003fe00
`define ADDR_SPLL_AL_CREF              8'hc
`define ADDR_SPLL_AL_CIN               8'h10
`define ADDR_SPLL_F_MEAS_VALUE         8'h14
`define SPLL_F_MEAS_VALUE_FREQ_OFFSET 0
`define SPLL_F_MEAS_VALUE_FREQ 32'h0fffffff
`define SPLL_F_MEAS_VALUE_VALID_OFFSET 28
`define SPLL_F_MEAS_VALUE_VALID 32'h10000000
`define ADDR_SPLL_F_MEAS_CR            8'h18
`define SPLL_F_MEAS_CR_CHAN_SEL_OFFSET 0
`define SPLL_F_MEAS_CR_CHAN_SEL 32'h0000000f
`define ADDR_SPLL_PLACEHOLDER0         8'h1c
`define SPLL_PLACEHOLDER0_PLACEHOLDER_OFFSET 0
`define SPLL_PLACEHOLDER0_PLACEHOLDER 32'h0fffffff
`define ADDR_SPLL_OCCR                 8'h20
`define SPLL_OCCR_OUT_EN_OFFSET 8
`define SPLL_OCCR_OUT_EN 32'h0000ff00
`define SPLL_OCCR_OUT_LOCK_OFFSET 16
`define SPLL_OCCR_OUT_LOCK 32'h00ff0000
`define ADDR_SPLL_RCER                 8'h24
`define ADDR_SPLL_OCER                 8'h28
`define ADDR_SPLL_DAC_HPLL             8'h40
`define ADDR_SPLL_DAC_MAIN             8'h44
`define SPLL_DAC_MAIN_VALUE_OFFSET 0
`define SPLL_DAC_MAIN_VALUE 32'h0000ffff
`define SPLL_DAC_MAIN_DAC_SEL_OFFSET 16
`define SPLL_DAC_MAIN_DAC_SEL 32'h000f0000
`define ADDR_SPLL_DEGLITCH_THR         8'h48
`define ADDR_SPLL_DFR_SPLL             8'h4c
`define SPLL_DFR_SPLL_VALUE_OFFSET 0
`define SPLL_DFR_SPLL_VALUE 32'h7fffffff
`define SPLL_DFR_SPLL_EOS_OFFSET 31
`define SPLL_DFR_SPLL_EOS 32'h80000000
`define ADDR_SPLL_EIC_IDR              8'h60
`define SPLL_EIC_IDR_TAG_OFFSET 0
`define SPLL_EIC_IDR_TAG 32'h00000001
`define ADDR_SPLL_EIC_IER              8'h64
`define SPLL_EIC_IER_TAG_OFFSET 0
`define SPLL_EIC_IER_TAG 32'h00000001
`define ADDR_SPLL_EIC_IMR              8'h68
`define SPLL_EIC_IMR_TAG_OFFSET 0
`define SPLL_EIC_IMR_TAG 32'h00000001
`define ADDR_SPLL_EIC_ISR              8'h6c
`define SPLL_EIC_ISR_TAG_OFFSET 0
`define SPLL_EIC_ISR_TAG 32'h00000001
`define ADDR_SPLL_DFR_HOST_R0          8'h70
`define SPLL_DFR_HOST_R0_VALUE_OFFSET 0
`define SPLL_DFR_HOST_R0_VALUE 32'hffffffff
`define ADDR_SPLL_DFR_HOST_R1          8'h74
`define SPLL_DFR_HOST_R1_SEQ_ID_OFFSET 0
`define SPLL_DFR_HOST_R1_SEQ_ID 32'h0000ffff
`define ADDR_SPLL_DFR_HOST_CSR         8'h78
`define SPLL_DFR_HOST_CSR_FULL_OFFSET 16
`define SPLL_DFR_HOST_CSR_FULL 32'h00010000
`define SPLL_DFR_HOST_CSR_EMPTY_OFFSET 17
`define SPLL_DFR_HOST_CSR_EMPTY 32'h00020000
`define SPLL_DFR_HOST_CSR_USEDW_OFFSET 0
`define SPLL_DFR_HOST_CSR_USEDW 32'h00001fff
`define ADDR_SPLL_TRR_R0               8'h7c
`define SPLL_TRR_R0_VALUE_OFFSET 0
`define SPLL_TRR_R0_VALUE 32'h00ffffff
`define SPLL_TRR_R0_CHAN_ID_OFFSET 24
`define SPLL_TRR_R0_CHAN_ID 32'h7f000000
`define SPLL_TRR_R0_DISC_OFFSET 31
`define SPLL_TRR_R0_DISC 32'h80000000
`define ADDR_SPLL_TRR_CSR              8'h80
`define SPLL_TRR_CSR_EMPTY_OFFSET 17
`define SPLL_TRR_CSR_EMPTY 32'h00020000
