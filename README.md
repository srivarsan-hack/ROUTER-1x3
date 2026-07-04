# 🚀 Router 1×3 RTL Design using Verilog HDL

A fully synthesizable **1×3 Router** implemented in **Verilog HDL** that routes packets from a single input port to one of three output ports based on the destination address. The design uses a **Finite State Machine (FSM)**, **FIFO buffers**, **synchronization logic**, and **parity-based error detection** to ensure reliable packet transmission.

---

# 📌 Project Overview

The Router 1×3 is a packet-switching digital system designed using Verilog HDL. It accepts data packets from a single source, decodes the destination address embedded in the packet header, and forwards the packet to one of three destination FIFOs.

Each output port has an independent FIFO, allowing data buffering and asynchronous packet retrieval. The design also includes parity generation and checking to detect transmission errors.

This project demonstrates important RTL design concepts commonly used in FPGA and ASIC development.

---

# 🏗️ Router Architecture

<p align="center">
  <img src="images/architecture.png" width="900">
</p>

The router is divided into five major RTL modules:

```
                 +------------------+
                 |    Router Top    |
                 +------------------+
                          │
      ┌──────────┬────────┼──────────┬──────────┐
      │          │        │          │
      ▼          ▼        ▼          ▼
+-----------+ +---------+ +-------+ +-------+
| Router    | | Router  | | FIFO0 | | FIFO1 |
| FSM       | | Register| +-------+ +-------+
+-----------+ +---------+       │
        │            │          ▼
        └──────┬─────┘      +-------+
               ▼            | FIFO2 |
         +-------------+    +-------+
         |Synchronizer |
         +-------------+
```

---

# 📂 RTL Modules

## 🔹 Router Top

The top module integrates all internal blocks and provides the interface between the source and destination networks.

### Responsibilities

- Instantiates all RTL modules
- Connects FSM, Register, Synchronizer and FIFOs
- Controls complete packet routing operation

---

## 🔹 Router FSM

The FSM controls every stage of packet processing.

### Functions

- Packet reception
- Header detection
- Payload transfer
- FIFO write control
- Busy signal generation
- Parity checking
- Packet completion

---

## 🔹 Router Register

The Register module temporarily stores incoming packet data and performs parity calculations.

### Functions

- Header storage
- Payload buffering
- Internal parity generation
- Received parity comparison
- Error generation

---

## 🔹 Synchronizer

The Synchronizer determines which FIFO should receive the packet.

### Functions

- Destination address decoding
- FIFO selection
- FIFO full detection
- Write enable generation
- Soft reset control

---

## 🔹 FIFO Buffers

Three independent FIFOs temporarily store packets before being read by the destination.

### Features

- Packet buffering
- Independent read operation
- Full flag
- Empty flag
- Synchronous operation

---

# ✨ Features

- ✅ Fully Synthesizable RTL
- ✅ Verilog HDL Implementation
- ✅ 8-bit Packet Interface
- ✅ Single Input, Three Outputs
- ✅ FSM Based Control
- ✅ Three Independent FIFOs
- ✅ Packet Routing
- ✅ Busy Signal Flow Control
- ✅ Packet Valid Indication
- ✅ Parity Generation
- ✅ Error Detection
- ✅ Modular RTL Design
- ✅ Functional Verification using Testbench

---

# 📦 Packet Format

Each packet consists of three parts.

| Field | Size |
|--------|------|
| Header | 8 Bits |
| Payload | 1–63 Bytes |
| Parity | 8 Bits |

---

## Header Format

| Bits | Description |
|------|-------------|
| [7:2] | Payload Length |
| [1:0] | Destination Address |

### Destination Address

| Address | FIFO |
|----------|------|
| 00 | FIFO 0 |
| 01 | FIFO 1 |
| 10 | FIFO 2 |
| 11 | Invalid Address |

---

# 🔌 Top Module Interface

## Inputs

| Signal | Width | Description |
|---------|------|-------------|
| clock | 1 | System Clock |
| resetn | 1 | Active Low Reset |
| pkt_valid | 1 | Packet Valid Signal |
| data_in | 8 | Input Packet |
| read_enb_0 | 1 | FIFO0 Read Enable |
| read_enb_1 | 1 | FIFO1 Read Enable |
| read_enb_2 | 1 | FIFO2 Read Enable |

---

## Outputs

| Signal | Width | Description |
|---------|------|-------------|
| data_out_0 | 8 | FIFO0 Output |
| data_out_1 | 8 | FIFO1 Output |
| data_out_2 | 8 | FIFO2 Output |
| valid_out_0 | 1 | FIFO0 Valid |
| valid_out_1 | 1 | FIFO1 Valid |
| valid_out_2 | 1 | FIFO2 Valid |
| busy | 1 | Router Busy |
| error | 1 | Parity Error |

---

# ⚙️ Working Principle

### Step 1 : Packet Reception

The source transmits one byte during every clock cycle.

```
Header → Payload → Parity
```

The **pkt_valid** signal remains HIGH while transmitting the header and payload.

During parity transmission,

```
pkt_valid = 0
```

---

### Step 2 : Destination Decoding

The router extracts the destination address from the packet header.

```
00 → FIFO0
01 → FIFO1
10 → FIFO2
```

The Synchronizer activates the corresponding FIFO.

---

### Step 3 : Packet Storage

Incoming payload bytes are written into the selected FIFO.

If the FIFO becomes full,

```
busy = 1
```

The source pauses transmission until space becomes available.

---

### Step 4 : Packet Read

When a destination detects

```
valid_out = 1
```

it enables

```
read_enb
```

to retrieve packet data.

---

### Step 5 : Error Detection

The Register module calculates packet parity.

```
Received Parity
        ==
Calculated Parity
```

If both values match,

```
Packet Accepted
```

Otherwise,

```
error = 1
```

---

# 🧪 RTL Module Verification

| Module | Verification |
|----------|--------------|
| Router Top | ✅ Passed |
| FSM | ✅ Passed |
| Register | ✅ Passed |
| Synchronizer | ✅ Passed |
| FIFO | ✅ Passed |

---

# 📊 Simulation Results

## Top Module

The complete router was verified using a Verilog testbench. The waveform confirms successful packet transmission, destination routing, FIFO operations, and parity verification.

<p align="center">
<img src="images/top.jpg" width="1000">
</p>

---

## FSM Verification

The waveform verifies state transitions, packet loading, FIFO control, and busy signal generation.

<p align="center">
<img src="images/FSM.jpg" width="1000">
</p>

Verified:

- State transitions
- FIFO control
- Busy handling
- Packet completion

---

## Register Verification

The Register module successfully captures packet data and performs parity generation and verification.

<p align="center">
<img src="images/REG.jpg" width="1000">
</p>

Verified:

- Header storage
- Payload storage
- Parity calculation
- Error detection

---

## Synchronizer Verification

The Synchronizer correctly decodes destination addresses and enables the appropriate FIFO.

<p align="center">
<img src="images/SYN.jpg" width="1000">
</p>

Verified:

- Address decoding
- FIFO selection
- Write enable generation
- FIFO full detection

---

## FIFO Verification

The FIFO waveform confirms successful write, read, full, and empty operations.

<p align="center">
<img src="images/FIFO.jpg" width="1000">
</p>

Verified:

- Data buffering
- Read operation
- Write operation
- Empty flag
- Full flag

---

# 🛠️ Tools Used

- Verilog HDL
- ModelSim
- Xilinx Vivado
- Git
- GitHub

---

# 📁 Repository Structure

```
Router_1x3/
│
├── RTL/
│   ├── router_top.v
│   ├── router_fsm.v
│   ├── router_fifo.v
│   ├── router_register.v
│   └── router_sync.v
│
├── Testbench/
│   └── router_tb.v
│
├── Images/
│   ├── architecture.png
│   ├── top.jpg
│   ├── FSM.jpg
│   ├── REG.jpg
│   ├── SYN.jpg
│   └── FIFO.jpg
│
├── README.md
│
└── LICENSE
```

---

# 🎯 Applications

- Network-on-Chip (NoC)
- Packet Switching Systems
- FPGA Communication
- Digital Communication Systems
- ASIC Front-End Design
- RTL Design Practice
- VLSI Education

---

# 📈 Future Improvements

- Support 1×4 and 1×8 Router Architectures
- CRC-based Error Detection
- AXI-Stream Interface
- FPGA Hardware Implementation
- Throughput Optimization
- UVM-Based Verification

---

# 📚 Learning Outcomes

Through this project, I gained practical experience in:

- RTL Design using Verilog HDL
- Finite State Machine (FSM) Design
- FIFO Architecture
- Packet Routing
- Functional Verification
- Digital System Design
- FPGA/ASIC Design Flow
- Modular Hardware Design

---

# 👨‍💻 Author

## **Srivarsan N**

Electronics Engineering Student

### Areas of Interest

- RTL Design
- FPGA Design
- VLSI
- Digital Electronics
- Embedded Systems
- ASIC Front-End Design

---

## ⭐ Support

If you found this project useful, consider giving it a **⭐ Star** on GitHub.

Thank you for visiting this repository!
