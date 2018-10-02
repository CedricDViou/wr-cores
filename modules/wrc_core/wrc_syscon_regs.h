/*
  Register definitions for slave core: WR Core System Controller

  * File           : wrc_syscon_regs.h
  * Author         : auto-generated by wbgen2 from wrc_syscon_wb.wb
  * Created        : Tue Oct  2 10:46:20 2018
  * Standard       : ANSI C

    THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE wrc_syscon_wb.wb
    DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!

*/

#ifndef __WBGEN2_REGDEFS_WRC_SYSCON_WB_WB
#define __WBGEN2_REGDEFS_WRC_SYSCON_WB_WB

#ifdef __KERNEL__
#include <linux/types.h>
#else
#include <inttypes.h>
#endif

#if defined( __GNUC__)
#define PACKED __attribute__ ((packed))
#else
#error "Unsupported compiler?"
#endif

#ifndef __WBGEN2_MACROS_DEFINED__
#define __WBGEN2_MACROS_DEFINED__
#define WBGEN2_GEN_MASK(offset, size) (((1<<(size))-1) << (offset))
#define WBGEN2_GEN_WRITE(value, offset, size) (((value) & ((1<<(size))-1)) << (offset))
#define WBGEN2_GEN_READ(reg, offset, size) (((reg) >> (offset)) & ((1<<(size))-1))
#define WBGEN2_SIGN_EXTEND(value, bits) (((value) & (1<<bits) ? ~((1<<(bits))-1): 0 ) | (value))
#endif


/* definitions for register: Syscon reset register */

/* definitions for field: Reset trigger in reg: Syscon reset register */
#define SYSC_RSTR_TRIG_MASK                   WBGEN2_GEN_MASK(0, 28)
#define SYSC_RSTR_TRIG_SHIFT                  0
#define SYSC_RSTR_TRIG_W(value)               WBGEN2_GEN_WRITE(value, 0, 28)
#define SYSC_RSTR_TRIG_R(reg)                 WBGEN2_GEN_READ(reg, 0, 28)

/* definitions for field: Reset line state value in reg: Syscon reset register */
#define SYSC_RSTR_RST                         WBGEN2_GEN_MASK(28, 1)

/* definitions for register: GPIO Set/Readback Register */

/* definitions for field: Status LED in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_LED_STAT                    WBGEN2_GEN_MASK(0, 1)

/* definitions for field: Link LED in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_LED_LINK                    WBGEN2_GEN_MASK(1, 1)

/* definitions for field: FMC I2C bitbanged SCL in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_FMC_SCL                     WBGEN2_GEN_MASK(2, 1)

/* definitions for field: FMC I2C bitbanged SDA in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_FMC_SDA                     WBGEN2_GEN_MASK(3, 1)

/* definitions for field: Network AP reset in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_NET_RST                     WBGEN2_GEN_MASK(4, 1)

/* definitions for field: SPEC Pushbutton 1 state in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_BTN1                        WBGEN2_GEN_MASK(5, 1)

/* definitions for field: SPEC Pushbutton 2 state in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_BTN2                        WBGEN2_GEN_MASK(6, 1)

/* definitions for field: SFP detect (MOD_DEF0 signal) in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_SFP_DET                     WBGEN2_GEN_MASK(7, 1)

/* definitions for field: SFP I2C bitbanged SCL in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_SFP_SCL                     WBGEN2_GEN_MASK(8, 1)

/* definitions for field: SFP I2C bitbanged SDA in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_SFP_SDA                     WBGEN2_GEN_MASK(9, 1)

/* definitions for field: SPI bitbanged SCLK in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_SPI_SCLK                    WBGEN2_GEN_MASK(10, 1)

/* definitions for field: SPI bitbanged NCS in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_SPI_NCS                     WBGEN2_GEN_MASK(11, 1)

/* definitions for field: SPI bitbanged MOSI in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_SPI_MOSI                    WBGEN2_GEN_MASK(12, 1)

/* definitions for field: SPI bitbanged MISO in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_SPI_MISO                    WBGEN2_GEN_MASK(13, 1)

/* definitions for field: DP Status LED in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_DP_LED_STAT                 WBGEN2_GEN_MASK(14, 1)

/* definitions for field: DP Link LED in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_DP_LED_LINK                 WBGEN2_GEN_MASK(15, 1)

/* definitions for field: DP SFP detect (MOD_DEF0 signal) in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_DP_SFP_DET                  WBGEN2_GEN_MASK(16, 1)

/* definitions for field: DP SFP I2C bitbanged SCL in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_DP_SFP_SCL                  WBGEN2_GEN_MASK(17, 1)

/* definitions for field: DP SFP I2C bitbanged SDA in reg: GPIO Set/Readback Register */
#define SYSC_GPSR_DP_SFP_SDA                  WBGEN2_GEN_MASK(18, 1)

/* definitions for register: GPIO Clear Register */

/* definitions for field: Status LED in reg: GPIO Clear Register */
#define SYSC_GPCR_LED_STAT                    WBGEN2_GEN_MASK(0, 1)

/* definitions for field: Link LED in reg: GPIO Clear Register */
#define SYSC_GPCR_LED_LINK                    WBGEN2_GEN_MASK(1, 1)

/* definitions for field: FMC I2C bitbanged SCL in reg: GPIO Clear Register */
#define SYSC_GPCR_FMC_SCL                     WBGEN2_GEN_MASK(2, 1)

/* definitions for field: FMC I2C bitbanged SDA in reg: GPIO Clear Register */
#define SYSC_GPCR_FMC_SDA                     WBGEN2_GEN_MASK(3, 1)

/* definitions for field: SFP I2C bitbanged SCL in reg: GPIO Clear Register */
#define SYSC_GPCR_SFP_SCL                     WBGEN2_GEN_MASK(8, 1)

/* definitions for field: SFP I2C bitbanged SDA in reg: GPIO Clear Register */
#define SYSC_GPCR_SFP_SDA                     WBGEN2_GEN_MASK(9, 1)

/* definitions for field: SPI bitbanged SCLK in reg: GPIO Clear Register */
#define SYSC_GPCR_SPI_SCLK                    WBGEN2_GEN_MASK(10, 1)

/* definitions for field: SPI bitbanged CS in reg: GPIO Clear Register */
#define SYSC_GPCR_SPI_CS                      WBGEN2_GEN_MASK(11, 1)

/* definitions for field: SPI bitbanged MOSI in reg: GPIO Clear Register */
#define SYSC_GPCR_SPI_MOSI                    WBGEN2_GEN_MASK(12, 1)

/* definitions for field: DP Status LED in reg: GPIO Clear Register */
#define SYSC_GPCR_DP_LED_STAT                 WBGEN2_GEN_MASK(14, 1)

/* definitions for field: DP Link LED in reg: GPIO Clear Register */
#define SYSC_GPCR_DP_LED_LINK                 WBGEN2_GEN_MASK(15, 1)

/* definitions for field: DP SFP I2C bitbanged SCL in reg: GPIO Clear Register */
#define SYSC_GPCR_DP_SFP_SCL                  WBGEN2_GEN_MASK(17, 1)

/* definitions for field: DP SFP I2C bitbanged SDA in reg: GPIO Clear Register */
#define SYSC_GPCR_DP_SFP_SDA                  WBGEN2_GEN_MASK(18, 1)

/* definitions for register: Hardware Feature Register */

/* definitions for field: Memory size in reg: Hardware Feature Register */
#define SYSC_HWFR_MEMSIZE_MASK                WBGEN2_GEN_MASK(0, 4)
#define SYSC_HWFR_MEMSIZE_SHIFT               0
#define SYSC_HWFR_MEMSIZE_W(value)            WBGEN2_GEN_WRITE(value, 0, 4)
#define SYSC_HWFR_MEMSIZE_R(reg)              WBGEN2_GEN_READ(reg, 0, 4)

/* definitions for field: Storage type in reg: Hardware Feature Register */
#define SYSC_HWFR_STORAGE_TYPE_MASK           WBGEN2_GEN_MASK(8, 2)
#define SYSC_HWFR_STORAGE_TYPE_SHIFT          8
#define SYSC_HWFR_STORAGE_TYPE_W(value)       WBGEN2_GEN_WRITE(value, 8, 2)
#define SYSC_HWFR_STORAGE_TYPE_R(reg)         WBGEN2_GEN_READ(reg, 8, 2)

/* definitions for field: Storage sector size in reg: Hardware Feature Register */
#define SYSC_HWFR_STORAGE_SEC_MASK            WBGEN2_GEN_MASK(16, 16)
#define SYSC_HWFR_STORAGE_SEC_SHIFT           16
#define SYSC_HWFR_STORAGE_SEC_W(value)        WBGEN2_GEN_WRITE(value, 16, 16)
#define SYSC_HWFR_STORAGE_SEC_R(reg)          WBGEN2_GEN_READ(reg, 16, 16)

/* definitions for register: Hardware Info Register */

/* definitions for field: Board name in reg: Hardware Info Register */
#define SYSC_HWIR_NAME_MASK                   WBGEN2_GEN_MASK(0, 32)
#define SYSC_HWIR_NAME_SHIFT                  0
#define SYSC_HWIR_NAME_W(value)               WBGEN2_GEN_WRITE(value, 0, 32)
#define SYSC_HWIR_NAME_R(reg)                 WBGEN2_GEN_READ(reg, 0, 32)

/* definitions for register: Storage SDBFS info */

/* definitions for field: Base address in reg: Storage SDBFS info */
#define SYSC_SDBFS_BADDR_MASK                 WBGEN2_GEN_MASK(0, 32)
#define SYSC_SDBFS_BADDR_SHIFT                0
#define SYSC_SDBFS_BADDR_W(value)             WBGEN2_GEN_WRITE(value, 0, 32)
#define SYSC_SDBFS_BADDR_R(reg)               WBGEN2_GEN_READ(reg, 0, 32)

/* definitions for register: Timer Control Register */

/* definitions for field: Timer Divider in reg: Timer Control Register */
#define SYSC_TCR_TDIV_MASK                    WBGEN2_GEN_MASK(0, 12)
#define SYSC_TCR_TDIV_SHIFT                   0
#define SYSC_TCR_TDIV_W(value)                WBGEN2_GEN_WRITE(value, 0, 12)
#define SYSC_TCR_TDIV_R(reg)                  WBGEN2_GEN_READ(reg, 0, 12)

/* definitions for field: Timer Enable in reg: Timer Control Register */
#define SYSC_TCR_ENABLE                       WBGEN2_GEN_MASK(31, 1)

/* definitions for register: Timer Counter Value Register */

/* definitions for register: User Diag: version register */

/* definitions for field: Ver in reg: User Diag: version register */
#define SYSC_DIAG_INFO_VER_MASK               WBGEN2_GEN_MASK(0, 16)
#define SYSC_DIAG_INFO_VER_SHIFT              0
#define SYSC_DIAG_INFO_VER_W(value)           WBGEN2_GEN_WRITE(value, 0, 16)
#define SYSC_DIAG_INFO_VER_R(reg)             WBGEN2_GEN_READ(reg, 0, 16)

/* definitions for field: Id in reg: User Diag: version register */
#define SYSC_DIAG_INFO_ID_MASK                WBGEN2_GEN_MASK(16, 16)
#define SYSC_DIAG_INFO_ID_SHIFT               16
#define SYSC_DIAG_INFO_ID_W(value)            WBGEN2_GEN_WRITE(value, 16, 16)
#define SYSC_DIAG_INFO_ID_R(reg)              WBGEN2_GEN_READ(reg, 16, 16)

/* definitions for register: User Diag: number of words */

/* definitions for field: Read/write words in reg: User Diag: number of words */
#define SYSC_DIAG_NW_RW_MASK                  WBGEN2_GEN_MASK(0, 16)
#define SYSC_DIAG_NW_RW_SHIFT                 0
#define SYSC_DIAG_NW_RW_W(value)              WBGEN2_GEN_WRITE(value, 0, 16)
#define SYSC_DIAG_NW_RW_R(reg)                WBGEN2_GEN_READ(reg, 0, 16)

/* definitions for field: Read-only words in reg: User Diag: number of words */
#define SYSC_DIAG_NW_RO_MASK                  WBGEN2_GEN_MASK(16, 16)
#define SYSC_DIAG_NW_RO_SHIFT                 16
#define SYSC_DIAG_NW_RO_W(value)              WBGEN2_GEN_WRITE(value, 16, 16)
#define SYSC_DIAG_NW_RO_R(reg)                WBGEN2_GEN_READ(reg, 16, 16)

/* definitions for register: User Diag: Control Register */

/* definitions for field: Address in reg: User Diag: Control Register */
#define SYSC_DIAG_CR_ADR_MASK                 WBGEN2_GEN_MASK(0, 16)
#define SYSC_DIAG_CR_ADR_SHIFT                0
#define SYSC_DIAG_CR_ADR_W(value)             WBGEN2_GEN_WRITE(value, 0, 16)
#define SYSC_DIAG_CR_ADR_R(reg)               WBGEN2_GEN_READ(reg, 0, 16)

/* definitions for field: R/W in reg: User Diag: Control Register */
#define SYSC_DIAG_CR_RW                       WBGEN2_GEN_MASK(31, 1)

/* definitions for register: User Diag: data to read/write */

/* definitions for register: WRPC Diag: ctrl */

/* definitions for field: WR DIAG data valid in reg: WRPC Diag: ctrl */
#define SYSC_WDIAG_CTRL_DATA_VALID            WBGEN2_GEN_MASK(0, 1)

/* definitions for field: WR DIAG data snapshot in reg: WRPC Diag: ctrl */
#define SYSC_WDIAG_CTRL_DATA_SNAPSHOT         WBGEN2_GEN_MASK(8, 1)

/* definitions for register: WRPC Diag: servo status */

/* definitions for field: WR valid in reg: WRPC Diag: servo status */
#define SYSC_WDIAG_SSTAT_WR_MODE              WBGEN2_GEN_MASK(0, 1)

/* definitions for field: Servo State in reg: WRPC Diag: servo status */
#define SYSC_WDIAG_SSTAT_SERVOSTATE_MASK      WBGEN2_GEN_MASK(8, 4)
#define SYSC_WDIAG_SSTAT_SERVOSTATE_SHIFT     8
#define SYSC_WDIAG_SSTAT_SERVOSTATE_W(value)  WBGEN2_GEN_WRITE(value, 8, 4)
#define SYSC_WDIAG_SSTAT_SERVOSTATE_R(reg)    WBGEN2_GEN_READ(reg, 8, 4)

/* definitions for register: WRPC Diag: Port status */

/* definitions for field: Link Status in reg: WRPC Diag: Port status */
#define SYSC_WDIAG_PSTAT_LINK                 WBGEN2_GEN_MASK(0, 1)

/* definitions for field: PLL Locked in reg: WRPC Diag: Port status */
#define SYSC_WDIAG_PSTAT_LOCKED               WBGEN2_GEN_MASK(1, 1)

/* definitions for register: WRPC Diag: PTP state */

/* definitions for field: PTP State in reg: WRPC Diag: PTP state */
#define SYSC_WDIAG_PTPSTAT_PTPSTATE_MASK      WBGEN2_GEN_MASK(0, 8)
#define SYSC_WDIAG_PTPSTAT_PTPSTATE_SHIFT     0
#define SYSC_WDIAG_PTPSTAT_PTPSTATE_W(value)  WBGEN2_GEN_WRITE(value, 0, 8)
#define SYSC_WDIAG_PTPSTAT_PTPSTATE_R(reg)    WBGEN2_GEN_READ(reg, 0, 8)

/* definitions for register: WRPC Diag: AUX state */

/* definitions for field: AUX channel in reg: WRPC Diag: AUX state */
#define SYSC_WDIAG_ASTAT_AUX_MASK             WBGEN2_GEN_MASK(0, 8)
#define SYSC_WDIAG_ASTAT_AUX_SHIFT            0
#define SYSC_WDIAG_ASTAT_AUX_W(value)         WBGEN2_GEN_WRITE(value, 0, 8)
#define SYSC_WDIAG_ASTAT_AUX_R(reg)           WBGEN2_GEN_READ(reg, 0, 8)

/* definitions for register: WRPC Diag: Tx PTP Frame cnts */

/* definitions for register: WRPC Diag: Rx PTP Frame cnts */

/* definitions for register: WRPC Diag:local time [msb of s] */

/* definitions for register: WRPC Diag: local time [lsb of s] */

/* definitions for register: WRPC Diag: local time [ns] */

/* definitions for register: WRPC Diag: Round trip (mu) [msb of ps] */

/* definitions for register: WRPC Diag: Round trip (mu) [lsb of ps] */

/* definitions for register: WRPC Diag: Master-slave delay (dms) [msb of ps] */

/* definitions for register: WRPC Diag: Master-slave delay (dms) [lsb of ps] */

/* definitions for register: WRPC Diag: Total link asymmetry [ps] */

/* definitions for register: WRPC Diag: Clock offset (cko) [ps] */

/* definitions for register: WRPC Diag: Phase setpoint (setp) [ps] */

/* definitions for register: WRPC Diag: Update counter (ucnt) */

/* definitions for register: WRPC Diag: Board temperature [C degree] */
/* [0x0]: REG Syscon reset register */
#define SYSC_REG_RSTR 0x00000000
/* [0x4]: REG GPIO Set/Readback Register */
#define SYSC_REG_GPSR 0x00000004
/* [0x8]: REG GPIO Clear Register */
#define SYSC_REG_GPCR 0x00000008
/* [0xc]: REG Hardware Feature Register */
#define SYSC_REG_HWFR 0x0000000c
/* [0x10]: REG Hardware Info Register */
#define SYSC_REG_HWIR 0x00000010
/* [0x14]: REG Storage SDBFS info */
#define SYSC_REG_SDBFS 0x00000014
/* [0x18]: REG Timer Control Register */
#define SYSC_REG_TCR 0x00000018
/* [0x1c]: REG Timer Counter Value Register */
#define SYSC_REG_TVR 0x0000001c
/* [0x20]: REG User Diag: version register */
#define SYSC_REG_DIAG_INFO 0x00000020
/* [0x24]: REG User Diag: number of words */
#define SYSC_REG_DIAG_NW 0x00000024
/* [0x28]: REG User Diag: Control Register */
#define SYSC_REG_DIAG_CR 0x00000028
/* [0x2c]: REG User Diag: data to read/write */
#define SYSC_REG_DIAG_DAT 0x0000002c
/* [0x30]: REG WRPC Diag: ctrl */
#define SYSC_REG_WDIAG_CTRL 0x00000030
/* [0x34]: REG WRPC Diag: servo status */
#define SYSC_REG_WDIAG_SSTAT 0x00000034
/* [0x38]: REG WRPC Diag: Port status */
#define SYSC_REG_WDIAG_PSTAT 0x00000038
/* [0x3c]: REG WRPC Diag: PTP state */
#define SYSC_REG_WDIAG_PTPSTAT 0x0000003c
/* [0x40]: REG WRPC Diag: AUX state */
#define SYSC_REG_WDIAG_ASTAT 0x00000040
/* [0x44]: REG WRPC Diag: Tx PTP Frame cnts */
#define SYSC_REG_WDIAG_TXFCNT 0x00000044
/* [0x48]: REG WRPC Diag: Rx PTP Frame cnts */
#define SYSC_REG_WDIAG_RXFCNT 0x00000048
/* [0x4c]: REG WRPC Diag:local time [msb of s] */
#define SYSC_REG_WDIAG_SEC_MSB 0x0000004c
/* [0x50]: REG WRPC Diag: local time [lsb of s] */
#define SYSC_REG_WDIAG_SEC_LSB 0x00000050
/* [0x54]: REG WRPC Diag: local time [ns] */
#define SYSC_REG_WDIAG_NS 0x00000054
/* [0x58]: REG WRPC Diag: Round trip (mu) [msb of ps] */
#define SYSC_REG_WDIAG_MU_MSB 0x00000058
/* [0x5c]: REG WRPC Diag: Round trip (mu) [lsb of ps] */
#define SYSC_REG_WDIAG_MU_LSB 0x0000005c
/* [0x60]: REG WRPC Diag: Master-slave delay (dms) [msb of ps] */
#define SYSC_REG_WDIAG_DMS_MSB 0x00000060
/* [0x64]: REG WRPC Diag: Master-slave delay (dms) [lsb of ps] */
#define SYSC_REG_WDIAG_DMS_LSB 0x00000064
/* [0x68]: REG WRPC Diag: Total link asymmetry [ps] */
#define SYSC_REG_WDIAG_ASYM 0x00000068
/* [0x6c]: REG WRPC Diag: Clock offset (cko) [ps] */
#define SYSC_REG_WDIAG_CKO 0x0000006c
/* [0x70]: REG WRPC Diag: Phase setpoint (setp) [ps] */
#define SYSC_REG_WDIAG_SETP 0x00000070
/* [0x74]: REG WRPC Diag: Update counter (ucnt) */
#define SYSC_REG_WDIAG_UCNT 0x00000074
/* [0x78]: REG WRPC Diag: Board temperature [C degree] */
#define SYSC_REG_WDIAG_TEMP 0x00000078
#endif
