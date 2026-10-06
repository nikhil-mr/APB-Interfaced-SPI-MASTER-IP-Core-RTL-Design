# APB Interfaced SPI Master IP Core

## Overview

This project implements an **APB Interfaced SPI Master IP Core** using **Verilog HDL**.

The design combines an **AMBA APB slave interface** with an **SPI Master controller**. An APB master can configure the SPI controller through memory-mapped registers, write transmit data, initiate SPI transfers, monitor SPI status, and read received SPI data.

The design is implemented as a modular RTL architecture consisting of four major functional blocks:

1. **APB Slave Interface**
2. **Baud Rate Generator**
3. **Shift Register**
4. **SPI Slave Select Control**

The complete design is integrated through a `Top_Block` module and is verified using a Verilog testbench and ModelSim simulation.

---

# Objectives

The main objective of this project is to design and implement a configurable **SPI Master IP Core with an APB interface**.

The design provides:

- APB-based register access
- SPI Master functionality
- Programmable SPI clock generation
- Configurable Clock Polarity (`CPOL`)
- Configurable Clock Phase (`CPHA`)
- MSB-first data transfer
- LSB-first data transfer
- 8-bit SPI data transmission
- 8-bit SPI data reception
- Automatic SPI Slave Select (`SS`) control
- SPI transfer status monitoring
- Receive data storage
- Interrupt request generation
- Modular RTL architecture
- Simulation-based verification

---

# Block Diagram

The APB Interfaced SPI Master IP Core is implemented as a modular RTL design consisting of four major blocks integrated inside the `Top_Block`.

```text
                                      APB INTERFACED SPI MASTER IP CORE
                                               (Top_Block)
┌───────────────────────┐
│                       │
│       APB MASTER      │
│                       │
│  pclk                 │
│  preset_n             │
│  paddr[2:0]           │
│  pwrite               │
│  psel                 │
│  penable              │
│  pwdata[7:0]          │
│                       │
└───────────┬───────────┘
            │
            │ APB CONTROL / DATA
            │
            ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                         APB SLAVE INTERFACE (B1)                             │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                         APB FSM                                         │  │
│  │                                                                        │  │
│  │                  IDLE → SETUP → ENABLE                                 │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌────────────────────── REGISTER FILE ───────────────────────────────────┐  │
│  │                                                                        │  │
│  │  SPICR1    SPI Control Register 1                                    │  │
│  │  SPICR2    SPI Control Register 2                                    │  │
│  │  SPIBR     SPI Baud Rate Register                                    │  │
│  │  SPISR     SPI Status Register                                       │  │
│  │  SPIDR     SPI Data Register                                         │  │
│  │                                                                        │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  Generates:                                                                  │
│    mstr, cpol, cpha, lsbfe, spiswai                                        │
│    sppr[2:0], spr[2:0]                                                      │
│    spi_mode[1:0]                                                            │
│    send_data                                                                │
│    data_mosi[7:0]                                                           │
│                                                                              │
│  Receives:                                                                   │
│    data_miso[7:0], receive_data, ss, tip                                   │
│                                                                              │
└───────────────┬───────────────────────┬───────────────────────┬──────────────┘
                │                       │                       │
                │ Configuration        │ TX Data               │ RX Data
                │                       │                       │
                ▼                       ▼                       ▲
┌─────────────────────────────┐   ┌────────────────────────────────────────────┐
│                             │   │                                            │
│   BAUD RATE GENERATOR (B2)  │   │           SHIFT REGISTER (B3)              │
│                             │   │                                            │
│  Inputs:                    │   │  Inputs:                                   │
│  • spi_mode                 │   │  • data_mosi[7:0]                          │
│  • spiswai                  │   │  • send_data                               │
│  • sppr[2:0]                │   │  • miso                                    │
│  • spr[2:0]                 │   │  • lsbfe                                   │
│  • cpol                     │   │  • cpha                                    │
│  • cpha                     │   │  • cpol                                    │
│  • ss                       │   │  • mrs0, mrs1                              │
│                             │   │  • mss0, mss1                              │
│  ┌─────────────────────────┐ │   │                                            │
│  │ Baud Rate Calculation   │ │   │  ┌────────────────────────────────────┐  │
│  │                         │ │   │  │      TRANSMIT SHIFT REGISTER       │  │
│  │ (SPPR + 1) ×            │ │   │  │                                    │  │
│  │ 2^(SPR + 1)             │ │   │  │ data_mosi → shift_reg → MOSI       │  │
│  └─────────────────────────┘ │   │  │                                    │  │
│              │                │   │  └────────────────────────────────────┘  │
│              ▼                │   │                                            │
│  baudratedivisor[11:0]       │   │  ┌────────────────────────────────────┐  │
│              │                │   │  │       RECEIVE SHIFT REGISTER       │  │
│              ▼                │   │  │                                    │  │
│       SCLK GENERATION        │   │  │ MISO → temp_reg → data_miso[7:0]   │  │
│              │                │   │  │                                    │  │
│              ▼                │   │  └────────────────────────────────────┘  │
│       sclk                   │   │                                            │
│                              │   │  Timing Control:                           │
│       Timing Signals         │   │  • MRS0 / MRS1 → MISO sampling             │
│       • mrs0                 │   │  • MSS0 / MSS1 → MOSI shifting             │
│       • mrs1                 │   │                                            │
│       • mss0                 │   │  Outputs:                                  │
│       • mss1                 │   │  • mosi                                    │
│                              │   │  • data_miso[7:0]                          │
└──────────────┬───────────────┘   └───────────────┬────────────────────────────┘
               │                                   │
               │ sclk                              │ mosi / miso
               │                                   │
               ▼                                   ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                         SPI SLAVE SELECT CONTROL (B4)                       │
│                                                                              │
│  Inputs:                                                                     │
│  • mstr                                                                       │
│  • spiswai                                                                    │
│  • spi_mode[1:0]                                                             │
│  • send_data                                                                 │
│  • baudratedivisor[11:0]                                                     │
│                                                                              │
│  Functions:                                                                  │
│  • Starts SPI transfer                                                       │
│  • Controls SS                                                                │
│  • Maintains SS during transfer                                             │
│  • Counts SPI transfer duration                                             │
│  • Generates receive_data                                                     │
│  • Generates TIP status                                                       │
│                                                                              │
│                       ┌─────────────────────┐                                │
│                       │ Transfer Control    │                                │
│                       │      Counter        │                                │
│                       └──────────┬──────────┘                                │
│                                  │                                           │
│                                  ▼                                           │
│                              SS CONTROL                                      │
│                                  │                                           │
│                                  ▼                                           │
│                                ss                                           │
│                                                                              │
│                              tip = ~ss                                       │
│                                                                              │
└───────────────────────────────────────┬──────────────────────────────────────┘
                                        │
                                        │ SS
                                        ▼

                              ┌─────────────────────┐
                              │                     │
                              │     SPI SLAVE       │
                              │   (External Device) │
                              │                     │
                              │       SCLK  ◄──────┼──── sclk
                              │       MOSI  ◄──────┼──── mosi
                              │       MISO  ───────►┼──── miso
                              │       SS    ◄──────┼──── ss
                              │                     │
                              └─────────────────────┘
