---
weight: 2
title: Lab 1 - Evolving a Cepheid into the Instability Strip
linkTitle: Lab 1
---

# Lab 1: Evolving a Cepheid into the Instability Strip

In this lab you will learn how to evolve a classical Cepheid model, with an initial mass in the $3$-$8\,M_\odot$ range. The evolution will be divided in two steps: first you will start from the Zero Age Main Sequence (ZAMS) and stop when a threshold in effective temperature $T_{\mathrm{eff}}$ is reached. 

In the second part of this lab, you will resume the previous run and simulate the evolution all the way through Helium burning, until reaching Helium depletion in the core. While the simulation runs you'll get to watch your star producing a blue loop and moving into the instability strip, while GYRE runs automatically during the pulsational phase!

During this second part of the run, you will also save some models (called `.mod` files), that will be reused in the upcoming lab.



## First steps: setting up the work directory
**Task 1**: Create your working directory for this lab. 

The name of the directory could be something like ``` ~/ MESA_ss_2026/friday```.
You may also place the working directory somewhere other than your home directory.

{{< details title="Answer 1" closed="true" >}}

Here's how to creade your working directory and then move inside it.
```bash
mkdir -p ~/MESA_ss_2026/friday
cd ~/MESA_ss_2026/friday

```
The mkdir -p command creates a directory and includes all the needed parent directories. So if the parent directory does not exist, it will be created automatically.
{{< /details >}}

**Task 2**: Download and unzip the input directory. 

We have already prepared an input directory to help you getting started with this lab: you can find it [here](https://mesastar.org/summer-school-2026/lodging/). **the link is a placeholder for now**.

Download the work directory into the  ``` ~/ MESA_ss_2026/friday``` directory you just created, unpack it, and enter into it.

{{< details title="Answer 2" closed="true" >}}

Here's how to unzip the input folder
```bash
unzip lab1_input.zip 
cd lab1_input
```



-----
-----
-----

Discuss with your team members and choose a value of initial mass in the range $3$-$8\,M_\odot$, so that you can 

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
