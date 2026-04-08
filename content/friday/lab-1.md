---
weight: 2
title: Lab 1 - Evolving a Cepheid into the Instability Strip
linkTitle: Lab 1
---

Lab 1 is where the Friday sequence starts. The point is to evolve a classical Cepheid model in the $3$-$8\,M_\odot$ range, follow it into core helium burning, and save the models that we will reuse in Lab 2.

> [!IMPORTANT]
> Ignore the README in this directory for the Friday lab plan. The actual model directory here is the setup we want to use to evolve a Cepheid, run GYRE in MESA during helium burning, and save `.mod` files for the next lab.

## Directory

`content/friday/MESA_models/lab1_evolve_a_cepheid/cepheid_evolution_gyre_in_mesa/`

## Goal

- evolve a Cepheid model into the instability strip
- watch the blue loop during core helium burning
- run GYRE in MESA while the star is in the Cepheid phase
- save `.mod` files that Lab 2 can reuse

## What Students Do

1. Pick a mass in the $3$-$8\,M_\odot$ range. The cleanest class split is to assign masses in $0.5\,M_\odot$ steps.
2. Build and run the Lab 1 work directory.
3. Use PGSTAR and the history output to follow the track into core helium burning.
4. Let the modified `run_star_extras` call GYRE in MESA during the helium-burning part of the run.
5. Save the `.mod` files written during the Cepheid phase and record the matching `log L` and `log T_eff`.

```bash
cd content/friday/MESA_models/lab1_evolve_a_cepheid/cepheid_evolution_gyre_in_mesa
./mk
./rn
```

> [!NOTE]
> In this setup, `src/run_star_extras.f90` turns on regular GYRE calls only during core helium burning and writes `.mod` files into `mod_dir/`.

## What the Class Should Produce

- an HR diagram with the strip-crossing models marked
- a shared table with mass, `log L`, `log T_eff`, and saved model names
- a bank of helium-burning `.mod` files for Lab 2

## TA Prep

- decide ahead of time how the class mass grid will be split across tables
- check that each table knows where the saved `.mod` files are being written
- make sure the class records which saved models are the best Cepheid candidates
- have one or two fallback masses ready in case a run needs to be swapped

{{< details title="TA note: what to emphasize in discussion" closed="true" >}}

Keep the discussion centered on a few concrete questions:

- Which masses make the cleanest blue loops?
- Which models actually enter the instability strip?
- How does the Cepheid candidate phase depend on mass?
- Which saved structures are the best starting points for Lab 2?

{{< /details >}}

## Suggested Reading

- [Ziółkowska et al. 2024, MESA Cepheid grid I](https://ui.adsabs.harvard.edu/abs/2024ApJS..274...30Z/abstract)
- [Ziółkowska et al. 2026, MESA Cepheid grid II](https://arxiv.org/abs/2602.08109)
