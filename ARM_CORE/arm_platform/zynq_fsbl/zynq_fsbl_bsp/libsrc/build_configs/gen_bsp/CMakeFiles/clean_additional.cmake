# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/diskio.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/ff.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/ffconf.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/sleep.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/xilffs.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/xilffs_config.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/xilrsa.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/xiltimer.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/include/xtimer_config.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxilffs.a"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxilrsa.a"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/zynq_fsbl/zynq_fsbl_bsp/lib/libxiltimer.a"
  )
endif()
