---
title: Physics Concepts
weight: 0
---

# Physics Concepts for Friday

Friday connects three levels of the same Cepheid problem:

1. **stellar evolution**: which models make blue loops and enter the instability strip?
2. **linear pulsation**: which radial modes are unstable, and what are their periods?
3. **nonlinear pulsation**: what finite-amplitude waveform does the star actually develop?

The labs are not three separate exercises. Lab 1 creates the stellar models, Lab 2 analyzes their linear pulsation properties, and Lab 3 asks what one selected model does after the pulsation grows to visible amplitude.

## Shared Technical Ideas

- **`.mod` files**: saved MESA stellar structures. Labs 2 and 3 use these. A `.mod` file is not the same thing as a restart photo.
- **`photos/` files**: MESA restart files. Use them to continue the same run with `./re`, not as general handoff models for the next lab.
- **history output**: the main place where Lab 1 writes evolutionary quantities and GYRE period/growth information.
- **PGSTAR**: the live diagnostic window. It is useful for HRD motion in Lab 1 and waveform shape in Lab 3.
- **current mass versus initial mass**: mass loss is on, so the model's current mass is not exactly the initial mass selected in Lab 1.
- **model number bookkeeping**: Lab 1 restarts append to `history.data`, so model numbers can be nonmonotonic in the history file. Lab 2 uses `initial_model_number` only to keep the RSP output matched to the selected Lab 1 model.

## Lab 1 - Evolution, Blue Loops, and GYRE in MESA

Lab 1 is about making the Cepheid candidates. The models are intermediate-mass, LMC-like stars with initial masses in the $3.9-9.4\,M_\odot$ range. During core helium burning, some of them execute blue loops that pass through the classical instability strip.

The main concepts are:

- **blue loop**: during core helium burning, the track can move back toward hotter effective temperature before returning redward.
- **instability strip**: the HRD region where radial modes can become overstable. The plotted edges are useful guides, not exact boundaries for every model or pulsation method.
- **input-physics sensitivity**: blue loops depend on metallicity, mass loss, convective boundary mixing, and other modeling choices. The Friday grid was chosen so the class gets useful loops.
- **why the star does not visibly pulsate in Lab 1**: MESA-star is taking evolutionary timesteps that are much longer than the pulsation period, so small dynamical perturbations are smoothed over.
- **GYRE in MESA**: GYRE is called during the Cepheid part of the evolution to compute radial-mode periods and growth rates without evolving full nonlinear pulsations.
- **linear growth rate**: positive growth means the mode is linearly unstable. It does not say what the final amplitude or light-curve shape will be.
- **saved models**: the `.mod` files saved during the dense GYRE-output region are the handoff models for Labs 2 and 3.

The key coding idea is that GYRE needs a model in its own format. Lab 1 asks students to connect the MESA structure data to GYRE using `set_model`; without that call, GYRE has no model to analyze and the run stops.

## Lab 2 - GYRE versus RSP-LNA

Lab 2 is about linear radial pulsation. It compares the GYRE results saved in Lab 1 with RSP's linear nonadiabatic mode calculation.

The main concepts are:

- **linear nonadiabatic analysis (LNA)**: the mode amplitudes are assumed small, but the calculation keeps thermal driving and damping. LNA gives periods and growth rates, not final amplitudes.
- **fundamental mode first**: the main comparison is the radial fundamental mode. In the Lab 1 GYRE output this is the fundamental radial mode, and in RSP it is mode `0`.
- **first and second overtones**: useful for context and for the Lab 3 resonance picture, but not the main Lab 2 deliverable.
- **frozen convection in GYRE**: the Lab 1 GYRE setup neglects perturbations to the convective flux. This is a reasonable approximation when convection is weakly coupled to the pulsation, but it becomes less reliable near the red edge.
- **RSP envelope model**: RSP does not load the full `.mod` structure in the same way GYRE does. It builds a static envelope from mass, luminosity, effective temperature, and composition.
- **RSP boundary conditions**: the RSP envelope has its own surface optical depth, outer boundary condition, zoning choices, and convection/pulsation parameters.
- **eddy-viscous damping**: RSP includes eddy-viscous damping through `RSP_alfam`; the Lab 1 GYRE calculation does not. Setting `RSP_alfam = 0d0` would likely widen the RSP instability strip, but the envelope and boundary-condition differences would still remain.
- **period comparison**: GYRE and RSP periods are expected to be broadly similar, but they need not match exactly for the same saved model.
- **growth-rate comparison**: growth rates are more sensitive to convection treatment and are expected to disagree more often than periods.
- **Wesenheit index**: a reddening-reduced period-luminosity-color quantity. Lab 2 uses the RSP color output to build a tighter period-Wesenheit relation in addition to the simpler period-luminosity relation.

Two fallback lists appear in Lab 2:

- **Table 1**: one RSP-positive model per available mass for finishing the main Lab 2 RSP-LNA exercise.
- **Table 2**: redder selected models for Lab 3. These are chosen for the nonlinear sample, not because RSP says every one is unstable.

That difference is intentional. Near the red edge, GYRE and RSP can classify the same saved model differently. That does not mean the table is broken; it is a concrete example of how different linear tools define slightly different instability strips.

## Lab 3 - Nonlinear TDC and the Hertzsprung Progression

Lab 3 asks what happens after a pulsation grows to finite amplitude. Linear analysis tells us which modes can grow, but it cannot produce a light curve, radius curve, velocity curve, bump morphology, or saturation amplitude.

The main concepts are:

- **TDC pulsation**: MESA-star is run with time-dependent convection and hydrodynamics so the envelope can develop a finite-amplitude radial pulsation.
- **GYRE kick**: the run is initialized with the GYRE eigenfunction of the fundamental radial mode, scaled to a chosen surface velocity. This makes the model pulsate on lab timescales.
- **kick amplitude**: for a production calculation, a smaller kick and longer run are safer. In the lab, a larger kick is acceptable because the goal is to develop a classifiable waveform quickly.
- **mode-selection choice**: seeding the fundamental mode is not neutral. It intentionally biases the run toward the fundamental-mode Hertzsprung progression.
- **finite-amplitude pulsation**: the pulsation has grown enough that its waveform, amplitude, radius variation, and velocity structure can be inspected directly.
- **science-quality limit cycle**: a stable single-mode limit cycle means the transient has died away, the period is stable, the cycle-to-cycle amplitudes are stationary, and `growth` or `KE_growth_avg` is close to zero on average.
- **lab-quality waveform**: for Lab 3, the run only needs to be developed enough to classify the bump. Positive growth means the mode is still growing; it does not by itself mean the model has reached a limit cycle.
- **bump Cepheid**: a Cepheid whose light, radius, or velocity curve contains a secondary feature, or bump, near the main pulsation cycle.
- **Hertzsprung progression**: as period changes, the bump moves from the descending branch, through the middle of the cycle, and onto the rising branch.
- **second-overtone resonance picture**: the clean single-mode interpretation links the bump progression to a near `2:1` resonance between the second overtone and fundamental mode, so $P_2/P_0 \approx 0.5$ is a useful guide.
- **red-edge selection**: the Lab 3 starting models are chosen about 10-30% in from the red edge. This helps favor fundamental-mode nonlinear behavior without sitting exactly on the edge of stability.

The limit-cycle language is not universal. OGLE includes classical Cepheids that pulsate in fundamental, first-overtone, second-overtone, double-mode, and triple-mode states, and nearby Cepheid-like variables can show period-doubled or irregular behavior. In model language, this is the broader problem of nonlinear mode selection: linear growth rates say which modes can grow, while nonlinear saturation and mode coupling decide what finite-amplitude state survives.

For the Friday lab, we deliberately focus on the stable single-mode fundamental case because it is the cleanest way to connect MESA outputs to the Hertzsprung progression.
