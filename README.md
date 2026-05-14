# 5-Stage Pipelined Processor (Von Neumann Architecture)

A high-performance 8-bit pipelined processor designed in Verilog HDL, featuring a classic 5-stage pipeline and advanced hardware units to resolve pipeline hazards.

---

## 📌 Project Overview
This project implements a complete RISC-based processor with a **5-stage pipeline** (IF, ID, EX, MEM, WB). The design focuses on maximizing throughput while maintaining data integrity through sophisticated **Hazard Detection** and **Forwarding** mechanisms. It is built using a unified **Von Neumann architecture**, where instructions and data share the same memory space.

---

## 🏗️ Processor Architecture

The processor is divided into five distinct stages to enable instruction-level parallelism:

1.  **Instruction Fetch (IF):** Fetches the 16-bit instruction from memory and manages the Program Counter (PC).
2.  **Instruction Decode (ID):** Decodes instructions, generates control signals, and manages the Register File (8 general-purpose registers).
3.  **Execute (EX):** Performs arithmetic and logic operations using a versatile ALU.
4.  **Memory Access (MEM):** Handles Load/Store operations to the Data Memory.
5.  **Write Back (WB):** Writes the results back to the Register File.

---

## 🚀 Advanced Features & Hazard Management

To ensure smooth execution and handle pipeline dependencies, I implemented:

* [cite_start]**Forwarding Unit:** Resolves **Data Hazards** by passing the execution result directly from the EX/MEM or MEM/WB pipeline registers to the ALU inputs, eliminating the need for stalls in most cases[cite: 34].
* [cite_start]**Hazard Detection Unit:** Automatically detects **Load-Use hazards** and control dependencies, inserting "Bubbles" (Stalls) when necessary to maintain architectural state[cite: 34].
* [cite_start]**Control Flow Management:** Includes a dedicated **Jump Unit** to handle Branches, Jumps, Stack operations (Push/Pop), and Interrupts with minimal performance impact[cite: 34].
* **Stack Support:** Built-in hardware support for subroutines and interrupt service routines via a Stack Pointer (SP).

---

## 🛠️ Instruction Set Architecture (ISA)
The processor supports a comprehensive set of 8-bit instructions, including:
* **Arithmetic/Logic:** ADD, SUB, AND, OR, NOT.
* **Memory Operations:** MOV, PUSH, POP, IN, OUT.
* **Control Flow:** JMP, JZ, JC, CALL, RET, INT, RTI.
* **Special:** NOP, SETC, CLRC.

---

## 💻 Technical Implementation
* [cite_start]**Language:** Verilog HDL[cite: 33].
* **Methodology:** Structural and Behavioral modeling.
* **Tools:** Siemens EDA's Questa Sim / ModelSim for functional simulation.
* [cite_start]**Architecture:** Von Neumann (Unified Instruction/Data Memory)[cite: 33].

---

## 📂 Project Structure
```text
├── RTL/
│   ├── processor_top.v      # Top-level module
│   ├── alu.v                # Arithmetic Logic Unit
│   ├── register_file.v      # 8x8 Register file
│   ├── control_unit.v       # Main control logic
│   ├── hazard_unit.v        # Hazard detection & Forwarding
│   └── memory.v             # Unified memory module
├── Simulation/
│   └── tb_processor.v       # Comprehensive testbench
└── Docs/
    └── 5-STAGE_PIPELINED_PROCESSOR.pdf  # Technical Report
