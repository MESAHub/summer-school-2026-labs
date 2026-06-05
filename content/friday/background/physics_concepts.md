---
title: Physics Concepts
weight: 0
---

# Physics Concepts for Friday

**Bonus technical concepts**

- running GYRE in MESA-star during evolution
- saving and reusing `.mod` files
- using PGSTAR to follow the model during evolution and pulsation runs
- running MESA-star in hydro mode
- using a GYRE kick to seed pulsation
- seeing the difference between linear instability and finite-amplitude pulsation
- reading physical information from the shape of a nonlinear light curve

## Lab 1 - Evolving a Cepheid into the Instability Strip

Lab 1 is about how a classical Cepheid model is produced in the first place. In this lab the relevant stars are in the $3$-$8\,M_\odot$ range. During core helium burning these stars can execute a blue loop. If the loop reaches the classical instability strip, the model becomes a Cepheid candidate.

The main concepts for Lab 1 are:

- **blue loop**: the track moves back to higher effective temperature during core helium burning
- **instability-strip crossing**: the model only becomes a classical Cepheid if it reaches the strip
- **mass dependence**: different masses do not cross the strip in the same way, which is why the class spreads the grid across multiple masses

Lab 1 also produces the inputs for Lab 2. The modified `run_star_extras` runs GYRE in MESA during helium burning and saves `.mod` files while the star is in the Cepheid phase.

## Lab 2 - Linear Analysis in GYRE vs LNA (from RSP)

Lab 2 is about linear radial pulsation. It extends the Lab 1 model directory and also uses the `rsp_Cepheid_LNA` directory. The point is to compare the fundamental radial mode from the GYRE-in-MESA runs against RSP-LNA using the same saved stellar structures.

The main concepts for Lab 2 are:

- **fundamental radial mode first**: the main comparison should start with the radial fundamental `l = 0` mode, `P0`, and any radial overtone work such as `P1` or `P2` is extra
- **growth rates**: positive growth means a mode is linearly unstable, and growth rates are one place where the two linear calculations may differ
- **frozen convection in GYRE**: GYRE drops the perturbation to convective flux in the thermal part of the linear equations, so convection-pulsation coupling is simplified
- **GYRE vs RSP-LNA**: periods may agree reasonably well while growth rates can disagree, especially once convection becomes important
- **blue edge versus red edge**: agreement should be better toward the blue edge and worse toward the red edge
- **period-luminosity relation**: once the class has periods and luminosities, it can build a `log P` versus `log L` relation in Google Sheets

An extra step in this lab is to use the colors module and build a Wesenheit-based relation.

## Lab 3 - The Hertzsprung Progression

Lab 3 is about what changes once the pulsation reaches finite amplitude. A few nonlinear fundamental mode Cepheid models are enough to show the bump progression and connect it to the Hertzsprung progression.

The main concepts for Lab 3 are:

- **finite amplitude pulsation**: linear analysis tells you whether a mode grows, but not the final light-curve shape
- **hydro mode**: this is only used as much as needed to evolve the nonlinear models
- **GYRE kick**: the kick is used to seed pulsation in the model
- **bump Cepheids**: the light curve can show a secondary bump
- **P2/P0 resonance picture**: the bump morphology is usually linked to a near `2:1` resonance between the second overtone and the fundamental mode
- **Hertzsprung progression**: the bump shifts from the descending branch, through the middle, and onto the rising branch as period changes
- **fundamental mode focus**: the main Lab 3 targets are fundamental mode bump Cepheids, with radial overtone cases only as extra cases if they appear

The goal is to inspect a few nonlinear models, identify where the bump is, and reconstruct the progression as a class.
