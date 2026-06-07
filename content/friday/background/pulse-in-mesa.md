---
title: Pulsations in MESA
weight: 5
---

## How many ways to do pulsations in MESA?

As you have seen today, there are many different codes packaged with MESA designed for analyzing stellar pulsations/oscillations. Which particular code is best, will depend on the type of star/pulsations you plan to study. We’ve compiled a list here, with some references to help you choose.

A reminder of some of the terminology:

- Linear: pulsations remain “small”, code calculates frequencies and eigenfunctions but cannot provide information about amplitude
- Adiabatic: heating term in the perturbed energy equation can be neglected, code cannot provide information about the growth rates/stability of pulsation
- Frozen convection approximation: an approximation that can be made to simplify nonadiabatic mode calculations, where the perturbations to the convective flux are neglected

| Code | Linearity | Adibaticity | Notes | References |
| ---- | --------- | ----------- | ----- | ---------- |
| Adipls | linear | adiabatic | Similar to GYRE, perhaps less user friendly | [ADIPLS](https://ui.adsabs.harvard.edu/abs/2008Ap%26SS.316..113C/abstract) |
| GYRE | linear | adiabatic & nonadiabatic | When doing nonadiabatic calculations GYRE uses the frozen convection approximation, can also calculate tidally force oscillations | [GYRE intro](https://ui.adsabs.harvard.edu/abs/2013MNRAS.435.3406T/abstract), [GYRE nonadiabatic method 1](https://ui.adsabs.harvard.edu/abs/2018MNRAS.475..879T/abstract), [GYRE nonadiabatic method 2](https://ui.adsabs.harvard.edu/abs/2020ApJ...899..116G/abstract), [GYRE Tides](https://ui.adsabs.harvard.edu/abs/2023ApJ...945...43S/abstract) |
| RSP-LNA | linear | nonadiabatic | Only does radial modes, restricted to homogeneous partially convective envelope, static model builder has limited range of convergence | [RSP Method](https://ui.adsabs.harvard.edu/abs/2008AcA....58..193S/abstract), [Implementation in MESA](https://ui.adsabs.harvard.edu/abs/2019ApJS..243...10P/abstract) |
| RSP Full | nonlinear | nonadiabatic | Only does radial modes, restricted to homogeneous partially convective envelope, static model builder has limited range of convergence | [RSP Method](https://ui.adsabs.harvard.edu/abs/2008AcA....58..193S/abstract), [Implementation in MESA](https://ui.adsabs.harvard.edu/abs/2019ApJS..243...10P/abstract) |
| TDC Pulsations (see lab 3) | nonlinear | nonadiabatic | Works for any envelope (or full stellar model) with additional evolutionary physics, significantly increased computation time | [TDC Pulsations](https://ui.adsabs.harvard.edu/abs/2026arXiv260315766F/abstract) |

## RSP and TDC convection controls

RSP and MESA-star TDC use the same one-equation turbulent convection model. In this model, the turbulent kinetic energy $e_t$ evolves as

\[
\begin{aligned}
\frac{D e_t}{D t}
&+ \alpha_{p_t} P_t \frac{D \rho^{-1}}{D t} \\
&= \epsilon_q + C - \frac{\partial L_t}{\partial m}.
\end{aligned}
\]

The source/sink term and convective luminosity are

\[
\begin{aligned}
C ={}&
\alpha e_t^{1/2}\frac{T P Q}{h\sqrt{6}}\mathcal{Y} \\
&- \alpha_D\left(\frac{8}{3}\sqrt{\frac{2}{3}}\right)\frac{e_t^{3/2}}{\alpha h} \\
&- \frac{48\sigma\gamma_r}{\alpha^2}
\left(\frac{T^3}{\rho^2 c_P \kappa h^2}\right)e_t,
\end{aligned}
\]

and

\[
\begin{aligned}
L_\mathrm{conv} &= 4\pi r^2\alpha\rho c_P T\frac{w}{\sqrt{6}}\mathcal{Y}, \\
w &= e_t^{1/2}.
\end{aligned}
\]

RSP can also include a nonlocal turbulent-flux term,

\[
\begin{aligned}
L_t &= -A \alpha \alpha_t \rho h e_t^{1/2}\frac{\partial e_t}{\partial r}, \\
A &= 4\pi r^2.
\end{aligned}
\]

The Lab 3 MESA-star TDC setup uses the same convection model in the local limit, without this nonlocal overshooting term.

| Physical role | RSP control | MESA-star TDC control | Lab value |
| --- | --- | --- | --- |
| MESA label "mixing length"; $\alpha$ in the convection terms | `RSP_alfa` | `mixing_length_alpha` | `1.77d0` |
| MESA label "convective flux"; scales $L_\mathrm{conv}$ | `RSP_alfac` | `TDC_alpha_C` | `1d0` |
| MESA label "turbulent source"; source term inside $C$ | `RSP_alfas` | `TDC_alpha_S` | `1d0` |
| MESA label "turbulent dissipation"; cascade sink inside $C$ | `RSP_alfad` | `TDC_alpha_D` | `1d0` |
| MESA label "turbulent pressure"; pressure-work term | `RSP_alfap` | `TDC_alpha_Pt` | `0d0` |
| MESA label "turbulent flux"; nonlocal overshoot term $L_t$ | `RSP_alfat` | not used by local-limit MESA-star TDC | `0d0` |
| MESA label "eddy viscosity"; eddy viscous damping | `RSP_alfam` | `TDC_alpha_M` | `0.25d0` |
| MESA label "radiative losses"; radiative sink inside $C$ | `RSP_gammar` | `TDC_alpha_R` | `0d0` |

In the Lab 2 RSP-LNA setup, `RSP_max_num_periods = 0` means RSP is only used for the linear analysis. In Lab 3, MESA-star TDC then follows the nonlinear finite amplitude pulsation with the corresponding TDC controls.
