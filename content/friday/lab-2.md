---
weight: 3
title: "Lab 2: Linear Analysis in GYRE vs LNA (from RSP)"
linkTitle: Lab 2
---

*Lab written by: Lynn Buchele (lead TA), Ebraheem Farag (lecturer), Mathijs Vanrespaille, Sofia Mesini, and Andy Santarelli*

## Background

In lab 1, we evolved a star through the instability strip and used GYRE (on-the-fly within MESA) to calculate the expected periods and growth rates of the fundamental radial mode $(l = 0, n = 0)$. In the next lab, we'll use MESA to further evolve one model and see the pulsations develop. However, we want to choose a model where the pulsations will actually be excited and then settle into a nonlinear state. We could use the output of GYRE to determine this, but GYRE's non-adiabatic calculations use some approximations that aren't necessarily valid for Cepheid stars.

Specifically, the GYRE setup we used in Lab 1 uses the frozen-convection approximation, which assumes that the oscillations do not perturb the convective flux. This approximation is most reasonable when convection carries little of the local flux, or when the coupling between convection and pulsation is weak. It becomes less reliable near the cool edge of the instability strip and in large-amplitude Cepheid pulsations, where convection can contribute to the driving and damping of the mode.

To account for this, we’ll now use a different pulsation tool included in MESA: the Radial Stellar Pulsations (RSP) code. Specifically, we'll use RSP's linear non-adiabatic functionality (LNA, sometimes also called LINA). In an LNA calculation, MESA perturbs a static envelope model with small-amplitude radial oscillations and reports the mode periods and growth rates without evolving the full nonlinear pulsation. This makes RSP-LNA a useful bridge between the GYRE results from Lab 1 and the nonlinear RSP/TDC evolution we will run in Lab 3. We will also be constructing a graph that shows the period-luminosity relationship that makes Cepheid stars so important for measuring astronomical distances.

## Science Goals

1. Find a model where pulsations are expected to be excited in the fundamental radial mode.
2. Determine the period-luminosity relation from our models.
3. Check the agreement between GYRE non-adiabatic calculations and RSP-LNA.

## MESA Goals

1. Use RSP's linear analysis tool to determine both periods and growth rates of the fundamental and first overtone modes.
2. Bonus: Learn how to use simple bash scripts to automate running MESA with many different parameters.

## Lab Directions

For this lab we’ll be using the histories and saved models from Lab 1. If your Lab 1 run completed, use your own `history.data` file and saved `.mod` files. If your run did not complete, use the [Lab 1 history file solutions](https://drive.google.com/drive/folders/1LUQkr654JLP1oKbPrYkLx-JUfL7-8bKz?usp=share_link) and open the solution `history.data` file for your initial mass. You should also grab the saved MESA model from your track, found in the [Lab 1 mod file solutions](https://drive.google.com/drive/folders/1jBEtn-JCkOq15l9cT3Z_L_jecpIAqeKs?usp=share_link), which are zipped by mass.

As an optional shortcut, the [Lab 1 GYRE file solutions](https://drive.google.com/drive/folders/1woaPSSlIvNQADA5Eg-SGO0N11gXHa-S2?usp=share_link) provide a compact `gyre_in_mesa.data` file for each initial mass. This compact file contains the columns `model_number`, `star_mass`, `X`, `Z`, `Teff`, `L`, and the period and growth information for the fundamental, first-overtone, and second-overtone modes. The `F_period`, `O1_period`, and `O2_period` columns correspond to the same GYRE periods from the full history file, but they are set to `-1` when that mode was not unstable. The `F_logKE_per_cycle`, `O1_logKE_per_cycle`, and `O2_logKE_per_cycle` columns are `2*growth` for unstable modes and `-1` otherwise. If you are using these compact files, use `L`, `F_period`, and `F_logKE_per_cycle` for the spreadsheet, and use `star_mass`, `X`, `Z`, and `Teff` when setting up RSP.

### Setting up

Recall that in lab 1 we saved the GYRE results for the fundamental radial mode and the first and second overtones in the history file. We'll now use that information to look for models where we expect pulsations in the fundamental mode to be excited. These are the modes with positive growth rates.

For the fundamental-mode model choice, use a model where the fundamental mode has positive growth and is growing faster than the second overtone: `F_growth > 0` and `F_growth > O2_growth`. If you are using the compact `gyre_in_mesa.data` table, this means `F_logKE_per_cycle > 0` and `F_logKE_per_cycle > O2_logKE_per_cycle`. For a first-overtone comparison, use the analogous condition `O1_growth > 0` and `O1_growth > O2_growth`, or `O1_logKE_per_cycle > 0` and `O1_logKE_per_cycle > O2_logKE_per_cycle` in the compact table. This extra check is useful because the GYRE calculation does not include the same eddy-viscous damping of overtone modes that we will use in RSP.

#### Task: Find a model and add your information to the spreadsheet

Look through your history file from lab 1 to find a model with `F_growth > 0` and `F_growth > O2_growth`. If you are using the compact `gyre_in_mesa.data` solution table instead, look for an entry where `F_logKE_per_cycle > 0` and `F_logKE_per_cycle > O2_logKE_per_cycle`. Please add the luminosity, GYRE F period, and GYRE F growth information to [this spreadsheet](https://docs.google.com/spreadsheets/d/1dVK0vpzgsAy0S7OG-qMyJlmwItwbp1JeB8B-xScV8WI/edit?usp=drive_link). From a full `history.data` file, use `luminosity`, `F_period`, and `F_growth`. From the compact `gyre_in_mesa.data` file, use `L`, `F_period`, and `F_logKE_per_cycle`. Please also add your name or initials in the first column so you can find your data again. Although not necessary for the spreadsheet, you should also make a note of the model number you chose.

As more people add their models, we should see a clear relationship between the period and luminosity values.

#### Task: Set up RSP work directory

Now that we have the results from GYRE in the spreadsheet, we want to get values from RSP-LNA as a comparison. Although we are using the results of lab 1, we want to create a new working directory since we'll be using different inlists to run RSP. You can find the [starting working directory here](https://drive.google.com/file/d/1MFZ4UsVcrvNBqcccYJmqZQhli_A8DGjP/view?usp=share_link).

Download and unzip this file into a new working directory (not into your lab 1 working directory).

### Set up RSP inlist

There are a few inlist parameters you will need to change in `inlist_rsp_Cepheid`. The place for each addition is marked with `!!!`. If you wish to test your skills at reading MESA documentation, take a moment now to search the documentation to determine for yourself what needs to be changed. Otherwise use the hints for each section provided in the drop downs.

#### Task: Set up the `star_job` inlist section

Add the control necessary to use RSP to the `star_job` section of the inlist. RSP does not read in a model and so please also set the starting model number to match the model whose information you added to the spreadsheet. This does not change the run itself, but it makes bookkeeping easier (and could be useful if you attempt the bonus task).

{{< details title="`star_job` parameters" closed="true" >}}

These are the controls which should be set in the `star_job` section of `inlist_rsp_Cepheid`.

```fortran
      create_RSP_model = .true.

      set_initial_model_number = .true.
      initial_model_number = ! Your model number here
```

{{< /details >}}

For consistency with the GYRE results obtained in lab 1, we keep the same settings in both the `eos` and `kap` sections of the inlist. We do however wish to turn on the colors module.

#### Task: Turn on the `colors` module

We will be using the V and I band magnitudes to compute an additional parameter. Fortunately (as you learned on Monday) we can do this by enabling the `colors` module.

{{< details title="`colors` parameters" closed="true" >}}

Since the bands we want are in the default colors list, we only need to add one flag to the inlist section.

```none
&colors
   use_colors = .true.
/ ! end of colors namelist
```

{{< /details >}}

#### Task: Set up the `controls` inlist section

Most of the inlist parameters used by RSP are found in the `controls` section of the inlist. Take a minute to look at the documentation of these controls [found here](https://docs.mesastar.org/en/26.4.1/reference/controls.html#radial-stellar-pulsations-rsp).

The first few controls are marked as "must set". This is because, rather than taking a full stellar model as GYRE does, RSP uses the stellar mass, luminosity, effective temperature, and envelope composition to build a static model of the stellar envelope.

The next set of controls change the parameters of the convection model which will be discussed by Eb in the lecture introducing lab 3. Most of these we will leave set to their default values. However, we need to set the mixing length parameter used by RSP (`RSP_alfa`) to match our evolutionary models constructed in lab 1.

The only other RSP control we will change is `RSP_max_num_periods` which we will set to 0. This is because we are only using RSP to perform the LNA analysis and not to evolve the non-linear pulsations.

Using the model you chose from Lab 1, set the parameters in the `controls` section of `inlist_rsp_Cepheid` using the values from the model you added to the spreadsheet. Use the values of `photosphere_X` and `photosphere_Z` to set the composition.

{{< details title="`controls` parameters" closed="true" >}}

```fortran
    !!! Set parameters using your model to build RSP envelope
    RSP_mass =
    RSP_Teff =
    RSP_L =

    !!! Set using photosphere_X and photosphere_Z
    RSP_X =
    RSP_Z =

    !!! Set to match the mixing_length_alpha from lab 1 inlist
    RSP_alfa =    

    !!! Run only LNA
    RSP_max_num_periods = 0 
```

{{< /details >}}

> [!NOTE]
> A few final notes:
>
> 1. Because we have mass loss turned on, the mass of each model will not be the initial mass we started with in lab 1.
> 2. We should check that the photospheric abundances are representative of the composition in the envelope. You can do this by visually inspecting the saved model (`.mod` file) which includes the abundance profiles of all isotopes throughout the star. Using the `RSP_X` and `RSP_Z` values, determine the corresponding Y value (recall that X + Y + Z = 1).
Check that, in the outer regions of the model, the `RSP_X` value you entered matches the `h1` value and that your calculated value of Y matches the `he4` value.
> 3. Double check that you are inputting your values in the units expected by RSP: mass in Msun, Teff in K, L in Lsun, X and Z as mass fractions.

### Run RSP LNA

#### Task: Once you have set necessary inlist controls, run MESA in the normal way

> [!TIP]
> Since this is a new working directory, don't forget to compile MESA before calling it.

{{< details title="Understanding potential error messages" closed="true" >}}

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

then try following the suggestion made in the error message and increase `RSP_T_anchor_tolerance` to `1d-4`. If this still doesn't work, then you are likely trying to build a model outside of the regime that RSP's model builder can handle. Please pick another model and try again.

{{< /details >}}

If you have tried two models and have not gotten RSP to converge, consult the tables below. For the main Lab 2 RSP exercise, Table 1 gives one RSP-positive fallback model per available initial mass. For the Lab 3 nonlinear run, Table 2 gives the shared starting model list and shows the RSP-LNA cross-checks for those exact model numbers.

{{< details title="Shared Lab 2 and Lab 3 model tables" closed="true" >}}

These tables give two different fallback lists. Table 1 is the Lab 2/RSP-oriented list: one model per available initial mass where RSP-LNA built an envelope and returned a positive fundamental-mode growth rate. Use it if you need a model that should work cleanly for the Lab 2 RSP-LNA exercise.

Table 2 is the Lab 3/nonlinear-oriented list: one selected saved model per available initial mass, chosen from the redder side of the instability strip. For the Lab 3 nonlinear runs, a useful starting point is often about 10-30% in from the red edge, where the fundamental mode is favored but the model is not sitting exactly on the edge of stability. These are the models used for the Lab 3 nonlinear sample. The corresponding `.mod` files are available in the [Lab 3 nonlinear-start model files](https://drive.google.com/file/d/1bTVVwBIyBsIVBZUVmIxXKwcFWXTSjcUj/view?usp=share_link). The RSP columns show what happened when those exact model numbers were run through the Lab 2 RSP-LNA workflow, so the RSP growth rate is not positive for every listed model.

That difference is part of the point: different linear checks can classify the same saved stellar model differently, especially near the red edge where convection matters. RSP builds an envelope model with its own surface optical depth, outer boundary condition, and convection/pulsation parameters, so its envelope is not identical to the full MESA star used for the GYRE calculation. RSP also includes eddy-viscous damping, while the GYRE calculation used in Lab 1 does not. If `RSP_alfam` were set to `0d0`, the RSP instability strip might widen and look more like the GYRE result, but differences are still expected because the envelope models and boundary conditions are not identical.

No selected model was found under these filters for initial masses 3.0-3.8 or 9.5-10.0 Msun. If your group has one of those masses, ask a TA whether to use the nearest listed mass or a different model from the Lab 1 solution set.

#### Table 1: Lab 2 RSP-positive fallback model choices

| Minit | model | M | Teff | L | GYRE P0 | GYRE growth | RSP P0 | RSP growth | classification |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 3.9 | 263 | 3.8621 | 5913 | 983 | 3.1975 | 0.006348 | 3.2931 | 0.0045231 | GYRE and RSP unstable |
| 4 | 293 | 3.9598 | 6087 | 1102 | 3.1354 | 0.00095675 | 3.2038 | 0.0098389 | GYRE and RSP unstable |
| 4.1 | 367 | 4.0519 | 6044 | 1283 | 3.592 | 0.001221 | 3.679 | 0.012718 | GYRE and RSP unstable |
| 4.2 | 383 | 4.1483 | 6020 | 1420 | 3.9063 | 0.0015891 | 4.0032 | 0.014537 | GYRE and RSP unstable |
| 4.3 | 364 | 4.2452 | 5994 | 1559 | 4.2225 | 0.0018294 | 4.334 | 0.016316 | GYRE and RSP unstable |
| 4.4 | 402 | 4.3426 | 6000 | 1702 | 4.4635 | 0.00040692 | 4.5815 | 0.017957 | GYRE and RSP unstable |
| 4.5 | 374 | 4.4397 | 5987 | 1853 | 4.7602 | 0.00013668 | 4.8906 | 0.019819 | GYRE and RSP unstable |
| 4.6 | 354 | 4.5367 | 5933 | 2003 | 5.1685 | 0.0025748 | 5.3257 | 0.021655 | GYRE and RSP unstable |
| 4.7 | 330 | 4.6327 | 5905 | 2172 | 5.5516 | 0.0037255 | 5.7264 | 0.023832 | GYRE and RSP unstable |
| 4.8 | 322 | 4.7304 | 5869 | 2333 | 5.9424 | 0.005508 | 6.1415 | 0.025365 | GYRE and RSP unstable |
| 4.9 | 319 | 4.828 | 5917 | 2516 | 6.0752 | 0.0001233 | 6.2665 | 0.027502 | GYRE and RSP unstable |
| 5 | 319 | 4.9248 | 5908 | 2705 | -1 | -1 | 6.616 | 0.02938 | RSP unstable only |
| 5.1 | 315 | 5.0232 | 5823 | 2893 | 7.0449 | 0.0068269 | 7.3051 | 0.031687 | GYRE and RSP unstable |
| 5.2 | 320 | 5.118 | 5759 | 3095 | 7.6636 | 0.012554 | 7.9758 | 0.032409 | GYRE and RSP unstable |
| 5.3 | 320 | 5.2169 | 5870 | 3316 | -1 | -1 | 7.7654 | 0.035289 | RSP unstable only |
| 5.4 | 318 | 5.313 | 5842 | 3539 | -1 | -1 | 8.2608 | 0.038167 | RSP unstable only |
| 5.5 | 331 | 5.4104 | 5737 | 3755 | 8.8202 | 0.011012 | 9.2089 | 0.039993 | GYRE and RSP unstable |
| 5.6 | 317 | 5.5072 | 5761 | 4019 | 9.1116 | 0.0086149 | 9.4957 | 0.044372 | GYRE and RSP unstable |
| 5.7 | 321 | 5.6043 | 5764 | 4235 | 9.3989 | 0.0061932 | 9.7971 | 0.04594 | GYRE and RSP unstable |
| 5.8 | 323 | 5.7023 | 5753 | 4483 | 9.8208 | 0.006851 | 10.249 | 0.048132 | GYRE and RSP unstable |
| 5.9 | 325 | 5.799 | 5714 | 4747 | 10.447 | 0.011745 | 10.936 | 0.050721 | GYRE and RSP unstable |
| 6 | 323 | 5.8961 | 5694 | 5026 | 10.988 | 0.013179 | 11.522 | 0.053203 | GYRE and RSP unstable |
| 6.1 | 321 | 5.9927 | 5644 | 5301 | 11.747 | 0.019852 | 12.358 | 0.053267 | GYRE and RSP unstable |
| 6.2 | 314 | 6.0908 | 5570 | 5555 | 12.684 | 0.028702 | 13.422 | 0.050119 | GYRE and RSP unstable |
| 6.3 | 321 | 6.1855 | 5646 | 5888 | 12.575 | 0.018826 | 13.238 | 0.059829 | GYRE and RSP unstable |
| 6.4 | 319 | 6.2836 | 5683 | 6224 | 12.743 | 0.0053259 | 13.4 | 0.063272 | GYRE and RSP unstable |
| 6.5 | 320 | 6.3797 | 5664 | 6505 | 13.278 | 0.013211 | 13.969 | 0.065611 | GYRE and RSP unstable |
| 6.6 | 323 | 6.4764 | 5629 | 6818 | 13.997 | 0.019002 | 14.768 | 0.067809 | GYRE and RSP unstable |
| 6.7 | 316 | 6.5728 | 5668 | 7191 | 14.154 | 0.0073563 | 14.905 | 0.069581 | GYRE and RSP unstable |
| 6.8 | 322 | 6.669 | 5721 | 7549 | -1 | -1 | 14.842 | 0.068924 | RSP unstable only |
| 6.9 | 331 | 6.7664 | 5614 | 7839 | 15.485 | 0.017834 | 16.376 | 0.075812 | GYRE and RSP unstable |
| 7 | 331 | 6.8678 | 5579 | 8165 | 16.251 | 0.025744 | 17.236 | 0.076741 | GYRE and RSP unstable |
| 7.1 | 325 | 6.9624 | 5608 | 8546 | 16.438 | 0.016759 | 17.41 | 0.079849 | GYRE and RSP unstable |
| 7.2 | 327 | 7.0588 | 5586 | 8911 | 17.136 | 0.020272 | 18.178 | 0.082633 | GYRE and RSP unstable |
| 7.3 | 323 | 7.1543 | 5558 | 9293 | 17.945 | 0.026043 | 19.08 | 0.085136 | GYRE and RSP unstable |
| 7.4 | 319 | 7.2509 | 5564 | 9758 | 18.484 | 0.02395 | 19.66 | 0.088694 | GYRE and RSP unstable |
| 7.5 | 324 | 7.3478 | 5529 | 10091 | 19.305 | 0.032733 | 20.599 | 0.08936 | GYRE and RSP unstable |
| 7.6 | 324 | 7.4456 | 5530 | 10508 | 19.815 | 0.031433 | 21.147 | 0.092799 | GYRE and RSP unstable |
| 7.7 | 329 | 7.541 | 5545 | 10968 | 20.198 | 0.026905 | 21.535 | 0.095256 | GYRE and RSP unstable |
| 7.8 | 320 | 7.6352 | 5489 | 11439 | 21.574 | 0.041431 | 23.12 | 0.097309 | GYRE and RSP unstable |
| 7.9 | 329 | 7.7366 | 5587 | 11863 | 20.649 | 0.0040072 | 22.018 | 0.097717 | GYRE and RSP unstable |
| 8 | 315 | 7.8291 | 5573 | 12356 | 21.442 | 0.008104 | 22.886 | 0.1012 | GYRE and RSP unstable |
| 8.1 | 325 | 7.9271 | 5479 | 12756 | 23.298 | 0.041293 | 25.043 | 0.10603 | GYRE and RSP unstable |
| 8.2 | 321 | 8.0199 | 5497 | 13292 | 23.66 | 0.032879 | 25.443 | 0.10896 | GYRE and RSP unstable |
| 8.3 | 327 | 8.1161 | 5483 | 13762 | 24.437 | 0.037067 | 26.308 | 0.11148 | GYRE and RSP unstable |
| 8.4 | 318 | 8.2114 | 5485 | 14295 | 25.039 | 0.035301 | 26.984 | 0.11367 | GYRE and RSP unstable |
| 8.5 | 322 | 8.3082 | 5449 | 14752 | 26.192 | 0.049739 | 28.303 | 0.11628 | GYRE and RSP unstable |
| 8.6 | 260 | 8.4331 | 5462 | 15202 | 26.347 | 0.039604 | 28.486 | 0.11675 | GYRE and RSP unstable |
| 8.7 | 325 | 8.5034 | 5448 | 15836 | 27.438 | 0.045698 | 29.714 | 0.12188 | GYRE and RSP unstable |
| 8.8 | 262 | 8.6181 | 5433 | 16447 | 28.21 | 0.0060611 | 30.849 | 0.125 | GYRE and RSP unstable |
| 8.9 | 264 | 8.7109 | 5431 | 17044 | 29.138 | 0.048665 | 31.685 | 0.12831 | GYRE and RSP unstable |
| 9 | 264 | 8.806 | 5394 | 17670 | 30.663 | 0.063515 | 33.417 | 0.1296 | GYRE and RSP unstable |
| 9.1 | 268 | 8.9059 | 5520 | 18326 | -1 | -1 | 31.118 | 0.13203 | RSP unstable only |
| 9.2 | 271 | 8.9985 | 5486 | 18983 | 30.18 | 0.011854 | 32.785 | 0.13782 | GYRE and RSP unstable |
| 9.3 | 272 | 9.0904 | 5394 | 19628 | 32.93 | 0.058459 | 36.082 | 0.14188 | GYRE and RSP unstable |
| 9.4 | 264 | 9.1896 | 5399 | 20300 | 33.533 | 0.058646 | 36.799 | 0.14391 | GYRE and RSP unstable |

#### Table 2: Lab 3 nonlinear-start model choices with RSP-LNA cross-checks

| Minit | model | M | Teff | L | selected P0 | selected growth | GYRE P0 | GYRE growth | RSP P0 | RSP growth | classification |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 3.9 | 358 | 3.854 | 5553 | 1049 | 4.2104 | 0.002001 | 4.2128 | 0.014782 | 4.5117 | -0.012437 | GYRE unstable only |
| 4 | 405 | 3.9511 | 5522 | 1167 | 4.6231 | 0.0039758 | 4.626 | 0.016994 | 4.9611 | -0.013428 | GYRE unstable only |
| 4.1 | 408 | 4.0477 | 5488 | 1287 | 5.055 | 0.0042498 | 5.0591 | 0.019386 | 5.4342 | -0.014506 | GYRE unstable only |
| 4.2 | 406 | 4.1454 | 5517 | 1413 | 5.2906 | 0.0073861 | 5.2699 | 0.013798 | 5.6354 | -0.010849 | GYRE unstable only |
| 4.3 | 383 | 4.2429 | 5480 | 1541 | 5.7269 | 0.013038 | 5.736 | 0.022091 | 6.1381 | -0.012183 | GYRE unstable only |
| 4.4 | 417 | 4.3406 | 5461 | 1674 | 6.1264 | 0.0084876 | 6.1376 | 0.024043 | 6.572 | -0.012503 | GYRE unstable only |
| 4.5 | 382 | 4.4381 | 5490 | 1822 | 6.3553 | 0.024002 | 6.3673 | 0.020321 | 6.7845 | -0.0082525 | GYRE unstable only |
| 4.6 | 362 | 4.5354 | 5434 | 1967 | 6.9485 | 0.014852 | 6.9614 | 0.027886 | 7.4515 | -0.01226 | GYRE unstable only |
| 4.7 | 337 | 4.6313 | 5358 | 2127 | 7.7118 | 0.014443 | 7.732 | 0.033365 | 8.3455 | -0.0184 | GYRE unstable only |
| 4.8 | 326 | 4.7295 | 5492 | 2302 | 7.4145 | 0.040702 | 7.4426 | 0.027576 | 7.8946 | -0.0026528 | GYRE unstable only |
| 4.9 | 325 | 4.8268 | 5450 | 2480 | 8.0179 | 0.018694 | 8.0449 | 0.031021 | 8.5651 | -0.0047996 | GYRE unstable only |
| 5 | 324 | 4.9236 | 5400 | 2661 | 8.6847 | 0.030977 | 8.726 | 0.035557 | 9.3288 | -0.0082402 | GYRE unstable only |
| 5.1 | 320 | 5.0218 | 5265 | 2834 | 10.08 | 0.052909 | 9.9972 | 0.045788 | 10.844 | -0.02269 | GYRE unstable only |
| 5.2 | 245 | 5.1333 | 5225 | 2665 | 9.5959 | 0.0054239 | 9.6128 | 0.042088 | 10.513 | -0.028451 | GYRE unstable only |
| 5.3 | 248 | 5.2322 | 5382 | 2858 | 8.9897 | 0.05625 | 8.9719 | 0.0245 | 9.6389 | -0.0096096 | GYRE unstable only |
| 5.4 | 320 | 5.3124 | 5484 | 3491 | 9.9291 | 0.1059 | 9.8743 | 0.032568 | 10.474 | 0.011674 | GYRE and RSP unstable |
| 5.5 | 251 | 5.427 | 5275 | 3254 | 10.573 | 0.037957 | 10.597 | 0.043828 | 11.448 | -0.018105 | GYRE unstable only |
| 5.6 | 322 | 5.5062 | 5317 | 3927 | 12.083 | 0.10817 | 11.958 | 0.047399 | 12.862 | -0.0055921 | GYRE unstable only |
| 5.7 | 248 | 5.6213 | 5230 | 3689 | 11.891 | 0.05177 | 11.91 | 0.050428 | 12.901 | -0.020533 | GYRE unstable only |
| 5.8 | 251 | 5.72 | 5296 | 3911 | 11.745 | 0.062656 | 11.792 | 0.046305 | 12.685 | -0.011123 | GYRE unstable only |
| 5.9 | 330 | 5.7985 | 5292 | 4654 | 13.561 | 0.025517 | 13.635 | 0.056531 | 14.664 | -0.0028174 | GYRE unstable only |
| 6 | 336 | 5.8957 | 5294 | 4931 | 14.053 | 0.041635 | 14.148 | 0.058172 | 15.218 | -0.00031883 | GYRE unstable only |
| 6.1 | 249 | 6.012 | 5228 | 4661 | 13.889 | 0.059128 | 13.936 | 0.056957 | 15.061 | -0.014597 | GYRE unstable only |
| 6.2 | 246 | 6.1102 | 5195 | 4918 | 14.755 | 0.073988 | 14.8 | 0.061648 | 16.029 | -0.017209 | GYRE unstable only |
| 6.3 | 328 | 6.1851 | 5233 | 5759 | 16.391 | 0.077703 | 16.391 | 0.068869 | 17.696 | -0.0022234 | GYRE unstable only |
| 6.4 | 323 | 6.2831 | 5175 | 6056 | 17.802 | 0.15068 | 17.681 | 0.077086 | 19.172 | -0.0095706 | GYRE unstable only |
| 6.5 | 324 | 6.3794 | 5237 | 6356 | 17.523 | 0.1441 | 17.439 | 0.072464 | 18.829 | 0.0025755 | GYRE and RSP unstable |
| 6.6 | 331 | 6.476 | 5111 | 6618 | 19.566 | 0.024603 | 19.663 | 0.086901 | 21.393 | -0.016861 | GYRE unstable only |
| 6.7 | 322 | 6.5724 | 5115 | 6966 | 20.508 | 0.065634 | 20.297 | 0.088853 | 22.076 | -0.01428 | GYRE unstable only |
| 6.8 | 330 | 6.6685 | 5099 | 7293 | 21.366 | 0.097282 | 21.177 | 0.092805 | 23.051 | -0.014704 | GYRE unstable only |
| 6.9 | 338 | 6.7661 | 5138 | 7619 | 21.028 | 0.036579 | 21.139 | 0.090034 | 22.964 | -0.003888 | GYRE unstable only |
| 7 | 337 | 6.8676 | 5123 | 7931 | 22.006 | 0.09578 | 21.924 | 0.093533 | 23.844 | -0.0054647 | GYRE unstable only |
| 7.1 | 250 | 6.9844 | 5015 | 7855 | 23.684 | 0.20211 | 23.355 | 0.10115 | 25.537 | -0.024306 | GYRE unstable only |
| 7.2 | 335 | 7.0584 | 4934 | 8514 | 27.117 | 0.092097 | 26.7 | 0.12206 | 29.191 | -0.03268 | GYRE unstable only |
| 7.3 | 331 | 7.1539 | 4955 | 8920 | 27.551 | 0.077469 | 27.053 | 0.12133 | 29.594 | -0.027084 | GYRE unstable only |
| 7.4 | 247 | 7.2753 | 4902 | 9037 | 28.158 | 0.10547 | 27.545 | 0.030795 | 30.962 | -0.034851 | GYRE unstable only |
| 7.5 | 247 | 7.3715 | 4866 | 9451 | 30.562 | 0.1905 | 30.05 | 0.13071 | 32.922 | -0.036777 | GYRE unstable only |
| 7.6 | 333 | 7.4452 | 4895 | 10035 | 31.284 | 0.11722 | 30.699 | 0.13612 | -- | -- | GYRE unstable only |
| 7.7 | 335 | 7.5406 | 4889 | 10478 | 32.444 | 0.13049 | 31.908 | 0.14213 | 34.84 | -0.029629 | GYRE unstable only |
| 7.8 | 333 | 7.6346 | 4904 | 11049 | 33.29 | 0.12951 | 32.639 | 0.14298 | 35.749 | -0.0223 | GYRE unstable only |
| 7.9 | 337 | 7.7362 | 4878 | 11279 | 34.351 | 0.14845 | 33.492 | 0.14235 | 36.882 | -0.026687 | GYRE unstable only |
| 8 | 247 | 7.8529 | 4869 | 11810 | 34.674 | 0.0051594 | 34.935 | 0.15105 | -- | -- | GYRE unstable only |
| 8.1 | 338 | 7.9267 | 4913 | 12322 | 35.018 | 0.076185 | 34.73 | 0.14767 | -- | -- | GYRE unstable only |
| 8.2 | 328 | 8.0193 | 4933 | 12882 | 35.755 | 0.15895 | 35.265 | 0.14797 | 38.714 | -0.010019 | GYRE unstable only |
| 8.3 | 335 | 8.1155 | 4821 | 13261 | 40.443 | 0.18995 | 39.751 | 0.17043 | 43.379 | -0.02561 | GYRE unstable only |
| 8.4 | 326 | 8.2107 | 4872 | 13828 | 39.582 | 0.2245 | 38.936 | 0.16521 | 42.793 | -0.011978 | GYRE unstable only |
| 8.5 | 328 | 8.3075 | 4843 | 14273 | 41.582 | 0.26344 | 40.847 | 0.17344 | 44.773 | -0.016102 | GYRE unstable only |
| 8.6 | 336 | 8.4078 | 4835 | 14753 | 42.817 | 0.24125 | 41.895 | 0.17485 | -- | -- | GYRE unstable only |
| 8.7 | 333 | 8.5029 | 4879 | 15318 | 42.194 | 0.30491 | 41.374 | 0.17068 | 45.575 | -0.0057579 | GYRE unstable only |
| 8.8 | 325 | 8.5939 | 4845 | 15842 | 44.594 | 0.29118 | 43.564 | 0.17941 | 48.009 | -0.0062753 | GYRE unstable only |
| 8.9 | 328 | 8.6872 | 4925 | 16484 | 42.687 | 0.30096 | 41.879 | 0.16892 | 46.191 | 0.0080752 | GYRE and RSP unstable |
| 9 | 331 | 8.7831 | 4830 | 16931 | 47.224 | 0.31013 | 46.054 | 0.18638 | 50.89 | -0.0030531 | GYRE unstable only |
| 9.1 | 331 | 8.8803 | 4883 | 17606 | 46.332 | 0.34419 | 45.322 | 0.18184 | 50.096 | 0.0035209 | GYRE and RSP unstable |
| 9.2 | 264 | 8.9989 | 4846 | 18752 | 48.428 | 0.036197 | 49.03 | 0.19997 | 54.352 | 0.0056037 | GYRE and RSP unstable |
| 9.3 | 267 | 9.0907 | 4827 | 19394 | 51.824 | 0.39692 | 51.055 | 0.2069 | -- | -- | GYRE unstable only |
| 9.4 | 330 | 9.1655 | 4871 | 19250 | 49.314 | 0.31887 | 48.503 | 0.19029 | 53.701 | 0.0098855 | GYRE and RSP unstable |

#### HR diagram comparison

The HR diagram below shows both table lists on top of the full saved-model grid. Circles are Table 1 and diamonds are Table 2. Point color shows the fundamental-mode instability classification for the exact saved model.

<figure style="margin: 1rem 0;">
  <a href="../plots/lab2/13_hr_table1_vs_table2_lab2_lab3_selected_models.pdf">
    <img src="../plots/lab2/13_hr_table1_vs_table2_lab2_lab3_selected_models.png" alt="Lab 2 and Lab 3 model-choice tables on the HR diagram" style="width: 100%; height: auto;">
  </a>
</figure>

{{< /details >}}

### Understanding the output of a successful RSP LNA run

Once you have found a set of model parameters where RSP successfully builds an envelope model your output will look something like:

```none
 read inlist_rsp_Cepheid
 create initial RSP model
            P(days)         growth
  0       0.12013E+02    -0.36487E-01
  1       0.74475E+01    -0.22923E+00
  2       0.52822E+01    -0.34390E+00
                                                     nz         150
                                                  T(nz)    1.9999953967758652D+06
                                          L_center/Lsun    2.5720000000000000D+03
                                          R_center/Rsun    5.1733518944278432D+00
                                          M_center/Msun    3.3169181802306444D+00
                                              L(1)/Lsun    2.5720000000000000D+03
                                              R(1)/Rsun    6.4194412331309621D+01
                                              M(1)/Msun    4.4157999999999999D+00
                                               v(1)/1d5    1.0000000000000001D-01
                                             tau_factor    1.5000000000000000D-03
                                               tau_base    6.6666666666666663D-01

                               set_initial_model_number           0
                             set_initial_number_retries           0
 net name o18_and_ne22.net
 RSP_flag T
 v_flag T
                                             tau_factor    1.5000000000000000D-03
                                           xmstar/mstar    2.4885226227848981D-01
                                             xmstar (g)    2.1850274571600221D+33
                                           M_center (g)    6.5953928498684284D+33
                                            xmstar/Msun    1.0988818197693553D+00
                                          M_center/Msun    3.3169181802306444D+00
                                          R_center (cm)    3.5991009129534375D+11
                                          R_center/Rsun    5.1733518944278245D+00
                                           core density    3.3773027106505087D-02
                                          L_center/Lsun    2.5720000000000000D+03
 kap_option gs98
 kap_CO_option gs98_co
 kap_lowT_option lowT_fa05_gs98
                                        OMP_NUM_THREADS          16


 Wesenheit Index:       -6.0523627020680895     

```

This is then followed by the usual MESA terminal output header, and one model's worth of output before MESA terminates with `termination code: reached max number of periods`.

Of this information, the part we are most interested in is the period and growth rate information printed right after `create initial RSP model`. RSP indexes the modes in order of decreasing period (increasing frequency). In our case, the mode labeled 0 should be the fundamental radial mode, followed by the first and second overtones (modes 1 and 2).

### Wesenheit Index - Period Relationship

As you will see in the shared spreadsheet, the period luminosity relationship has some scatter. This is because the underlying relationship is actually between period, luminosity and *color*. We can collapse the color dependence by using the Wesenheit index:

$ W_{VI} = I - R(V-I), $

where $V$ and $I$ are the absolute magnitudes in the V and I bands, respectively, and $R$ is a constant that parameterizes the color dependence. For a more detailed discussion of this approach take a look at the appendices of [Madore and Freedman 1991](https://ui.adsabs.harvard.edu/abs/1991PASP..103..933M/abstract) or [Madore 1982](https://ui.adsabs.harvard.edu/abs/1982ApJ...253..575M/abstract). We'll use the value $R=1.55$ as was used by [Smolec et al 2026](https://arxiv.org/abs/2603.26111).

The provided `run_star_extras` will print the `RSP_W_VI` value to the terminal just before the data from the first time step.

#### Task: Add RSP information to the spreadsheet

Using your terminal output, add your RSP results for the fundamental period, growth rate, and Wesenheit index to the shared spreadsheet (put this on the same line as your GYRE results).

To fill in our diagrams a little bit more, repeat this process (changing the inlist parameters and running RSP LNA) for different timesteps from your lab 1 results.

> [!NOTE]
> Take a look at your original `history.data` file from lab 1. Do you need to change the values of `RSP_X` and `RSP_Z` when running a new model?

You should aim to run 2-3 models. For lab 3, when we'll evolve the pulsations, it's best to start with a model that has a positive growth rate from RSP-LNA. If your first model had a positive growth rate for the fundamental mode, then note down that model number. If the fundamental growth rate was negative, try choosing a model in the middle of the instability strip for your next run (even if the GYRE growth rate was negative).

>[!TIP]
> You can use the png output saved from lab 1 to easily check which models are in the instability strip.

If your second model also has a negative growth rate, consult the tables above. Table 1 lists RSP-positive fallback choices for Lab 2, while Table 2 shows the selected red-edge model set that connects cleanly to the nonlinear Lab 3 sample.

### As the spreadsheet fills in discuss the following questions at your table

- How similar are the periods returned by GYRE and RSP for the same model?
- How similar are the growth rates returned by GYRE and RSP for the same model?
- Compare the period-luminosity relations between the two codes. Are there any major differences?
- How do the period-luminosity relations compare to the period-Wesenheit relations?

{{< details title="Solutions (spoilers!)" closed="true" >}}

These plots come from the full model grid used to check the Lab 2 and Lab 3 model choices. They are not required for the manual part of the lab, but they are useful for seeing what changes when the same saved stellar models are analyzed with GYRE and with RSP-LNA. For GYRE, the fundamental mode is the radial mode with `n_pg = 1`; for RSP, the fundamental mode is mode `0`. The HR agreement plots use the full blue-loop model set from the Lab 1 reference solutions. For the GYRE part of the classification, the relevant mode must have positive growth and must be growing faster than the second overtone. The RSP part is classified from the matching RSP-LNA calculation using positive growth for the same mode only.

The plotter used to generate these figures is available [here](https://drive.google.com/file/d/115PrNza8qip5em7uIh3hk1JE6hXoVeQZ/view?usp=share_link).

#### Instability-strip comparison

<figure style="margin: 1rem 0;">
  <a href="../plots/lab2/09_hr_instability_agreement_all_grid.pdf">
    <img src="../plots/lab2/09_hr_instability_agreement_all_grid.png" alt="Fundamental-mode GYRE/RSP instability agreement across the full grid" style="width: 100%; height: auto;">
  </a>
</figure>

The fundamental-mode plot shows the full blue-loop history grid. The green and orange points together are the GYRE fundamental-mode selection from Lab 1, split by whether the matching RSP-LNA model is also unstable. The blue points are models where only RSP-LNA finds positive fundamental-mode growth. The gray points are the stable/background grid points. RSP is stricter for some of the cooler selected models and extends differently on the hot side, which is why Table 1 is the better fallback list for finishing Lab 2 and Table 2 is the better handoff list for Lab 3.

<figure style="margin: 1rem 0;">
  <a href="../plots/lab2/10_hr_first_overtone_instability_agreement_all_grid.pdf">
    <img src="../plots/lab2/10_hr_first_overtone_instability_agreement_all_grid.png" alt="First-overtone GYRE/RSP instability agreement across the full grid" style="width: 100%; height: auto;">
  </a>
</figure>

The first-overtone comparison is noisier for our purposes. It is useful context, but the nonlinear Lab 3 sample is chosen for fundamental-mode behavior, so the fundamental-mode agreement is the plot to use when choosing models for the next lab.

#### Period-radius relations

<div style="display: grid; gap: 1rem; grid-template-columns: repeat(auto-fit, minmax(18rem, 1fr)); margin: 1rem 0;">
  <figure style="margin: 0;">
    <figcaption><strong>Fundamental mode</strong></figcaption>
    <a href="../plots/lab2/03_fundamental_period_radius_unstable_gyre_rsp.pdf">
      <img src="../plots/lab2/03_fundamental_period_radius_unstable_gyre_rsp.png" alt="Fundamental-mode period-radius relation for unstable GYRE and RSP models" style="width: 100%; height: auto;">
    </a>
  </figure>
  <figure style="margin: 0;">
    <figcaption><strong>First overtone</strong></figcaption>
    <a href="../plots/lab2/04_first_overtone_period_radius_unstable_gyre_rsp.pdf">
      <img src="../plots/lab2/04_first_overtone_period_radius_unstable_gyre_rsp.png" alt="First-overtone period-radius relation for unstable GYRE and RSP models" style="width: 100%; height: auto;">
    </a>
  </figure>
</div>

Both codes recover the expected trend that larger Cepheids have longer pulsation periods. The RSP points use `Rphot`, while the GYRE points use the radius from the Lab 1 stellar model. The sequences are close, but RSP generally gives a somewhat longer period for the same structure.

#### Period-luminosity relations

<div style="display: grid; gap: 1rem; grid-template-columns: repeat(auto-fit, minmax(18rem, 1fr)); margin: 1rem 0;">
  <figure style="margin: 0;">
    <figcaption><strong>Fundamental mode</strong></figcaption>
    <a href="../plots/lab2/14_fundamental_period_luminosity_unstable_gyre_rsp.pdf">
      <img src="../plots/lab2/14_fundamental_period_luminosity_unstable_gyre_rsp.png" alt="Fundamental-mode period-luminosity relation for unstable GYRE and RSP models" style="width: 100%; height: auto;">
    </a>
  </figure>
  <figure style="margin: 0;">
    <figcaption><strong>First overtone</strong></figcaption>
    <a href="../plots/lab2/15_first_overtone_period_luminosity_unstable_gyre_rsp.pdf">
      <img src="../plots/lab2/15_first_overtone_period_luminosity_unstable_gyre_rsp.png" alt="First-overtone period-luminosity relation for unstable GYRE and RSP models" style="width: 100%; height: auto;">
    </a>
  </figure>
</div>

The period-luminosity plots have visible width because temperature matters. The remaining GYRE/RSP offset is mostly a period offset, not a luminosity offset.

#### Period-Wesenheit relations with OGLE

<div style="display: grid; gap: 1rem; grid-template-columns: repeat(auto-fit, minmax(18rem, 1fr)); margin: 1rem 0;">
  <figure style="margin: 0;">
    <figcaption><strong>Fundamental mode</strong></figcaption>
    <a href="../plots/lab2/18_fundamental_period_wesenheit_unstable_gyre_rsp_ogle_overlay.pdf">
      <img src="../plots/lab2/18_fundamental_period_wesenheit_unstable_gyre_rsp_ogle_overlay.png" alt="Fundamental-mode period-Wesenheit relation with OGLE comparison" style="width: 100%; height: auto;">
    </a>
  </figure>
  <figure style="margin: 0;">
    <figcaption><strong>First overtone</strong></figcaption>
    <a href="../plots/lab2/19_first_overtone_period_wesenheit_unstable_gyre_rsp_ogle_overlay.pdf">
      <img src="../plots/lab2/19_first_overtone_period_wesenheit_unstable_gyre_rsp_ogle_overlay.png" alt="First-overtone period-Wesenheit relation with OGLE comparison" style="width: 100%; height: auto;">
    </a>
  </figure>
</div>

These are the main plots to use for the period-Wesenheit comparison. The Wesenheit index folds in color information, so the relation is tighter than the period-luminosity relation and is easier to compare with observed Cepheids. The model sequence is shifted onto the observed plane for comparison, so the vertical offset should not be interpreted as a distance measurement. The useful point is that the slopes and overall trends line up reasonably well.

#### Direct GYRE/RSP ratios

<div style="display: grid; gap: 1rem; grid-template-columns: repeat(auto-fit, minmax(18rem, 1fr)); margin: 1rem 0;">
  <figure style="margin: 0;">
    <figcaption><strong>Fundamental-mode period ratio</strong></figcaption>
    <a href="../plots/lab2/20_period_ratio_F0_gyre_over_rsp_vs_gyre_logP.pdf">
      <img src="../plots/lab2/20_period_ratio_F0_gyre_over_rsp_vs_gyre_logP.png" alt="Fundamental-mode GYRE-over-RSP period ratio as a function of GYRE period" style="width: 100%; height: auto;">
    </a>
  </figure>
  <figure style="margin: 0;">
    <figcaption><strong>Fundamental-mode radius ratio</strong></figcaption>
    <a href="../plots/lab2/22_radius_ratio_F0_lab1_over_rsp_Rphot_vs_gyre_logP.pdf">
      <img src="../plots/lab2/22_radius_ratio_F0_lab1_over_rsp_Rphot_vs_gyre_logP.png" alt="Fundamental-mode Lab 1 radius over RSP Rphot ratio as a function of GYRE period" style="width: 100%; height: auto;">
    </a>
  </figure>
  <figure style="margin: 0;">
    <figcaption><strong>First-overtone period ratio</strong></figcaption>
    <a href="../plots/lab2/21_period_ratio_F1_gyre_over_rsp_vs_gyre_logP.pdf">
      <img src="../plots/lab2/21_period_ratio_F1_gyre_over_rsp_vs_gyre_logP.png" alt="First-overtone GYRE-over-RSP period ratio as a function of GYRE period" style="width: 100%; height: auto;">
    </a>
  </figure>
  <figure style="margin: 0;">
    <figcaption><strong>First-overtone radius ratio</strong></figcaption>
    <a href="../plots/lab2/23_radius_ratio_F1_lab1_over_rsp_Rphot_vs_gyre_logP.pdf">
      <img src="../plots/lab2/23_radius_ratio_F1_lab1_over_rsp_Rphot_vs_gyre_logP.png" alt="First-overtone Lab 1 radius over RSP Rphot ratio as a function of GYRE period" style="width: 100%; height: auto;">
    </a>
  </figure>
</div>

The period-ratio plots show the main systematic difference directly: for many of these models, `P_GYRE / P_RSP` is below one, so RSP gives a longer period for the same saved model. The radius-ratio plots stay very close to one, so the period difference is not mostly caused by using inconsistent radii. It is more likely coming from the different pulsation calculations and the way the RSP envelope model is constructed from the stellar model.

{{< /details >}}

### Bonus task: Batch running RSP

After setting up RSP for several different parameter combinations, you might notice that doing this manually is a little bit tedious (and if you're anything like me, very prone to human error). For the bonus task, you can try your hand at automating these runs. For this, focus first on the RSP information.


Depending on how you're feeling halfway through Friday, there are a few different difficulty levels that you can choose from, see below. Regardless of your chosen difficulty level, once you have your results please add the luminosity, Wesenheit index, RSP period and RSP growth rate data to the shared spreadsheet. When you do this, please add your information at the bottom of the spreadsheet to avoid overwriting other people's values.

#### Option 1: Let me cook

Come up with your own approach to automating this task. After you have a plan, but before starting to write your code, discuss your answers to the following questions with your TA.

{{< details title="Things to consider when automating your MESA RSP LNA run" closed="true" >}}

- How do you plan to extract the relevant parameters from the output of lab 1?
- How do you plan to create the correct inlist for each model?
- How do you plan to loop over all the relevant models?
- What output do you need to save?
- How can you make this output easy to process (i.e., add to the spreadsheet)?
- If you want to also include the Lab 1 GYRE information in your output, how will you match it to the RSP-LNA results?

{{< /details >}}

#### Option 2: Set me on the path

Below, you'll find an outline of one possible approach to solve this problem. Using this outline, create your own implementation of each part of the process from scratch.

{{< details title="One potential approach" closed="true" >}}

- Conveniently, the `.mod` files saved in lab 1 contain the mass, effective temperature, and luminosity for RSP in their filenames. As you saw from the history file, the photosphere values of X and Z (used to set `RSP_X` and `RSP_Z`) remain constant during this part of evolution.
- You can create a bash script which will loop over all the files in the `mod_dir` and parse the file names to get the values needed to run RSP.
- In this loop you can use `shmesa change` to update the relevant inlist parameters `initial_model_number`, `RSP_mass`, `RSP_Teff`, and `RSP_L` before running MESA. This preserves the Lab 1 model number in the output table.
- As you saw in the main lab, RSP prints the period and growth rates to the terminal and we provided code to print the RSP Wesenheit index.
- For the batch run, you will need to write one record of LNA data to an output file for each model. You will need to figure out the control necessary to trigger this output and modify the file opening so that the output is not overwritten when you call MESA again for each new model (the keyword `position` in the fortran `open` call may be useful). You may also want to double check the units of this output.

{{< /details >}}

#### Option 3: Take my hand

Start from these [partially complete solutions](https://drive.google.com/file/d/1YXyy03R6unwUVqn8J1Ej9TOM1ZmYnyoz/view?usp=share_link) which use the method described in the hint above. These are replacement files, not a full work directory: copy `batch_LNA.sh` and `inlist_rsp_Cepheid` into your Lab 2 RSP work directory, and copy `run_star_extras.f90` into `src/run_star_extras.f90`. All the changes you need to make are marked with `!!!`.

#### Option 4: Show me how it's done

{{< details title="Small changes to the solutions files you still need to make" closed="true" >}}

This is a [complete set of solutions](https://drive.google.com/file/d/1q_ieQpw9ggKxSQ-5eoDLMWcuXlMX4hrQ/view?usp=share_link) with comments explaining the code. Read through the code to understand what is happening and then run it using your results from lab 1.

If you use these solutions files directly, you still need to pass the correct path for your `mod_dir` from lab 1 to `batch_LNA.sh`. The supplied script updates `initial_model_number`, `RSP_mass`, `RSP_Teff`, and `RSP_L` from the `.mod` filenames. Set `RSP_X` and `RSP_Z` in `inlist_rsp_Cepheid` to the composition you want to use before launching the bash script using the command `./batch_LNA.sh`. If you get a permissions error simply run `chmod u+x batch_LNA.sh` and try to run the script again.

{{< /details >}}

> [!TIP]
> For options 2-4, your output will be a whitespace-separated table. Most spreadsheet programs (Excel, LibreOffice Calc, GoogleSheets) can import this kind of text file. Then, the columns of this new spreadsheet can easily be copied into the class spreadsheet.

### Bonus task part 2

If you have completed your batch RSP-LNA runs, try to also add the GYRE period and growth rate values to the spreadsheet. **Hint**: Remember, this information is saved in the output of lab 1 and so you don't need to rerun any models.

### Optional: fully automated batch setup

When we did these runs to generate the data for the plots in the lecture slides, we made a few changes to automate a few more things. For those interested, we provide and describe this directory below.

{{< details title="Set up used for fully automated batch runs" closed="true" >}}

The [extended full-solution archive](https://drive.google.com/file/d/1BP5cMCpX6v8kInb3DPGKuNtqABhG-5Oo/view?usp=share_link) shows a more automated version of the batch workflow. It follows the same basic idea as the bonus task, but is set up to run through many saved Lab 1 `.mod` files with less manual editing.

The extended script loops over the saved model files, reads the model number, current mass, effective temperature, and luminosity from each filename, updates the corresponding RSP inlist controls with `shmesa change`, runs RSP-LNA, and appends one output record per successful model. That makes the output easier to join to the Lab 1 GYRE tables and use for comparison plots. You do not need this extended version to complete the lab; it is included as reference code for anyone who wants to see a more automated implementation.

{{< /details >}}

## Suggested Further Reading

Method references:

- [Townsend and Teitler 2013, GYRE](https://ui.adsabs.harvard.edu/abs/2013MNRAS.435.3406T/abstract)
- [Paxton et al. 2019, MESA V](https://ui.adsabs.harvard.edu/abs/2019ApJS..243...10P/abstract)
- [Anderson et al. 2016, pulsation-convection coupling and Cepheid instability-strip edges](https://www.aanda.org/articles/aa/full_html/2016/07/aa28031-15/aa28031-15.html)

Pulsation and P-L references:

- [Smolec et al. 2026, MESA Cepheid grid III](https://arxiv.org/abs/2603.26111)
- [Bono et al. 1999, theoretical Cepheid P-L, P-C, and P-L-C relations](https://ui.adsabs.harvard.edu/abs/1999ApJ...512..711B/abstract)
- [Espinoza-Arancibia et al. 2022, period change rates of LMC Cepheids using MESA](https://ui.adsabs.harvard.edu/abs/2022MNRAS.517.1538E/abstract)
