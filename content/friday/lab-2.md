---
weight: 3
title: Lab 2 - Linear Analysis in GYRE vs LNA (from RSP)
linkTitle: Lab 2
---

Lab 2 extends the Lab 1 work. We take the `.mod` files and GYRE results from the Cepheid evolution runs, compare them against RSP-LNA on the same stellar structures, and build a class period-luminosity relation. The main comparison should start with the radial fundamental `l = 0` mode, `P0`.

The simple version of that relation is just $\log L$ versus $\log P$, and that is enough for the lab. If we want an extra step, we can also look at a Wesenheit relation,

$$
W_{VI} = I - R_{VI}(V-I)
$$

which is a reddening-reduced period-luminosity-color relation. We do not need that extra step to make the lab work. In fact, the scatter in a plain $\log L$ versus $\log P$ plot is useful because part of it comes from the color dependence that the Wesenheit construction is designed to reduce.

One science point of this lab is that GYRE and RSP-LNA should not be expected to agree perfectly. In its non-adiabatic linear treatment, GYRE uses the frozen convection approximation and drops the perturbation to convective flux. That makes it behave more like a radiative linear calculation. For Cepheids, this often means periods agree better than growth rates, and the agreement should be better toward the blue edge of the instability strip than toward the red edge where convection matters more.

## Directories

- `content/friday/MESA_models/lab1_evolve_a_cepheid/cepheid_evolution_gyre_in_mesa/`
- `content/friday/MESA_models/lab2_GYRE_vs_LNA_P_L/rsp_Cepheid_LNA/`

## Goal

- reuse the Cepheid models saved in Lab 1
- compare GYRE-in-MESA periods and growth rates with RSP-LNA
- focus first on the radial fundamental `l = 0` mode, `P0`
- build a class `log P` versus `log L` relation in Google Sheets

## What Students Do

1. Start from the saved `.mod` files from Lab 1.
2. Gather the GYRE-in-MESA output for the radial fundamental `l = 0` mode, `P0`, from the Lab 1 run.
3. Use the `rsp_Cepheid_LNA` directory to run LNA on the same structures.
4. Compare the periods and growth rates from the two methods, starting with the fundamental mode.
5. Add the class results to a shared Google Sheet and build the `log P` versus `log L` plot.
6. If there is time, use the colors module as an extra step and make a Wesenheit-based relation.
7. If there is time, inspect any unstable radial overtone `l = 0` cases that appear in the output, such as `P1` or `P2`.

```bash
cd content/friday/MESA_models/lab2_GYRE_vs_LNA_P_L/rsp_Cepheid_LNA
./mk
./rn
```

> [!IMPORTANT]
> This lab is not a separate science story. It extends the Lab 1 model directory and uses `rsp_Cepheid_LNA` specifically so we can compare LNA in RSP against the GYRE results from the Lab 1 Cepheid models.

> [!TIP]
> Keep the first pass simple. If the class gets a clean fundamental mode comparison and a usable `log P` versus `log L` relation, the lab has done its job.

> [!NOTE]
> A main thing to look for is that the two linear calculations often agree better in period than in growth rate. The likely reason is that GYRE freezes convection while RSP-LNA is the comparison built for a Cepheid pulsation framework where convection matters.

## What the Class Should Produce

- a table of GYRE-in-MESA and RSP-LNA periods and growth rates for the fundamental `l = 0` mode, `P0`
- a class `log P` versus `log L` relation
- an optional Wesenheit relation if the bonus step is used
- an optional note on any unstable radial overtone cases

## TA Prep

- pick which Lab 1 `.mod` files the class should start with
- decide which fundamental `l = 0` mode quantity from each run, for `P0`, the class will treat as the primary comparison point
- set up the shared Google Sheet so each table enters mass, luminosity, period, growth rate, and method
- keep the Wesenheit step clearly marked as optional
- remind the class that the blue-edge versus red-edge trend is something they should look for in the comparison

{{< details title="TA note: what to emphasize in discussion" closed="true" >}}

The discussion in this lab should stay close to three questions:

- Do GYRE and RSP-LNA give similar periods on the same model?
- Do they disagree more clearly in growth rates?
- How much scatter do we see across the class sample?
- What kind of period-luminosity relation do we recover from the models?

{{< /details >}}

## Suggested Reading

Method references:

- [Townsend and Teitler 2013, GYRE](https://ui.adsabs.harvard.edu/abs/2013MNRAS.435.3406T/abstract)
- [Paxton et al. 2019, MESA V](https://ui.adsabs.harvard.edu/abs/2019ApJS..243...10P/abstract)
- [Anderson et al. 2016, pulsation-convection coupling and Cepheid instability-strip edges](https://www.aanda.org/articles/aa/full_html/2016/07/aa28031-15/aa28031-15.html)

Pulsation and P-L references:

- [Smolec et al. 2026, MESA Cepheid grid III](https://arxiv.org/abs/2603.26111)
- [Bono et al. 1999, theoretical Cepheid P-L, P-C, and P-L-C relations](https://ui.adsabs.harvard.edu/abs/1999ApJ...512..711B/abstract)
- [Espinoza-Arancibia et al. 2022, period change rates of LMC Cepheids using MESA](https://ui.adsabs.harvard.edu/abs/2022MNRAS.517.1538E/abstract)
