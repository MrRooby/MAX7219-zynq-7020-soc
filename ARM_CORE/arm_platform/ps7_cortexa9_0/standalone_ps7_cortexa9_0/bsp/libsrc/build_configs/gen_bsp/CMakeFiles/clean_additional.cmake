# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/include/sleep.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/include/xiltimer.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/include/xtimer_config.h"
  "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform/ps7_cortexa9_0/standalone_ps7_cortexa9_0/bsp/lib/libxiltimer.a"
  )
endif()
