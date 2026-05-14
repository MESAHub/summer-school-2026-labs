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

For this lab we’ll be using the models that you saved from Lab 1. If your run did not complete, use the [Lab 1 GYRE file solutions](https://drive.google.com/drive/folders/1woaPSSlIvNQADA5Eg-SGO0N11gXHa-S2?usp=share_link) and the `gyre_in_mesa.data` file in the subdirectory for your initial mass. When you need the saved MESA models, use the [Lab 1 mod file solutions](https://drive.google.com/drive/folders/1jBEtn-JCkOq15l9cT3Z_L_jecpIAqeKs?usp=share_link), which are zipped by mass.

### Add GYRE values to shared spreadsheet for several models

First things first, let’s look for models where we expect pulsations in the fundamental mode to be excited. These are the modes with positive growth rates. Recall, that in lab 1 we saved the GYRE results for the fundamental radial mode and the first and second overtones in `gyre_in_mesa.data`. This file includes the model number, effective temperature, luminosity, periods, and growth information for models where GYRE was called in MESA. In addition to looking for a model with a positive growth rate, please also choose a model number where a `.mod` file was saved. This is to ensure that you are looking at models where RSP can also be used and so that you can evolve the non-linear pulsations for this model in lab 3. Once you have found a model with a positive growth rate (and a `.mod` file): please add the period, luminosity, and growth rate to [this spreadsheet](https://docs.google.com/spreadsheets/d/1dVK0vpzgsAy0S7OG-qMyJlmwItwbp1JeB8B-xScV8WI/edit?usp=drive_link). As more people add their models, we should see a clear relationship between the period and luminosity values.

### Set up RSP work directory

Although we are using the results of lab 1, we want to create a new working directory since we'll be using different inlists to run RSP. You can find the [starting working directory here](https://drive.google.com/file/d/1MFZ4UsVcrvNBqcccYJmqZQhli_A8DGjP/view?usp=share_link).

The shared Lab 2 files are:

- [FriLab2Start.zip](https://drive.google.com/file/d/1MFZ4UsVcrvNBqcccYJmqZQhli_A8DGjP/view?usp=share_link)
- [FriLab2BonusPartialSolve.zip](https://drive.google.com/file/d/1YXyy03R6unwUVqn8J1Ej9TOM1ZmYnyoz/view?usp=share_link)
- [FriLab2BonusFullSolve.zip](https://drive.google.com/file/d/1q_ieQpw9ggKxSQ-5eoDLMWcuXlMX4hrQ/view?usp=share_link)

### Set up RSP inlist

There are a few inlist parameters you will need to change in `inlist_rsp_Cepheid`. The place for each addition is marked with `!!!`. If you wish to test your skills at reading MESA documentation, take a moment now to search the documentation to determine for yourself what needs to be changed. Otherwise see the walk through below.

{{< details title="Task: RSP inlist settings" closed="true" >}}

To use RSP within MESA, we need to set `create_RSP_model = .true.` in the `star_job` section of `inlist_rsp_Cepheid`. For consistency with the GYRE results obtained in lab 1, we keep the same settings in both the `eos` and `kap` sections of the inlist. Most of the inlist parameters used by RSP are found in the `controls` section of the inlist. Take a minute to look at the documentation of these controls [found here](https://docs.mesastar.org/en/26.4.1/reference/controls.html#radial-stellar-pulsations-rsp). The first few controls are marked as "must set". This is because, rather than taking a full stellar model as GYRE does, RSP uses the stellar mass, luminosity, effective temperature, and envelope composition to build a static model of the stellar envelope.

The next set of controls change the parameters of the convection model which will be discussed by Eb in the lecture introducing lab 3. Most of these we will leave set to their default values however we need to set the mixing length parameter used by RSP (`RSP_alfa`) to match our evolutionary models constructed in lab 1. There are also some additional numerical controls that we will leave at their default values. The only other RSP control we will change is `RSP_max_num_periods` which we will set to 0. This is because we are only using RSP to perform the LNA analysis and not to evolve the non-linear pulsations.

Using your Lab 1 `.mod` filename and the matching row in `gyre_in_mesa.data`, set the following controls in `inlist_rsp_Cepheid` to the correct value for the models you examined in the previous step:

```fortran
    RSP_mass = 
    RSP_Teff = 
    RSP_L = 
    RSP_X = 
    RSP_Z = 
    RSP_alfa = 
```

A few notes:

1. Because we have mass loss turned on, the mass of each model will not be the initial mass we started with in lab 1.
2. We're going to take our values of `RSP_X` and `RSP_Z` from the surface mass fractions saved in the history file. First, however, we should check that the surface abundances are representative of the composition in the envelope. You can do this using the saved model which includes the abundance profiles of all isotopes throughout the star. Check that the `h1` and `he4` values of the surface zone are representative of the stellar envelope.
3. Make sure to double check that you are inputting your values in the units expected by RSP: mass in Msun, Teff in K, L in Lsun, X and Z as mass fractions.

{{< /details >}}

### Run RSP LNA

Once you have set necessary inlist controls, run MESA in the normal way.

> [!TIP]
> Since this is new working directory, don't forget to compile MESA before calling it.

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

### Wesenheit Index - Period Relationship

As more people fill in the spreadsheet, you may notice that the period luminosity relationship has a fair bit of scatter. This is because **Add more details here about where the theoretical color dependence comes from**. To reduced this scatter, instead of using luminosity we can use the Wesenheit index which is a parameter that corrects for reddening effects:

$ W_{VI} = I - R(V-I), $

Where $V$ and $I$ are the absolute magnitudes in the V and I bands, respectively, and $R$ is a constant that parameterizes the color dependence. We'll use the value $R=1.55$ from Madore 1982, see also Smolec et al 2026. As we learned on day 1, MESA can now output these magnitudes using the `colors` module. Since these bands are included in the default list we can simply set

```none
&colors
   use_colors = .true. 
/ ! end of colors namelist
```

as the `colors` section of the inlist. We can now rerun the model. Although, by default the Wesenheit index is not printed to the terminal when using RSP-LNA, the `run_star_extras` file we have provided you does print this information.

To fill in our diagrams a little bit more, repeat this process (changing the inlist parameters and running RSP LNA) for different timesteps from your lab 1 results.

> [!NOTE]
> Take a look at your original `history.data` file from lab 1. Do you need to change the envelop composition when running a new model?

### As the spreadsheet fills in discuss the following questions at your table

- Do GYRE and RSP-LNA give similar periods on the same model?
- Are the growth rates similar between the two codes?
- How much scatter do we see across the class sample?
- What kind of period-luminosity relation do we recover from the models?
- Does using the Wesenheit index reduce the scatter compared to the period-luminosity relation?

### Bonus task: Batch running RSP

After setting up RSP for several different parameter combinations, you might notice that doing this manually is a little bit tedious (and if you're anything like me, very prone to human error). For the bonus task, you can try your hand at automating these runs. Depending on how you're feeling halfway through Friday, there are a few different difficulty levels that you can choose from, see below. Regardless of your chosen difficulty level, once you have your results please add the period, luminosity, and growth rate data to the shared spreadsheet.

#### Let me cook

Come up with your own approach to automating this task. After you have a plan but before starting to write your code, discuss your answers to the following questions with your TA.

{{< details title="Things to consider when automating your MESA RSP LNA run" closed="true" >}}

- How do you plan to extract the relevant parameters from the output of lab 1?
- How do you plan to create the correct inlist for each model?
- How do you plan to loop over all the relevant models?
- What output do you need to save?
- How can you make this output easy to process (i.e., add to the spreadsheet)?
- If you want to also include GYRE information in your output what steps do you need to take?

{{< /details >}}

#### Set me on the path

Below, you'll find an outline of one possible approach to solve this problem. Using this outline, create your own implementation of each part of the process from scratch.

{{< details title="One potential approach" closed="true" >}}

- Conveniently, the `.mod` files saved in lab 1 contain all of the relevant information for RSP in their filenames. Note that because the envelope doesn't change composition, you don't need to change `RSP_X` or `RSP_Z`. This means that you can create a bash script which loops over all of the files in the lab 1 `mod_dir` and extracts the relevant parameters from the filename for each model.
- In this loop you can use `shmesa change` to update the relevant inlist parameters `RSP_mass`, `RSP_Teff`, `RSP_L` before running MESA.
- As you saw in the main lab, RSP prints the period and growth rates to the terminal and we provided code to print the Wesenheit index. Additionally, the `extras_start_step` routine in `run_star_extras` is already configured to write LNA data to an output file. That table includes the Lab 1 model number, mass, luminosity, effective temperature, Wesenheit index, RSP-LNA period/growth, and GYRE period/growth. You will need to figure out the control necessary to trigger this output and to modify this routine to ensure that the output is not overwritten when you call MESA again for each new model (the keyword `position` in the fortran `open` call may be useful). You may also want to double check the units of this output.

{{< /details >}}

#### Take my hand

Start from the [partially complete solutions](https://drive.google.com/file/d/1YXyy03R6unwUVqn8J1Ej9TOM1ZmYnyoz/view?usp=share_link) which use the method described in the hint above. As with the earlier inlists, changes you need to make are marked with `!!!`.

#### Show me how it's done

{{< details title="Small changes to the solutions files you still need to make" closed="true" >}}

This is a [complete set of solutions](https://drive.google.com/file/d/1q_ieQpw9ggKxSQ-5eoDLMWcuXlMX4hrQ/view?usp=share_link) with comments explaining the code. Read through the code to understand what is happening and then run it using your results from lab 1.

If you use these solutions files directly, you still need to pass the correct path for your `mod_dir` from lab 1 to `batch_LNA.sh`, and set `RSP_X` and `RSP_Z` to the correct values in `inlist_rsp_Cepheid` (using the same values as the main part of the lab).

{{< /details >}}

## How many ways to do pulsations in MESA?

As you have seen today, there are many different codes packaged with MESA designed for analyzing stellar pulsations/oscillations. Which particular code is best, will depend on the type of star/pulsations you plan to study. We’ve compiled a list here, with some references to help you choose.

A reminder of some of the terminology:

- Linear: pulsations remain “small”, code calculates frequencies and eigenfunctions but cannot provide information about amplitude
- Adiabatic: heating term in the perturbed energy equation can be neglected, code cannot provide information about the growth rates/stability of pulsation
- Frozen-convection approximation: an approximation that can be made to simplify non-adiabatic mode calculations, where the perturbations to the convective flux are neglected

| Code | Linearity | Adibaticity | Notes | References |
| ---- | --------- | ----------- | ----- | ---------- |
| Adipls | linear | adiabatic | Similar to GYRE, perhaps less user friendly | [ADIPLS](https://ui.adsabs.harvard.edu/abs/2008Ap%26SS.316..113C/abstract) |
| GYRE | linear | adiabatic & non-adiabatic | When doing non-adiabatic calculations GYRE uses the frozen-convection approximation | [GYRE intro](https://ui.adsabs.harvard.edu/abs/2013MNRAS.435.3406T/abstract), [GYRE non-adiabatic method 1](https://ui.adsabs.harvard.edu/abs/2018MNRAS.475..879T/abstract), [GYRE non-adiabatic method 2](https://ui.adsabs.harvard.edu/abs/2020ApJ...899..116G/abstract), [GYRE Tides](https://ui.adsabs.harvard.edu/abs/2023ApJ...945...43S/abstract) |
| RSP-LNA | linear | non-adiabatic | Only does radial modes, restricted to homogeneous partially convective envelope, static model builder has limited range of convergence | [RSP Method](https://ui.adsabs.harvard.edu/abs/2008AcA....58..193S/abstract), [Implementation in MESA](https://ui.adsabs.harvard.edu/abs/2019ApJS..243...10P/abstract) |
| RSP Full | non-linear | non-adiabatic | Only does radial modes, restricted to homogeneous partially convective envelope, static model builder has limited range of convergence | [RSP Method](https://ui.adsabs.harvard.edu/abs/2008AcA....58..193S/abstract), [Implementation in MESA](https://ui.adsabs.harvard.edu/abs/2019ApJS..243...10P/abstract) |
| TDC Pulsations (see lab 3) | non-linear | non-adiabatic | Works for any envelope (or full stellar model) with additional evolutionary physics, significantly increased computation time | [TDC Pulsations](https://ui.adsabs.harvard.edu/abs/2026arXiv260315766F/abstract) |

## Suggested Further Reading

Method references:

- [Townsend and Teitler 2013, GYRE](https://ui.adsabs.harvard.edu/abs/2013MNRAS.435.3406T/abstract)
- [Paxton et al. 2019, MESA V](https://ui.adsabs.harvard.edu/abs/2019ApJS..243...10P/abstract)
- [Anderson et al. 2016, pulsation-convection coupling and Cepheid instability-strip edges](https://www.aanda.org/articles/aa/full_html/2016/07/aa28031-15/aa28031-15.html)

Pulsation and P-L references:

- [Smolec et al. 2026, MESA Cepheid grid III](https://arxiv.org/abs/2603.26111)
- [Bono et al. 1999, theoretical Cepheid P-L, P-C, and P-L-C relations](https://ui.adsabs.harvard.edu/abs/1999ApJ...512..711B/abstract)
- [Espinoza-Arancibia et al. 2022, period change rates of LMC Cepheids using MESA](https://ui.adsabs.harvard.edu/abs/2022MNRAS.517.1538E/abstract)
