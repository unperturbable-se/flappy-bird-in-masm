# 🐦 Flappy Bird in MASM (Irvine32)

A simple **Flappy Bird–style game** written in **x86 Assembly** using **MASM** and the **Irvine32 library**.

This project serves as an educational exercise for learning:
* **Low-level programming**
* **Console animation**
* **Interactive console graphics**

---

## ✨ Features (Planned)

The goal is to implement the core mechanics of the classic game:

* **Simple Bird Character:** The bird moves upward when a key is pressed.
* **Gravity Simulation:** The bird is continuously pulled downward.
* **Pipes/Obstacles:** Obstacles that scroll horizontally across the screen.
* **Collision Detection:** Logic to detect when the bird hits the ground or an obstacle.
* **Score Counter:** Tracking the player's score.
* **Basic Console Graphics:** Using **Irvine32** procedures for colored console output.

---

## 🛠️ Tools / Requirements

To build and run this project, you will need:

* **MASM** (`ml.exe`)
* The **Irvine32 Library** (specifically `Irvine32.inc` and `Irvine32.lib`)
* A **32-bit Windows environment** or a Visual Studio setup configured to support MASM.
* The standard **Windows console** (used for rendering the game).
