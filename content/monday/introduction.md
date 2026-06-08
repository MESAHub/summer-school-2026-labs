+++
date = '2026-04-06T13:38:04+02:00'
draft = false
title = 'Outline'
+++


# Motivation

How old is a planetary system?

This seemingly simple question lies at the heart of modern exoplanet science. Planet ages are needed to understand planetary composition, atmospheric loss, habitability, migration histories, and the evolution of planetary populations. Yet planets rarely reveal their ages directly. Instead, we infer planetary ages from their host stars.

Stars evolve in predictable ways over time. Their rotation rates change, their colors and luminosities evolve, and their oscillation frequencies shift as their internal structures change. Each of these observables can therefore serve as a stellar clock.

Throughout the three labs, we will explore these widely used age-dating techniques:

1. Gyrochronology — using stellar rotation periods.
2. Isochrone fitting — using stellar colors and magnitudes.
3. Asteroseismology — using stellar oscillation frequencies.

We will use MESA to understand the underlying stellar physics and to build our own theoretical predictions.

# Lab 1: Gyrochronology 

Technical Goals

* Set up a MESA work directory
* Modify an inlist
* Set up PGPLOT
* Initialize and run stellar evolution models

Physics Concepts

* Angular momentum loss and magnetic braking
* Rossby number
* Angular momentum transport
* Solid-body rotation

Questions to Address

1. How effective is stellar rotation as an age indicator? Compare typical observational uncertainties in rotation periods (10%) with the dynamical range implied by your calculated gyrochrones.
2. Why can stellar rotation serve as a clock at all? What properties of the spin-down law make gyrochronology possible?


⸻

# Lab 2: Exploring MESA Colors

Technical Goals

* Use the MESA colors module
* Learn additional inlist controls
* Explore advanced PGPLOT diagnostics

Physics Concepts

* Atmospheric boundary conditions
* Mixing-length theory

Questions to Address

1. How effective are stellar colors and magnitudes as age indicators? Compare typical observational uncertainties with the dynamical range implied by your calculated isochrones.
2. How sensitive are your inferred ages to changes in model assumptions? Do theoretical uncertainties dominate over observational uncertainties?


⸻

# Lab 3: Asteroseismology

Technical Goals

* Use run_star_extras
* Explore additional inlist controls
* Develop custom PGPLOT diagnostics

Physics Concepts

* p-mode large frequency separation
* p-mode small frequency separation
* Oscillation amplitudes
* Detectability of oscillations with space-based photometric and ground-based radial-velocity observations

Questions to Address

1. How effective is asteroseismology as an age indicator? Compare typical observational uncertainties (∼1 μHz) with the dynamical range implied by your calculated seismic diagnostics and isochrones.
2. How sensitive are your inferred ages to changes in model assumptions? Do theoretical uncertainties dominate over observational uncertainties?
3. Can we detect oscillations for M dwarfs given the current instrument precision? Assume the precision for photometric observation is 60 ppm/hr, and that for RV is 30 cm/s/minute, and a cadence of 1 minute.


# Looking Ahead

By the end of these labs, you should be able to:

* Run and modify stellar evolution models with MESA.
* Understand the physical basis of several stellar age-dating techniques.
* Evaluate both observational and theoretical sources of uncertainty.
* Compare the strengths and limitations of different stellar clocks.

You should begin thinking like a stellar modeler: asking what age a method predicts, why it predicts that age, and how robust that prediction really is.

