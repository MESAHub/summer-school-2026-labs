---
weight: 4
title: Lab 3 - The Hertzsprung Progression
linkTitle: Lab 3
---

Lab 3 is the nonlinear lab for Friday. We only need a small number of models here. The point is to kick a few fundamental mode Cepheid models to finite amplitude, inspect the waveform, and track the bump progression across period.

Distant Cepheid observations are often sparse enough that template-based fitting has to do a lot of the work. In the bump-Cepheid period range, it is not always clear whether those analyses are really fitting the bump itself or fitting a smoother template across it, and that may affect the derived mean magnitudes when the data are limited. So Lab 3 gives some direct science background for how light-curve shape can matter in Cepheid distance work.

The usual interpretation is that the bump morphology is tied to a near `2:1` resonance between the second overtone and the fundamental mode, so the key quantity is $P_2/P_0 \approx 0.5$. As the stellar structure changes across the strip, that resonance shifts and the bump moves from the descending branch, through the middle, and onto the rising branch.

## Directory

`content/friday/MESA_models/lab3_Hertzsprung_progression/TDC_Cepheid/`

## Goal

- run a few nonlinear fundamental mode Cepheid models
- use hydro mode only as much as needed for the nonlinear part
- use a GYRE kick to seed pulsation
- identify bump Cepheids and reconstruct the Hertzsprung progression
- connect the bump progression to the $P_2/P_0$ resonance picture
- treat any radial overtone cases as an extra, not the main target

## What Students Do

1. Start from one or two fundamental mode Cepheid models prepared from the earlier labs.
2. Use the `TDC_Cepheid` setup to remesh, kick the model, and evolve it to finite amplitude.
3. Inspect the light, radius, and velocity curves.
4. Record where the bump appears: descending branch, middle, or rising branch.
5. Add the result to a shared Google Sheet so the class can reconstruct the bump progression.
6. If any unstable radial overtone `l = 0` cases appear in the broader sample, such as `P1` or `P2`, treat them as extra comparison cases rather than the main sequence.

```bash
cd content/friday/MESA_models/lab3_Hertzsprung_progression/TDC_Cepheid
./mk
./rn
```

> [!IMPORTANT]
> This is the only lab where the hydro pieces really matter. Keep the scope small. The goal is not to teach all of nonlinear pulsation theory, but to get enough nonlinear models to see the bump progression clearly.

> [!NOTE]
> In this setup, the model is kicked with GYRE in MESA and then followed in hydro mode toward finite-amplitude pulsation.

## What the Class Should Produce

- a small set of nonlinear Cepheid light curves
- a shared table marking the bump location for each model
- a class bump-progression sequence
- an optional note on any radial overtone comparison cases

## TA Prep

- choose a small number of models that are likely to show the bump clearly
- make sure the class knows exactly how bump location will be classified
- keep the Google Sheet focused on period and bump location
- use PGSTAR and the work/history output to decide which runs are worth discussing live
- remind the class that bump morphology is also part of the observational Cepheid light-curve problem when the data are sparse
- keep the resonance explanation simple: the bump is usually linked to the second-overtone to fundamental resonance when $P_2/P_0$ is near $0.5$
- keep the main target on fundamental mode bump Cepheids and leave any radial overtone cases as optional extras

{{< details title="TA note: what to emphasize in discussion" closed="true" >}}

The discussion here should stay on the visible science result:

- Where is the bump in each model?
- How does the bump move as period changes?
- What does the nonlinear light-curve shape add that Lab 2 could not show?

{{< /details >}}

## Suggested Reading

- [Farag et al. 2026, self-consistent nonlinear classical Cepheid pulsations during stellar evolution with MESA](https://arxiv.org/abs/2603.15766)
- [Bono, Marconi, and Stellingwerf 2000, the Hertzsprung progression](https://ui.adsabs.harvard.edu/abs/2000A%26A...360..245B/abstract)
- [Marconi et al. 2024, the Hertzsprung progression of classical Cepheids in the Gaia era](https://ui.adsabs.harvard.edu/abs/2024MNRAS.529.4210M/abstract)
