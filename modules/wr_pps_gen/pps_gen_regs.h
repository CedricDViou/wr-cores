/*
  Register definitions for slave core: WR Switch PPS generator and RTC

  * File           : pps_gen_regs.h
  * Author         : auto-generated by wbgen2 from pps_gen_wb.wb
  * Created        : Wed Jun 23 23:57:56 2021
  * Standard       : ANSI C

    THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE pps_gen_wb.wb
    DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!

*/

#ifndef __WBGEN2_REGDEFS_PPS_GEN_WB_WB
#define __WBGEN2_REGDEFS_PPS_GEN_WB_WB

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


/* definitions for register: Control Register */

/* definitions for field: Reset counter in reg: Control Register */
#define PPSG_CR_CNT_RST                       WBGEN2_GEN_MASK(0, 1)

/* definitions for field: Enable counter in reg: Control Register */
#define PPSG_CR_CNT_EN                        WBGEN2_GEN_MASK(1, 1)

/* definitions for field: Adjust offset in reg: Control Register */
#define PPSG_CR_CNT_ADJ                       WBGEN2_GEN_MASK(2, 1)

/* definitions for field: Set time in reg: Control Register */
#define PPSG_CR_CNT_SET                       WBGEN2_GEN_MASK(3, 1)

/* definitions for field: PPS Pulse width in reg: Control Register */
#define PPSG_CR_PWIDTH_MASK                   WBGEN2_GEN_MASK(4, 28)
#define PPSG_CR_PWIDTH_SHIFT                  4
#define PPSG_CR_PWIDTH_W(value)               WBGEN2_GEN_WRITE(value, 4, 28)
#define PPSG_CR_PWIDTH_R(reg)                 WBGEN2_GEN_READ(reg, 4, 28)

/* definitions for register: Nanosecond counter register */

/* definitions for register: UTC Counter register (least-significant part) */

/* definitions for register: UTC Counter register (most-significant part) */

/* definitions for register: Nanosecond adjustment register */

/* definitions for register: UTC Adjustment register (least-significant part) */

/* definitions for register: UTC Adjustment register (most-significant part) */

/* definitions for register: External sync control register */

/* definitions for field: Sync to external PPS input in reg: External sync control register */
#define PPSG_ESCR_SYNC                        WBGEN2_GEN_MASK(0, 1)

/* definitions for field: PPS unmask output in reg: External sync control register */
#define PPSG_ESCR_PPS_UNMASK                  WBGEN2_GEN_MASK(1, 1)

/* definitions for field: PPS output valid in reg: External sync control register */
#define PPSG_ESCR_PPS_VALID                   WBGEN2_GEN_MASK(2, 1)

/* definitions for field: Timecode output(UTC+cycles) valid in reg: External sync control register */
#define PPSG_ESCR_TM_VALID                    WBGEN2_GEN_MASK(3, 1)

/* definitions for field: Set seconds counter in reg: External sync control register */
#define PPSG_ESCR_SEC_SET                     WBGEN2_GEN_MASK(4, 1)

/* definitions for field: Set nanoseconds counter in reg: External sync control register */
#define PPSG_ESCR_NSEC_SET                    WBGEN2_GEN_MASK(5, 1)

PACKED struct PPSG_WB {
  /* [0x0]: REG Control Register */
  uint32_t CR;
  /* [0x4]: REG Nanosecond counter register */
  uint32_t CNTR_NSEC;
  /* [0x8]: REG UTC Counter register (least-significant part) */
  uint32_t CNTR_UTCLO;
  /* [0xc]: REG UTC Counter register (most-significant part) */
  uint32_t CNTR_UTCHI;
  /* [0x10]: REG Nanosecond adjustment register */
  uint32_t ADJ_NSEC;
  /* [0x14]: REG UTC Adjustment register (least-significant part) */
  uint32_t ADJ_UTCLO;
  /* [0x18]: REG UTC Adjustment register (most-significant part) */
  uint32_t ADJ_UTCHI;
  /* [0x1c]: REG External sync control register */
  uint32_t ESCR;
};

#endif
