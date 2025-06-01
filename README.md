# Sugar Centrifuge Controller 🚀

This project implements an automated control system for two sugar centrifuges (Big and Small) using a Siemens S7-1500 PLC. The system runs on a structured state machine with 7 operational stages, visualized on a TP700 Comfort HMI. It also includes a temperature safety check and configurable filling via sensor inputs.

---

## 🧩 Features

- 🚦 7-State Sequential Control (Idle, Filling, Acceleration, Running, Deceleration, Emptying, Cycle Check)
- 🔁 Independent control of two centrifuges (Big and Small)
- 🧠 Flexible filling control using sensors `I1` and `I3`
- 🌡️ Temperature monitoring with safety interlock (`Temp_Sensor`)
- 📊 HMI visualization with live state tracking and fault indicators
- 📝 Full LaTeX report and visualization screenshots included

---

## 📂 Project Structure
## 📋 Requirements

- Siemens TIA Portal (v16 or later)
- S7-1500 PLC (or simulation)
- TP700 Comfort HMI
- Git for version control

---

## ✅ Status

> ✅ Fully functional and tested in simulation  
> 🧪 Safe start/stop with temperature validation  
> 🔄 Two full operating cycles per centrifuge  

---

## 🛠️ How to Run

1. Clone this repository  
   `git clone https://github.com/Gabbzgreat/sugar-centrifuge-controller.git`

2. Open TIA Portal and load the project

3. Simulate or deploy on PLC + HMI setup

4. Watch the states, cycles, and temperature faults on HMI

