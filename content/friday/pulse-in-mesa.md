---
weight: 3
title: Bonus Info: How many ways to do pulsations in MESA?
linkTitle: BonusInfo
---

## How many ways to do pulsations in MESA?

As you have seen today, there are many different codes packaged with MESA designed for analyzing stellar pulsations/oscillations. Which particular code is best, will depend on the type of star/pulsations you plan to study. We’ve compiled a list here, with some references to help you choose.

A reminder of some of the terminology:

- Linear: pulsations remain “small”, code calculates frequencies and eigenfunctions but cannot provide information about amplitude
- Adiabatic: heating term in the perturbed energy equation can be neglected, code cannot provide information about the growth rates/stability of pulsation
- Frozen-convection approximation: an approximation that can be made to simplify non-adiabatic mode calculations, where the perturbations to the convective flux are neglected

| Code | Linearity | Adibaticity | Notes | References |
| ---- | --------- | ----------- | ----- | ---------- |
| Adipls | linear | adiabatic | Similar to GYRE, perhaps less user friendly | [ADIPLS](https://ui.adsabs.harvard.edu/abs/2008Ap%26SS.316..113C/abstract) |
| GYRE | linear | adiabatic & non-adiabatic | When doing non-adiabatic calculations GYRE uses the frozen-convection approximation, can also calculate tidally force oscillations | [GYRE intro](https://ui.adsabs.harvard.edu/abs/2013MNRAS.435.3406T/abstract), [GYRE non-adiabatic method 1](https://ui.adsabs.harvard.edu/abs/2018MNRAS.475..879T/abstract), [GYRE non-adiabatic method 2](https://ui.adsabs.harvard.edu/abs/2020ApJ...899..116G/abstract), [GYRE Tides](https://ui.adsabs.harvard.edu/abs/2023ApJ...945...43S/abstract) |
| RSP-LNA | linear | non-adiabatic | Only does radial modes, restricted to homogeneous partially convective envelope, static model builder has limited range of convergence | [RSP Method](https://ui.adsabs.harvard.edu/abs/2008AcA....58..193S/abstract), [Implementation in MESA](https://ui.adsabs.harvard.edu/abs/2019ApJS..243...10P/abstract) |
| RSP Full | non-linear | non-adiabatic | Only does radial modes, restricted to homogeneous partially convective envelope, static model builder has limited range of convergence | [RSP Method](https://ui.adsabs.harvard.edu/abs/2008AcA....58..193S/abstract), [Implementation in MESA](https://ui.adsabs.harvard.edu/abs/2019ApJS..243...10P/abstract) |
| TDC Pulsations (see lab 3) | non-linear | non-adiabatic | Works for any envelope (or full stellar model) with additional evolutionary physics, significantly increased computation time | [TDC Pulsations](https://ui.adsabs.harvard.edu/abs/2026arXiv260315766F/abstract) |