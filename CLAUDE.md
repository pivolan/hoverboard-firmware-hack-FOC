# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Field Oriented Control (FOC) firmware for hoverboard mainboards. It provides motor control for stock hoverboards with STM32F103RCT6 or GD32F103RCT6 microcontrollers. The firmware supports multiple control methods (Commutation, Sinusoidal, FOC) and various input methods (ADC, USART, PPM, PWM, iBUS, Nunchuk).

## Build Commands

### Using Make (Default)
```bash
# Build firmware (default variant)
make

# Build with specific variant
make -e VARIANT=VARIANT_ADC
make -e VARIANT=VARIANT_USART
make -e VARIANT=VARIANT_PWM
# ... other variants available

# Clean build files
make clean

# Flash firmware to board
make flash

# Unlock STM32 (if needed)
make unlock

# Format code
make format
```

### Using PlatformIO
```bash
# Build specific variant
pio run -e VARIANT_PWM
pio run -e VARIANT_USART
# ... other variants

# Upload to board
pio run -e VARIANT_PWM -t upload

# Monitor serial output
pio device monitor -b 115200
```

## High-Level Architecture

### Core Components

1. **Motor Control Core** (`Src/bldc.c`, `Src/control.c`)
   - Implements FOC/Sinusoidal/Commutation control algorithms
   - BLDC motor control generated from Simulink model
   - Handles PWM generation for both motors

2. **BLDC Controller** (`Src/BLDC_controller.c`, `Inc/BLDC_controller.h`)
   - Auto-generated from Simulink model
   - Contains FOC control loop implementation
   - Fixed-point math for efficiency

3. **Communication Layer** (`Src/comms.c`, `Inc/comms.h`)
   - Handles USART2/3 serial communication
   - Supports multiple protocols (USART, iBUS, PPM, PWM)
   - Manages sideboard communication

4. **Configuration System** (`Inc/config.h`)
   - Central configuration for all variants
   - Motor parameters, battery settings, control modes
   - Variant-specific configurations

5. **Hardware Abstraction** (`Src/setup.c`, `Src/stm32f1xx_it.c`)
   - STM32 HAL initialization
   - ADC, Timer, GPIO configuration
   - Interrupt handlers

### Key Variants

- **VARIANT_ADC**: Control via analog potentiometers
- **VARIANT_USART**: Serial protocol control
- **VARIANT_NUNCHUK**: Wii Nunchuk controller
- **VARIANT_PPM/PWM**: RC remote control
- **VARIANT_IBUS**: Flysky iBUS protocol
- **VARIANT_HOVERCAR**: Pedal-controlled vehicle
- **VARIANT_HOVERBOARD**: Original sideboard compatibility

### Control Modes

1. **FOC_CTRL** (Field Oriented Control)
   - VOLTAGE MODE: Constant voltage, fast response
   - SPEED MODE: Closed-loop speed control
   - TORQUE MODE: Torque control with freewheeling

2. **SIN_CTRL** (Sinusoidal Control)
   - Smooth sinusoidal commutation
   - Phase advance support

3. **COM_CTRL** (Block Commutation)
   - Simple 6-step commutation
   - Basic but robust

## Important Notes

- The current branch is `pwm` (not `main`)
- Default variant in platformio.ini is set to VARIANT_PWM
- ADC conversion and PWM timing are critical - see ADC_TOTAL_CONV_TIME in config.h
- Fixed-point math is used extensively for performance
- Motor parameters are calibrated in `Src/BLDC_controller_data.c`
- Field weakening can be enabled but requires careful calibration (safety risk)

## Custom Coast Mode (FOC+SPD with smooth acceleration)

**Modified Speed Mode behavior to prevent battery drain and wheel fighting:**

### Features (config.h lines 154-157):
- `COAST_MODE_ENABLE`: Enable coasting mode with modified SPD_MODE behavior
- `COAST_ACCEL_RATE`: Acceleration rate limit in RPM/cycle (default: 100)
- `COAST_NO_BRAKE`: Disable active braking when current speed exceeds target

### Behavior:
1. **Zero input** → Coast (no power, natural deceleration)
2. **Current speed > target speed** → Coast (no active braking, saves battery)
3. **Current speed < target speed** → Smooth acceleration with rate limiting
4. **Maximum speed limit** → Always respected (N_MOT_MAX = 150 RPM)

### Benefits:
- No wheel fighting in tank steering mode
- Significant battery savings (no constant position holding)
- Smooth, progressive acceleration
- Natural coasting feel
- Maintains speed control for traction

### Tuning:
Adjust `COAST_ACCEL_RATE` in config.h:156:
- Higher value (e.g., 200) = faster acceleration
- Lower value (e.g., 50) = smoother, gentler acceleration