# Plan — LED Dot-Matrix Alarm Clock (MAX7219 + Zynq XC7Z020)

## 1. Goal

Build an alarm clock on the **Zynq-7000 (XC7Z020, ZedBoard-class)** that drives **4× 8×8 LED
dot-matrix modules** based on **MAX7219** chips, daisy-chained over a 3-wire serial link.

The work splits across the two halves of the Zynq:

| Half | Runs | Responsibility |
|------|------|----------------|
| **PL** (FPGA / Verilog) | Custom AXI4-Lite peripheral | Display memory, ASCII→glyph font, column→row transposition, MAX7219 serial driver, blink, refresh |
| **PS** (ARM Cortex-A9 / C) | Bare-metal application | Clock/alarm logic, mode state machine, keypad service (debounce + auto-repeat), RTC via timer interrupt |

The PL peripheral is mapped into the **AXI GP0** address space so the CPU has **direct R/W
access to display memory** and control registers.

---

## 2. How the MAX7219 is used here (from the datasheet)

- **Frame format:** 16 bits, MSB first. `D15–D12` = don't care, `D11–D8` = address, `D7–D0` = data.
  Shifted on CLK rising edge, latched on **LOAD** rising edge.
- **Matrix mapping:** each digit register `0x01..0x08` = one **row** of an 8×8 module; the 8 data
  bits = the 8 LEDs of that row. (Physical orientation depends on module wiring — confirm with the
  real module; transpose/mirror in HW if rotated 90°.)
- **Cascade:** for 4 modules, shift **64 bits** (chip-far first), then one LOAD pulse updates all.
- **Init registers** (write once at startup):
  - `0x09` Decode mode = `0x00` (**no decode** — required for matrix)
  - `0x0A` Intensity = `0x00..0x0F` (brightness)
  - `0x0B` Scan limit = `0x07` (all 8 rows)
  - `0x0C` Shutdown = `0x01` (normal operation; `0x00` = shutdown)
  - `0x0F` Display test = `0x00` (off)
- Serial clock can run far below the 10 MHz max — derive a slow CLK from the AXI clock.

---

## 3. PL (Verilog) design

### 3.1 Block diagram
```
 AXI4-Lite (GP0)
      │  reg writes/reads
      ▼
 ┌──────────────────────────────────────────────┐
 │ axi_led_matrix (S00_AXI register file)       │
 │  - display RAM (ASCII codes, RW)             │
 │  - control: intensity, blink mask, enable    │
 │  - status                                    │
 └───────┬───────────────────────────┬──────────┘
         │ ASCII char per cell        │ blink mask
         ▼                            │
   ┌───────────┐                      │
   │ font_rom  │ ASCII → 8×8 glyph    │
   └─────┬─────┘                      │
         ▼ column-wise glyph          ▼
   ┌─────────────┐   blink gating  ┌──────────────┐
   │ transpose   │────────────────▶│ max7219_drv  │── DIN/CLK/LOAD ▶ MAX7219 ×4
   │ col → row   │  64-bit frame   │ (shift + FSM)│
   └─────────────┘                 └──────────────┘
```

### 3.2 Verilog modules / files

| File | Purpose |
|------|---------|
| `hdl/axi_led_matrix_v1_0.v` | IP top wrapper (Vivado IP packager generates skeleton) |
| `hdl/axi_led_matrix_v1_0_S00_AXI.v` | AXI4-Lite slave: register file + display RAM, read/write decode |
| `hdl/display_ram.v` | Dual-port display memory (ASCII bytes); CPU port + render port |
| `hdl/font_rom.v` | ROM: ASCII code → 8×8 glyph (8 bytes/char). Init from `font.mem` |
| `hdl/transpose.v` | Column-based glyph → row-based bytes the MAX7219 expects |
| `hdl/blink_ctrl.v` | Blink-position mask + ~1–2 Hz blink phase, blanks selected cells |
| `hdl/max7219_driver.v` | Serial engine: build 64-bit frame, generate DIN/CLK/LOAD, init sequence FSM, periodic refresh |
| `hdl/clk_div.v` | Derive slow serial clock + refresh tick from AXI clock |
| `sim/tb_max7219_driver.v` | Testbench: check init sequence and a known frame on DIN/CLK/LOAD |
| `sim/tb_axi_led_matrix.v` | Testbench: AXI write/read of display RAM and control regs |
| `constraints/led_matrix.xdc` | Pin constraints: DIN, CLK, LOAD (Pmod), push-buttons |
| `data/font.mem` | Glyph table (`$readmemh`), at least `0-9`, `:`, space, `A`, `P`, `M` |

### 3.3 Suggested AXI register map (AXI GP0, word-addressed)

| Offset | Name | Access | Description |
|--------|------|--------|-------------|
| `0x00–0x0F` | `DISP_MEM[0..N]` | RW | Display memory, **ASCII-encoded** characters (one char per cell) |
| `0x20` | `CTRL` | RW | bit0 enable/shutdown, bit1 display-test |
| `0x24` | `INTENSITY` | RW | bits[3:0] brightness 0–15 |
| `0x28` | `BLINK_MASK` | RW | one bit per character cell = blink that **digit position** |
| `0x2C` | `STATUS` | R | bitfield: driver busy / frame done |

> Keep "ASCII-based display memory" and "digit position to blink" as explicit registers — both are
> named requirements in the instruction.

---

## 4. PS (C) software

### 4.1 Files

| File | Purpose |
|------|---------|
| `sw/main.c` | Init platform, IP, interrupts; main loop / state dispatch |
| `sw/max7219.c` / `.h` | Driver: AXI register access, write ASCII string to display, set blink mask, set intensity, enable |
| `sw/keypad.c` / `.h` | Button read with **debounce** + **auto-repeat**; emits key events |
| `sw/rtc.c` / `.h` | **RTC**: TTC/SCU timer 1 Hz interrupt, keeps hh:mm:ss, tick callback |
| `sw/clock_app.c` / `.h` | Mode state machine, alarm compare, set-mode digit flashing |
| `sw/font.h` | (optional) shared char constants if any rendering done in SW |

(BSP-generated `xparameters.h`, `platform.c`, `xgpio`/`xscutimer`/`xscugic` come from Vitis.)

### 4.2 Application behaviour (from instruction)

- **Modes:** `SHOW_TIME`, `SET_TIME`, `SET_ALARM` (cycled by a Mode button).
- **Display content depends on mode:** current time normally; the time/alarm being edited in set modes.
- **Set operation → flashing digits:** in `SET_*` modes, write the edited digit position into
  `BLINK_MASK` so the PL blinks it; clear the mask when leaving set mode.
- **Keypad service:** Mode / + / − (and optionally Alarm-toggle). Debounce (~20 ms sample),
  auto-repeat (hold > ~500 ms then repeat ~every 150 ms) for fast value changes.
- **RTC:** 1 Hz timer ISR increments seconds→minutes→hours (24 h), sets a "time changed" flag.
- **Alarm:** when `current == alarm` and alarm enabled, flash whole display / toggle shutdown bit
  as an alarm indication; cleared by a key.

### 4.3 Driver init order (`max7219_init`)
1. Set scan-limit / decode / intensity / test-off via the PL (PL may do this autonomously in its
   FSM — decide who owns init; recommended: **PL does the MAX7219 init**, SW just writes content).
2. Enable display (`CTRL.enable = 1`).
3. Write initial time string to `DISP_MEM`.

---

## 5. Milestones

1. **HW bring-up:** `max7219_driver.v` + `clk_div.v` + testbench → push a fixed pattern to 4 chips,
   verify on hardware (e.g. all-on / a known glyph).
2. **AXI peripheral:** package `axi_led_matrix`, map display RAM + control regs, prove CPU R/W from
   a bare-metal "write byte → see pixel" test.
3. **Font + transpose:** ASCII in display RAM → correct glyphs on the matrix.
4. **Clock core:** RTC timer ISR + render `HH:MM` and keep it ticking.
5. **Keypad:** debounce + auto-repeat, drive a counter on screen.
6. **Modes + blink:** set-time / set-alarm with flashing edited digit via `BLINK_MASK`.
7. **Alarm:** compare + indication, polish brightness/blink rate.

---

## 6. Open decisions to confirm early

- **Module orientation / wiring** of the real 4-in-1 board → fixes whether `transpose.v` also needs
  a horizontal mirror or 90° rotation, and the chip order in the 64-bit frame.
- **Display width:** 4×8 = 32 columns. With a 5–6 px font that's ~4–5 characters → choose layout for
  `HH:MM` (e.g. narrow 3-col digits + colon, or scroll). Decide font cell width now.
- **Who runs MAX7219 init** — PL FSM (recommended, robust) vs. SW driver.
- **Buttons:** which on-board / Pmod buttons map to Mode / + / − / Alarm.
- **Board:** instruction says XC7Z020; confirm exact board (ZedBoard?) for the correct `.xdc` pins.
