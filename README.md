# FPGA Mastermind Game – CS303 Project

This project was developed as part of the CS303 Logic and Digital System Design course at Sabanci University.

## Project Description
A hardware-based implementation of the classic Mastermind code-breaking game on FPGA. The system allows two players to compete against each other using physical buttons and switches, with real-time feedback displayed via LEDs and 7-segment displays.

## Game Rules
Mastermind is a two-player code-breaking game where:
- **Code Maker**: Creates a secret 4-character code using letters: A, C, E, F, H, L, U
- **Code Breaker**: Has 3 attempts to guess the code
- After each guess, the system provides feedback via 8 LEDs (2 LEDs per character):
  - **Both LEDs ON (11)**: Correct letter in correct position
  - **One LED ON (01)**: Correct letter in wrong position
  - **Both LEDs OFF (00)**: Letter not in the code
- Players alternate roles after each round
- First player to score 2 points wins the game

## Hardware Components
- **FPGA Board**: Tang Nano 9K (Gowin GW1NR-9)
- **Inputs**:
  - 2 push buttons (Player A and Player B)
  - 3 switches for letter selection (3-bit binary input)
  - 1 reset button
- **Outputs**:
  - 8 LEDs for game feedback
  - 4-digit 7-segment display
  - 7 segment lines + decimal point

## Pin Mapping (TangNano9K)

### Input Pins
| Signal | Pin | Description |
|--------|-----|-------------|
| clk | 52 | System clock (27 MHz) |
| rst | 75 | Reset button (active low) |
| enterA | 74 | Player A button |
| enterB | 77 | Player B button |
| letterIn[2:0] | 71, 72, 73 | Letter selection switches |

### Output Pins
| Signal | Pin(s) | Description |
|--------|--------|-------------|
| led[7:0] | 51, 53, 54, 55, 56, 57, 68, 69 | Feedback LEDs |
| a_out to g_out | 42, 35, 34, 30, 29, 41, 40 | 7-segment lines |
| p_out | 33 | Decimal point |
| an[3:0] | 25, 26, 27, 28 | Digit select signals |

### Letter Encoding
| Switch Input | Binary | Letter |
|--------------|--------|--------|
| 0 | 000 | (blank) |
| 1 | 001 | A |
| 2 | 010 | C |
| 3 | 011 | E |
| 4 | 100 | F |
| 5 | 101 | H |
| 6 | 110 | L |
| 7 | 111 | U |

## Build Instructions

### Prerequisites
- Gowin EDA IDE (version 1.9.8 or later)
- Tang Nano 9K FPGA board
- USB-C cable for programming

### Steps
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/fpga-mastermind-game.git
   cd fpga-mastermind-game
   ```

2. Open Gowin EDA IDE

3. Create a new project:
   - Select device: GW1NR-LV9QN88PC6/I5
   - Add all `.v` files to the project
   - Add `tangnano9k.cst` as constraints file

4. Synthesize and implement the design:
   - Click "Synthesize"
   - Click "Place & Route"
   - Click "Generate Bitstream"

5. Program the FPGA:
   - Connect Tang Nano 9K via USB
   - Use "Programmer" tool
   - Select generated `.fs` file
   - Click "Program/Configure"

### Simulation (Optional)
Run the testbench for verification:
```bash
iverilog -o mastermind_sim mastermind_tb.v mastermind.v
vvp mastermind_sim
gtkwave mastermind_tb.vcd
```

## Module Architecture

### System Overview
```
top_module
├── clk_divider      (Clock division)
├── debouncer x2     (Button debouncing for A & B)
├── mastermind       (Main game logic FSM)
└── ssd              (7-segment display driver)
```

### Key Modules
- **mastermind.v**: Core game logic with 11-state FSM
- **top_module.v**: Top-level integration module
- **clk_divider.v**: Generates slower clock for game timing
- **debouncer.v**: Eliminates button bounce noise
- **ssd.v**: Multiplexed 7-segment display controller

### FSM States
1. ST_WAIT - Waiting for game start
2. ST_DISPLAY_SCORE - Show current scores
3. ST_DISPLAY_MAKER - Show current code maker
4. ST_INPUT_CODE - Code maker enters secret code
5. ST_DISPLAY_BREAK - Show code breaker
6. ST_DISPLAY_TRIES - Show remaining tries
7. ST_INPUT_GUESS - Code breaker enters guess
8. ST_CHECK_RESULT - Display feedback LEDs
9. ST_REVEAL_CODE - Show secret code (if breaker failed)
10. ST_ADD_POINTS - Update scores
11. ST_FINISH - Game over, show winner

## Features
- **11-State FSM**: Robust game flow control
- **Hardware Debouncing**: Clean button inputs using clock-based debouncer
- **Timer System**: Automatic state transitions with configurable delays
- **Smart Hint Logic**: Accurate feedback matching Mastermind rules
- **Score Tracking**: Automatic point management and role switching
- **Multiplexed Display**: Efficient 7-segment control for 4 digits

## My Contributions
- Designed and implemented the main FSM architecture
- Developed button debouncing logic for reliable input
- Created LED feedback system with hint calculation algorithm
- Integrated 7-segment display controller with multiplexing
- Debugged timing and synchronization issues
- Optimized state transitions and game flow

## Course Information
**CS303 – Logic and Digital System Design**
Sabanci University, Faculty of Engineering and Natural Sciences

## License
This project is an academic assignment. Feel free to reference it for educational purposes.
