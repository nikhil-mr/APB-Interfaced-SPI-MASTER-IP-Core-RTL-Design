# APB Interfaced SPI Master IP Core

## Overview

This project implements an **APB Interfaced SPI Master IP Core** using **Verilog HDL**.

The design combines an **AMBA APB slave interface** with an **SPI Master controller**, allowing an APB master to configure the SPI peripheral, write transmit data, initiate SPI transfers, monitor SPI status, and read received data.

The IP core is designed using a modular RTL architecture consisting of four main functional blocks:

- APB Slave Interface
- Baud Rate Generator
- Shift Register
- SPI Slave Select Control

The design is developed at the RTL level and verified using a Verilog testbench and ModelSim simulation.

---

## Objectives

The main objective of this project is to design and implement a configurable SPI Master IP Core that can be controlled through an APB interface.

The design provides:

- APB-based register access
- SPI Master functionality
- Programmable SPI clock generation
- Configurable Clock Polarity (CPOL)
- Configurable Clock Phase (CPHA)
- MSB-first and LSB-first data transfer
- 8-bit serial data transmission and reception
- Automatic SPI Slave Select (`SS`) control
- SPI transfer status monitoring
- Receive data storage
- Interrupt request generation
- Modular RTL architecture
- Simulation-based functional verification

---

# System Architecture

The complete IP consists of four major RTL blocks.

```text
                         APB MASTER
                             |
                             |
                    +-------------------+
                    | APB Slave         |
                    | Interface         |
                    +-------------------+
                       |       |      |
                       |       |      |
                 Config.    TX Data   RX Data
                       |       |      |
                       v       v      ^
              +--------------------------+
              | Baud Rate Generator      |
              +--------------------------+
                       |
                      SCLK
                       |
                       v
              +--------------------------+
              | Shift Register           |
              |                          |
              | MOSI              MISO   |
              +--------------------------+
                       |
                       |
              +--------------------------+
              | SPI Slave Select        |
              | Control                  |
              +--------------------------+
                       |
                      SS
