---
weight: 3
title: Lab 2 - Linear Analysis in GYRE vs LNA (from RSP)
linkTitle: Lab 2
---
## Background

In lab 1, we evolved a star through the instability strip and used GYRE (on-the-fly within MESA) to calculate the expected periods and growth rates of the fundamental radial mode $(l = 0, n = 0)$. However, when doing non-adiabatic calculations GYRE uses the frozen convection approximation. This approximation assumes that the oscillations do not perturb the convective flux. While this approximation is reasonable for smaller amplitude pulsations, the large amplitude of the pulsations in Cepheids do perturb the convective flux. To account for this, we’ll now use a different pulsation tool included in MESA: the Radial Stellar Pulsations (RSP) code. Specifically, we'll use RSP's linear non-adiabatic  functionality (RSP-LNA). We will also be constructing a graph that shows the period-luminosity relationship that makes Cepheid stars so important for measuring astronomical distances.

## Science Goals

1. Determine the period-luminosity relation from our models
2. Check the agreement between GYRE non-adiabatic calculations and RSP-LNA

## MESA Goals

1. Use RSP's linear analysis tool to determine both periods and growth rates of the fundamental and first overtone modes
2. Bonus: Learn how to use simple bash scripts to automate running MESA with many different parameters

## Lab Directions

For this lab we’ll be using the models that you saved from Lab 1. If your run did not complete then please find the solutions directory for your mass here: **add link to solutions dir**.

### Add GYRE values to shared spreadsheet for several models

First things first, let’s look for models where we expect pulsations in the fundamental mode to be excited. These are the modes with positive growth rates. Recall, that in lab 1 we saved the growth rates of the fundamental radial mode (and the first and second overtones) in the history file. In addition to looking for a model with a positive growth rate, please also choose a model number where a `.mod` file was saved. This is to ensure that you are looking at models where RSP can also be used and so that you can evolve the non-linear pulsations for this model in lab 3. Once you have found a model with a positive growth rate (and a `.mod` file): please add the period, luminosity, and growth rate to this spreadsheet: **add spreadsheet link here**. As more people add their models, we should see a clear relationship between the period and luminosity values.

### Set up RSP work directory

Although we are using the results of lab 1, we want to create a new working directory since we'll be using different inlists to run RSP. You can find the starting working directory here **add link to starting directory**.

### Set up RSP inlist

There are a few inlist parameters you will need to change in `inlist_rsp_Cepheid`. The place for each addition is marked with `!!!`. If you wish to test your skills at reading MESA documentation, take a moment now to search the documentation to determine for yourself what needs to be changed. Otherwise see the walk through below.

{{< details title="Task: RSP inlist settings" closed="true" >}}

To use RSP within MESA, we need to set `create_RSP_model = .true.` in the `star_job` section of `inlist_rsp_Cepheid`. For consistency with the GYRE results obtained in lab 1, we keep the same settings in both the `eos` and `kap` sections of the inlist. Most of the inlist parameters used by RSP are found in the `controls` section of the inlist. Take a minute to look at the documentation of these controls [found here](https://docs.mesastar.org/en/26.4.1/reference/controls.html#radial-stellar-pulsations-rsp). The first few controls are marked as "must set". This is because, rather than taking a full stellar model as GYRE does, RSP uses the stellar mass, luminosity, effective temperature, and envelope composition to build a static model of the stellar envelope.

The next set of controls change the parameters of the convection model which will be discussed by Eb in the lecture introducing lab 3. **Double check with Eb that this is, in fact, the case** There are also some additional numerical controls that we will leave at their default values. The only other RSP control we will change is `RSP_max_num_periods` which we will set to 0. This is because we are only using RSP to perform the LNA analysis and not to evolve the non-linear pulsations.

Using your history output from lab 1, set the following controls in `inlist_rsp_Cepheid` to the correct value for the models you examined in the previous step:

```fortran
    RSP_mass = 
    RSP_Teff = 
    RSP_L = 
    RSP_X = 
    RSP_Z = 
```

A few notes:

1. Because we have mass loss turned on, the mass of each model will not be the initial mass we started with in lab 1.
2. We're going to take our values of `RSP_X` and `RSP_Z` from the surface mass fractions saved in the history file. First, however, we should check that the surface abundances are representative of the composition in the envelope. You can do this using the saved model which includes the abundance profiles of all isotopes throughout the star. Check that the `h1` and `he4` values of the surface zone are representative of the stellar envelope.
3. Make sure to double check that you are inputting your values in the units expected by RSP: mass in Msun, Teff in K, L in Lsun, X and Z as mass fractions.

{{< /details >}}

### Run RSP LNA

Once you have set necessary inlist controls, run MESA in the normal way.

[!TIP]
Since this is new working directory, don't forget to compile MESA before calling it.

### Understanding potential error messages

Depending on the model that you chose, you may get an error message that looks something like

```none
 read inlist_rsp_Cepheid
 create initial RSP model
 P <= Prad          -1   3.1066999930251846        31.441496087080992        10566.796852683854     
 failed in do_rsp_build
 failed in build_rsp_model
 star_create_RSP_model ierr          -1
 do_load1_star ierr          -1
 do_before_evolve_loop ierr          -1
 do_before_evolve_loop ierr          -1
```

This error indicates that you are trying to build a model outside of the regime where RSP's model builder can converge. In this case, please pick a different model number and try again.

If you receive the following error:

```none
 read inlist_rsp_Cepheid
 create initial RSP model
 failed to find outer dm to satisfy tolerance for T_anchor
 you might try increasing RSP_T_anchor_tolerance
 failed in do_rsp_build
 failed in build_rsp_model
 star_create_RSP_model ierr          -1
 do_load1_star ierr          -1
 do_before_evolve_loop ierr          -1
 do_before_evolve_loop ierr          -1
```

then try following the suggestion made in the error message and increase `RSP_T_anchor_tolerance` to `1d-4`. If this still doesn't, work then again you are likely trying to build a model outside of regime that RSP's model builder can handle. Please pick another model and try again.

### Understanding the output of a successful RSP LNA run

Once you have found a set of model parameters where RSP successfully builds an envelope model your output will look something like:

```none
read inlist_rsp_Cepheid
 create initial RSP model
            P(days)         growth
  0       0.14728E+02    -0.21797E-01
  1       0.87938E+01    -0.14356E+00
  2       0.63221E+01    -0.22557E+00
                                                     nz         150
                                                  T(nz)    1.9903944381453020D+06
                                          L_center/Lsun    2.9475799999999999D+03
                                          R_center/Rsun    4.5306625805144325D+00
                                          M_center/Msun    2.2651322466144657D+00
                                              L(1)/Lsun    2.9475799999999999D+03
                                              R(1)/Rsun    8.0366922071693168D+01
                                              M(1)/Msun    5.9900000000000002D+00
                                               v(1)/1d5    1.0000000000000001D-01
                                             tau_factor    1.5000000000000000D-03
                                               tau_base    6.6666666666666663D-01

                             set_initial_number_retries           0
 net name o18_and_ne22.net
 RSP_flag T
 v_flag T
                                             tau_factor    1.5000000000000000D-03
                                           xmstar/mstar    6.2184770507271026D-01
                                             xmstar (g)    7.4065638078766692D+33
                                           M_center (g)    4.5040113176046538D+33
                                            xmstar/Msun    3.7248677533855350D+00
                                          M_center/Msun    2.2651322466144657D+00
                                          R_center (cm)    3.1519819572638794D+11
                                          R_center/Rsun    4.5306625805144165D+00
                                           core density    3.4336790237497916D-02
                                          L_center/Lsun    2.9475799999999999D+03
 kap_option gs98
 kap_CO_option gs98_co
 kap_lowT_option lowT_fa05_gs98
                                        OMP_NUM_THREADS          16
```

This is then followed by the usual MESA terminal output header, and one model's worth of output before MESA terminates with `termination code: reached max number of periods`. Of this information, the part we are most interested in is the period and growth rate information printed right after `create initial RSP model`. RSP indexes the modes in order of decreasing period (increasing frequency). In our case, the mode labeled 0 should be the fundamental radial mode, followed by the first and second overtones (modes 1 and 2). RSP then prints some information about the stellar model, conveniently printing the surface luminosity labeled as `L(1)/Lsun`. Using this output, add your RSP results to the shared spreadsheet.

To fill in our period luminosity diagram a little bit more, repeat this process (changing the inlist parameters and running RSP LNA) for different timesteps from your lab 1 results.

[!NOTE]
Take a look at your original `history.data` file. Do you need to change the envelop composition when running a new model?

### As the spreadsheet fills in discuss the following questions at your table

- Do GYRE and RSP-LNA give similar periods on the same model?
- Are the growth rates similar between the two codes? 
- How much scatter do we see across the class sample?
- What kind of period-luminosity relation do we recover from the models?

### Bonus task: Batch running RSP

After setting up RSP for several different parameter combinations, you might notice that doing this manually is a little bit tedious (and if you're anything like me, very prone to human error). For the bonus task, you can try your hand at automating these runs. Depending on how you're feeling halfway through Friday, there are a few different difficulty levels that you can choose from, see below. Regardless of your chosen difficulty level, once you have your results please add the period, luminosity, and growth rate data to the shared spreadsheet.

#### Let me cook

Come up with your own approach to automating this task. After you have a plan but before starting to write your code, discuss your answers to the following questions with your TA.

{{< details title="Things to consider when automating your MESA RSP LNA run" closed="true" >}}

- How do you plan to extract the relevant parameters from the output of lab 1?
- How do you plan to create the correct inlist for each model?
- What output do you need to save?
- How can you make this output easy to process (i.e., add to the spreadsheet)?

{{< /details >}}

#### Set me on the path

Below, you'll find an outline of one possible approach to solve this problem. Using this outline, create your own implementation of each part of the process from scratch.

{{< details title="One potential approach" closed="true" >}}

- Conveniently, the `.mod` files saved in lab 1 contain all of the relevant information for RSP in their filenames. Note that because the envelope doesn't change composition, you don't need to change `RSP_X` or `RSP_Z`. This means that you can create a bash script which loops over all of the files in the lab 1 `mod_dir` and extracts the relevant parameters from the filename for each model.
- In this loop you can use `shmesa change` to update the relevant inlist parameters `RSP_mass`, `RSP_Teff`, `RSP_L` before running MESA.
- As you saw in the main lab, RSP prints the period and growth rates to the terminal. Additionally, the `extras_start_step` routine in `run_star_extras` is already configured to write LNA data to an output file. You will need to figure out the control necessary to trigger this output and to modify this routine to ensure that the output is not overwritten when you call MESA again for each new model (the keyword `position` in the fortran `open` call may be useful). You may also want to double check the units of this output.

{{< /details >}}

#### Take my hand

Here **add link to partial solutions** you will find partially complete solutions which use the method described in the hint above. See these files for specific instructions on what you need to do to complete them.

#### Show me how it's done

{{< details title="Small changes to the solutions files you still need to make" closed="true" >}}

Here **add link to full solutions** you will find a complete set of solutions with comments explaining the code. Read through the code to understand what is happening and then run it using your results from lab 1. 

If you use these solutions files directly, you still need to pass the correct path for your `mod_dir` from lab 1 in `batch_LNA.sh`, and set `RSP_X` and `RSP_Z` to the correct values in `inlist_rsp_Cepheid` (using the same values as the main part of the lab).

{{< /details >}}

## Eb's prior information

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
