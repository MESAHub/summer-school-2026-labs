---
weight: 3
title: Lab 2 - Linear Analysis in GYRE vs LNA (from RSP)
linkTitle: Lab 2
---
## Background

In lab 1, we evolved a star through the instability strip and used GYRE (on-the-fly within MESA) to calculate the expected periods and growth rates of the fundamental radial mode $(l = 0, n = 0)$. However, when doing non-adiabatic calculations GYRE uses the frozen convection approximation. This approximation assumes that the oscillations do not perturb the convective flux. While this approximation is reasonable for smaller amplitude pulsations, the large amplitude of the pulsations in Cepheids do perturb the convective flux. To account for this, we’ll now use a different pulsation tool included in MESA: the Radial Stellar Pulsations (RSP) code. We will also be constructing a graph that shows the period-luminosity relationship that makes Cepheid stars so important for measuring astronomical distances.

## Science Goals

1. Determine the period-luminosity relation from our models
2. Check the agreement between GYRE non-adiabatic calculations and RSP linear non-adiabatic calculations
3. Bonus: determine the edges of the instability strip

## MESA Goals

1. Use RSP's linear analysis tool to determine both periods and growth rates of the fundamental and first overtone modes
2. Bonus: Learn how to use simple bash scripts to automate running MESA with many different parameters

## Lab Directions

For this lab we’ll be using the models that you saved from Lab 1. If your run did not complete then please find the solutions directory for your mass here: **add link to solutions dir**.

### Add GYRE values to shared spreadsheet for several models

First things first, let’s look for models where we expect pulsations in the fundamental mode to be excited. These are the modes with positive growth rates. The exact model number that you use doesn’t matter so much for this step so look at the output from lab 1 and find a model where the fundamental mode has a positive value of growth (hint: no negative values will be shown, instead modes with a negative growth rate are listed as ‘stable’. This is because the star is stable to this perturbation. I.e. the motions will be damped nd no pulsation will develop). **Give guidance also the choose a model number around where we saved a `.mod` file in lab 1, so that we can be reasonably sure of RSP's model builder converging.**

Once you have found a model with a positive growth rate: please add the period, luminosity, and growth rate to this spreadsheet: **add spreadsheet link here**. As more people add their models, we should see a clear relationship between the period and luminosity values.

### Set up RSP work directory

**Need to add instructions on grabbing the RSP LNA work directory.**

### Set up RSP inlist

Now we will do some linear non-adiabatic (LNA) analysis using the RSP code included in MESA. To use this functionality we need to set `create_RSP_model = .true.` in the `star_job` section of `inlist_rsp_Cepheid`. For consistency with the GYRE results obtained in lab 1, we keep the same settings in both the `eos` and `kap` sections of the inlist. Most of the inlist parameters used by RSP are found in the `controls` section of the inlist. Take a minute to look at the documentation of these controls [found here](https://docs.mesastar.org/en/26.4.1/reference/controls.html#radial-stellar-pulsations-rsp). The first few controls are marked as "must set". This is because, rather than taking a full stellar model as GYRE does, RSP uses the stellar mass, luminosity, effective temperature, and envelope composition to build a static model of the stellar envelope.

The next set of controls change the parameters of the convection model which will be discussed by Eb in the lecture introducing lab 3. **Double check with Eb that this is, in fact, the case** There are also some additional numerical controls that we will leave at their default values. **Possibly change `RSP_anchor_tolerance` to `1d-4` based on tests, if so need to explain control and why we make the change.**  The only other RSP control we will change is `RSP_max_num_periods` which we will set to 0. This is because we are only using RSP to perform the LNA analysis and not to evolve the non-linear pulsations.

Using your history output from lab 1, set the following controls in `inlist_rsp_Cepheid` to the correct value for the models you examined in the previous step:

```fortran
    RSP_mass = 
    RSP_Teff = 
    RSP_L = 
    RSP_X = 
    RSP_Z = 
```

[!IMPORTANT]
Make sure that the values you set for `RSP_X` and `RSP_Z` correspond to the values of X and Z in the envelope. Also note that, because we have mass loss enabled, the mass of your model will not be the initial mass you set in lab 1.

### Run RSP LNA

Once you have set the envelope values, run MESA in the normal way.

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

Once you have found a set of model parameters where RSP sucessfully builds an envelope model your output will look something like:

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

which is then followed by the usual MESA terminal output header, and one model's worth of output before MESA terminates with `termination code: reached max number of periods`. Of this information, the part we are most interested in is the period and growth rate information printed right after `create initial RSP model`. RSP indexes the modes in order of decreasing period (increasing frequency). In our case, the mode labeled 0 should be the fundamental radial mode, followed by the first and second overtones (modes 1 and 2). RSP then prints some information about the stellar model, conveniently printing the surface luminosity labeled as `L(1)/Lsun`. Using this output please add your RSP results to the shared spreadsheet.

To fill in our period luminosity diagram a little bit more, repeat this process (changing the inlist parameters and running RSP LNA) for different parameters from your lab 1 results.

[!NOTE]
Take a look at your original `history.data` file. Do you need to change the envelop composition when running a new model?

### As the spreadsheet fills in discuss the following questions at your table

- Do GYRE and RSP-LNA give similar periods on the same model?
- Do they disagree more clearly in growth rates?
- How much scatter do we see across the class sample?
- What kind of period-luminosity relation do we recover from the models?

### Bonus task: Batch running RSP

After setting up RSP for several different parameter combinations, you might notice that doing this manually is a little bit tedious (and if you're anything like me, very prone to human error). For the bonus task, you can try your hand at automating these runs. For this bonus task, there are a few different difficulty levels that you can choose from:

#### Let me cook

Come up with your own approach to automating this task. Once you have a plan, and before starting the code, look at the questions below and discuss them with your TA.

{{< details title="Things to consider when automating your MESA RSP LNA run" closed="true" >}}

- How do you plan to extract the relevant parameters from the output of lab 1?
- How do you plan to create the correct inlist for each model?
- What output do you need to save?
- How can you make this output easy to process?

{{< /details >}}

#### Set me on the path

Below, you'll find an outline of one possible approach to solve this problem. Using this outline, create your own implementation of each part of the process from scratch.

{{< details title="One potential approach" closed="true" >}}

- The `.mod` files saved in lab 1 contain all of the relevant information for RSP. Note that because the envelope doesn't change composition, you don't need to change `RSP_X` or `RSP_Z`. This means that you can create a bash script which loops over all of the files in the lab 1 `mod_dir` and extract the relevant parameters from the file name for each model.
- You can then use `shmesa change` to update the relevant inlist parameters `RSP_mass`, `RSP_Teff`, `RSP_L` before running MESA.
- This will output the information to the terminal, additionally the `extras_start_step` routine in `run_star_extras` is already configure to write LINA data to an output file. You will need to modify this to ensure that the output is not overwritten when you call MESA again for each new model (the keyword `position` in the fortran `open` call may be useful). You may also want to double check the units of this output.

{{< /details >}}

#### Take my hand

Here **add link to partial solutions** you will find partially complete solutions which will walk you through one method of solving this problem. See the files there for specific instructions.

#### Show me how it's done

Here **add link to full solutions** you will find a complete set of solutions with comments explaining the code. Read through the code to understand what is happening and then run it using your results from lab 1.

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
