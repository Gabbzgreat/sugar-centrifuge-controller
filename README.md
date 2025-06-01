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

