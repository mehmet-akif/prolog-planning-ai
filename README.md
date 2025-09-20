# Prolog AI Planning – Dishwashing & RoboCup

## Overview

This project implements **two classical AI planning problems** in **Prolog**:  
1. **Dishwashing Robot** – a household robot that washes dirty dishes.  
2. **RoboCup Soccer** – robots moving, passing, and shooting on a grid to score goals.  

Both systems are built with **successor-state axioms, action preconditions, and declarative heuristics** to enable efficient planning. A generic planner (`planner.pl`) is used to simulate plans and compute optimal strategies.

This project showcases practical applications of **logic programming and planning in AI**.

---

## Table of Contents
- [Project Description](#project-description)
- [Results](#results)
- [Technologies Used](#technologies-used)
- [Usage](#usage)

---

## Project Description

- **Dishwashing Planner**  
  - Models actions: picking up, putting down, turning faucet on/off, adding soap, scrubbing, and rinsing.  
  - Includes constraints: max 2 items held, glasses need brush, plates need sponge.  
  - Implements declarative heuristics to prune useless sequences like “rinse without soap.”  

- **RoboCup Soccer Planner**  
  - Models a grid world with robots, teammates, and opponents.  
  - Actions include: moving, passing, and shooting.  
  - Successor-state axioms update robot locations, ball possession, and scoring.  
  - Declarative heuristics avoid redundant passes, back-and-forth moves, and non-optimal plays.  

---

## Results

### Dishwashing
- **Simple goals (11, 12, 13):** Solved instantly (<1s).  
- **Goal 14:** Regular mode took 36.27s; heuristic mode reduced to 4.97s.  
- **Goal 15:** Reduced from 107.47s to ~4.97s using heuristics.  
- **Goal 21:** Ran in 1.92s regular vs. 0.54s heuristic.  
- **Complex goals (22, 31):** Still required very long runtimes (22–38 minutes), showing limits of current heuristics:contentReference[oaicite:0]{index=0}.

### RoboCup
- **Simple goals (11–13):** Executed instantly (<0.1s).  
- **Goal 14:** Improved from 0.20s to 0.11s with heuristics.  
- **Goal 15:** Reduced from 4.49s to 1.31s.  
- **Goal 21:** Runtime dropped from 0.22s to 0.11s with heuristics.  
- Complex goal states showed noticeable planning speedups but highlighted need for more sophisticated pruning:contentReference[oaicite:1]{index=1}.

---

## Technologies Used

- **Language**: Prolog (tested with SWI-Prolog and ECLiPSe Prolog 6).  
- **Core AI Concepts**:
  - Successor-State Axioms  
  - Action Precondition Axioms  
  - Declarative Heuristics (`useless/2`)  
  - STRIPS-like Planning Representation  
- **Generic Planner**: Provided in `planner.pl`.  

---

## Usage

1. **Install Prolog**  
   - Use [SWI-Prolog](https://www.swi-prolog.org/) or ECLiPSe Prolog 6.

2. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/prolog-planning-ai.git


