---
weight: 3
title: "Lab 2: Linear Analysis in GYRE vs LNA (from RSP)"
linkTitle: Lab 2
---

*Lab written by: Lynn Buchele (lead TA), Mathijs Vanrespaille, Sofia Mesini, Andy Santarelli, and Ebraheem Farag (lecturer)*

## Background

In lab 1, we evolved a star through the instability strip and used GYRE (on-the-fly within MESA) to calculate the expected periods and growth rates of the fundamental radial mode $(l = 0, n = 0)$. In the next lab, we'll use MESA to further evolve one model and see the pulsations develop. However, we want to choose a model where the pulsations will actually be excited and then settle into a nonlinear state. We could use the output of GYRE to determine this, but GYRE's nonadiabatic calculations use some approximations that aren't necessarily valid for Cepheid stars.

Specifically, the GYRE setup we used in Lab 1 uses the frozen convection approximation, which assumes that the oscillations do not perturb the convective flux. This approximation is most reasonable when convection carries little of the local flux, or when the coupling between convection and pulsation is weak. It becomes less reliable near the cool edge of the instability strip and in large amplitude Cepheid pulsations, where convection can contribute to the driving and damping of the mode.

To account for this, we’ll now use a different pulsation tool included in MESA: the Radial Stellar Pulsations (RSP) code. Specifically, we'll use RSP's linear nonadiabatic functionality (LNA, sometimes also called LINA). In an LNA calculation, MESA perturbs a static envelope model with small amplitude radial oscillations and reports the mode periods and growth rates without evolving the full nonlinear pulsation. This makes RSP-LNA a useful bridge between the GYRE results from Lab 1 and the nonlinear RSP/TDC evolution we will run in Lab 3. We will also be constructing a graph that shows the period-luminosity relationship that makes Cepheid stars so important for measuring astronomical distances.

## Science Goals

1. Find a model where pulsations are expected to be excited in the fundamental radial mode.
2. Determine the period-luminosity relation from our models.
3. Check the agreement between GYRE nonadiabatic calculations and RSP-LNA.

## Lab Goals

1. Choose a Lab 1 model using the GYRE period and growth rate output.
2. Run RSP-LNA for the selected model and enter the comparison values in the class spreadsheet.
3. Use the comparison to decide which models are good candidates for nonlinear follow up in Lab 3.

## MESA Goals

1. Use RSP's linear analysis tool to determine both periods and growth rates of the fundamental and first overtone modes.
2. Bonus: Learn how to use simple bash scripts to automate running MESA with many different parameters.

## Lab Directions

For this lab we’ll be using the histories and saved models from Lab 1. If your Lab 1 run completed, use your own `history.data` file and saved `.mod` files. If your run did not complete, use the [Lab 1 history file solutions](https://drive.google.com/drive/folders/1LUQkr654JLP1oKbPrYkLx-JUfL7-8bKz?usp=share_link) and open the solution `history.data` file for your initial mass. You should also grab the saved MESA model from your track, found in the [Lab 1 mod file solutions](https://drive.google.com/drive/folders/1jBEtn-JCkOq15l9cT3Z_L_jecpIAqeKs?usp=share_link), which are zipped by mass.

{{< details title="Optional shortcut: using `gyre_in_mesa.data` files" closed="true" >}}

The [Lab 1 GYRE file solutions](https://drive.google.com/drive/folders/1woaPSSlIvNQADA5Eg-SGO0N11gXHa-S2?usp=share_link) provide a compact `gyre_in_mesa.data` file for each initial mass. These files can be used instead of searching through the full `history.data` file.

The compact file contains `model_number`, `star_mass`, `X`, `Z`, `Teff`, `L`, and the period and growth information for the fundamental, first overtone, and second overtone modes. The `F_period`, `O1_period`, and `O2_period` columns correspond to the same GYRE periods from the full history file, but they are set to `-1` when that mode was not unstable. The `F_logKE_per_cycle`, `O1_logKE_per_cycle`, and `O2_logKE_per_cycle` columns are `2*growth` for unstable modes and `-1` otherwise.

If you are using the compact file, use `L`, `F_period`, and `F_logKE_per_cycle` for the spreadsheet. Use `star_mass`, `X`, `Z`, and `Teff` when setting up RSP.

For the fundamental mode model choice, use `F_logKE_per_cycle > 0` and `F_logKE_per_cycle > O2_logKE_per_cycle`. For a first overtone comparison, use `O1_logKE_per_cycle > 0` and `O1_logKE_per_cycle > O2_logKE_per_cycle`.

{{< /details >}}

### Setting up

Recall that in lab 1 we saved the GYRE results for the fundamental radial mode and the first and second overtones in the history file. We'll now use that information to look for models where we expect pulsations in the fundamental mode to be excited. These are the modes with positive growth rates.

For the fundamental mode model choice, use a model where the fundamental mode has positive growth and is growing faster than the second overtone: `F_growth > 0` and `F_growth > O2_growth`. For a first overtone comparison, use the analogous condition `O1_growth > 0` and `O1_growth > O2_growth`. This extra check is useful because the GYRE calculation does not include the same eddy viscous damping of overtone modes that we will use in RSP. If you are using the compact `gyre_in_mesa.data` table instead, use the equivalent columns listed in the optional drop-down above.

For the `.mod` file you may carry into Lab 3, the ideal GYRE choice has the fundamental mode growing faster than both overtones: `F_growth > 0`, `F_growth > O1_growth`, and `F_growth > O2_growth`. If you cannot find a model with `F_growth > O1_growth`, that is fine; choose a model with `F_growth > 0` and `F_growth > O2_growth` that is closer to the red edge of the instability strip. A model closer to the blue edge is more likely to switch into an overtone during the nonlinear Lab 3 run.

#### Task: Find a model and add your information to the spreadsheet

Look through your history file from Lab 1 to find a model with `F_growth > 0` and `F_growth > O2_growth`. Please add the luminosity, GYRE F period, and GYRE F growth information to [this spreadsheet](https://docs.google.com/spreadsheets/d/1dVK0vpzgsAy0S7OG-qMyJlmwItwbp1JeB8B-xScV8WI/edit?usp=drive_link). From a full `history.data` file, use `luminosity`, `F_period`, and `F_growth`. If you are using the compact `gyre_in_mesa.data` file instead, use the column mapping in the optional drop-down above. Please also add your name or initials in the first column so you can find your data again. Keep a note of the model number you chose; you will use it for bookkeeping in the RSP inlist and when choosing a Lab 3 starting model.

As more people add their models, we should see a clear relationship between the period and luminosity values.

#### Task: Set up RSP work directory

Now that we have the results from GYRE in the spreadsheet, we want to get values from RSP-LNA as a comparison. Although we are using the results of lab 1, we want to create a new working directory since we'll be using different inlists to run RSP. You can find the [starting working directory here](https://drive.google.com/file/d/1MFZ4UsVcrvNBqcccYJmqZQhli_A8DGjP/view?usp=share_link).

Download and unzip this file into a new working directory (not into your lab 1 working directory).

### Set up RSP inlist

There are a few inlist parameters you will need to change in `inlist_rsp_Cepheid`. The place for each addition is marked with `!!!`. If you wish to test your skills at reading MESA documentation, take a moment now to search the documentation to determine for yourself what needs to be changed. Otherwise use the hints for each section provided in the drop downs.

#### Task: Set up the `star_job` inlist section

Add the control necessary to use RSP to the `star_job` section of the inlist. RSP does not read in a model, so please also set the starting model number to match the Lab 1 model number you noted above. This does not change the run itself, but it makes bookkeeping easier (and could be useful if you attempt the bonus task).

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

The next set of controls change the parameters of RSP's time dependent convection model. Most of these stay at their standard values so that everyone uses the same pulsation setup. The one value you need to set is the RSP mixing length parameter, `RSP_alfa`, which should match the `mixing_length_alpha` used in your Lab 1 evolutionary model.

For a broader comparison of RSP and MESA-star TDC pulsation controls, see [Pulsations in MESA](../background/pulse-in-mesa/).

{{< details title="RSP Convection Controls Background" closed="true" >}}

RSP evolves the turbulent kinetic energy, $e_t$, with a one-equation convection model:

\[
\begin{aligned}
\frac{D e_t}{D t}
&+ \alpha_{p_t} P_t \frac{D \rho^{-1}}{D t} \\
&= \epsilon_q + C - \frac{\partial L_t}{\partial m},
\end{aligned}
\]

The source/sink term and convective luminosity can be written as

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

The nonlocal turbulent flux is

\[
\begin{aligned}
L_t &= -A \alpha \alpha_t \rho h e_t^{1/2}\frac{\partial e_t}{\partial r}, \\
A &= 4\pi r^2.
\end{aligned}
\]

As you will see in Lab 3, `TDC` in MESA-star adopts the same convection model except without this nonlocal overshooting term.

The source/sink term $C$ is left at the standard RSP setting in this lab. The controls we are adopting are:

```fortran
! RSP_alfa: MESA label "mixing length"; alpha in the convection terms
RSP_alfa  = 1.77d0

! RSP_alfac: MESA label "convective flux"; scales L_conv
RSP_alfac = 1.0d0

! RSP_alfas: MESA label "turbulent source"; source term inside C
RSP_alfas = 1.0d0

! RSP_alfad: MESA label "turbulent dissipation"; cascade sink inside C
RSP_alfad = 1.0d0

! RSP_alfap: MESA label "turbulent pressure"; alpha_{p_t} pressure-work term
RSP_alfap = 0.0d0

! RSP_alfat: MESA label "turbulent flux"; alpha_t in L_t, nonlocal overshoot
RSP_alfat = 0.0d0

! RSP_alfam: MESA label "eddy viscosity"; alpha_m in epsilon_q
RSP_alfam = 0.25d0

! RSP_gammar: MESA label "radiative losses"; gamma_r sink inside C
RSP_gammar = 0.0d0
```

{{< /details >}}

The only other RSP control we will change is `RSP_max_num_periods` which we will set to 0. This is because we are only using RSP to perform the LNA analysis and not to evolve the nonlinear pulsations.

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

If you have tried two models and have not gotten RSP to converge, please pick another model from your Lab 1 output or ask a TA for a fallback model.

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

As you will see in the shared spreadsheet, the period-luminosity relationship has some scatter. This is because the underlying relationship is actually between period, luminosity and *color*. We can collapse the color dependence by using the Wesenheit index:

$ W_{VI} = I - R(V-I), $

where $V$ and $I$ are the absolute magnitudes in the V and I bands, respectively, and $R$ is a constant that parameterizes the color dependence. For a more detailed discussion of this approach take a look at the appendices of [Madore and Freedman 1991](https://ui.adsabs.harvard.edu/abs/1991PASP..103..933M/abstract) or [Madore 1982](https://ui.adsabs.harvard.edu/abs/1982ApJ...253..575M/abstract). We'll use the value $R=1.55$ as was used by [Smolec et al 2026](https://arxiv.org/abs/2603.26111).

The provided `run_star_extras` will print the `RSP_W_VI` value to the terminal just before the data from the first time step.

#### Task: Add RSP information to the spreadsheet

Using your terminal output, add your RSP results for the fundamental period, growth rate, and Wesenheit index to the shared spreadsheet (put this on the same line as your GYRE results).

To fill in our diagrams a little bit more, repeat this process (changing the inlist parameters and running RSP LNA) for different timesteps from your lab 1 results.

> [!NOTE]
> Take a look at your original `history.data` file from lab 1. Do you need to change the values of `RSP_X` and `RSP_Z` when running a new model?

You should aim to run 2-3 models. For Lab 3, when we'll evolve the pulsations, note down model numbers that worked cleanly and showed positive fundamental mode growth. If the fundamental growth rate was negative, try choosing a model in the middle of the instability strip for your next run.

>[!TIP]
> You can use the png output saved from lab 1 to easily check which models are in the instability strip.

If your second model also has a negative growth rate, try a model closer to the middle of the instability strip or ask a TA for a fallback choice.

### As the spreadsheet fills in discuss the following questions at your table

- How similar are the periods returned by GYRE and RSP for the same model?
- How similar are the growth rates returned by GYRE and RSP for the same model?
- Compare the period-luminosity relations between the two codes. Are there any major differences?
- How do the period-luminosity relations compare to the period Wesenheit relations?

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
- In this loop you can use [`shmesa change`](https://github.com/MESAHub/mesa/tree/main/scripts/shmesa) to update the relevant inlist parameters `initial_model_number`, `RSP_mass`, `RSP_Teff`, and `RSP_L` before running MESA. This preserves the Lab 1 model number in the output table.
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
> For options 2-4, your output will be a table separated by whitespace. Most spreadsheet programs (Excel, LibreOffice Calc, GoogleSheets) can import this kind of text file. Then, the columns of this new spreadsheet can easily be copied into the class spreadsheet.

### Bonus task part 2

If you have completed your batch RSP-LNA runs, try to also add the GYRE period and growth rate values to the spreadsheet. **Hint**: Remember, this information is saved in the output of lab 1 and so you don't need to rerun any models.

### Optional: fully automated batch setup

When we did these runs to generate the data for the plots in the lecture slides, we made a few changes to automate a few more things. For those interested, we provide and describe this directory below.

{{< details title="Set up used for fully automated batch runs" closed="true" >}}

The [extended full solution archive](https://drive.google.com/file/d/1BP5cMCpX6v8kInb3DPGKuNtqABhG-5Oo/view?usp=share_link) shows a more automated version of the batch workflow. It follows the same basic idea as the bonus task, but is set up to run through many saved Lab 1 `.mod` files with less manual editing.

The extended script loops over the saved model files, reads the model number, current mass, effective temperature, and luminosity from each filename, updates the corresponding RSP inlist controls with [`shmesa change`](https://github.com/MESAHub/mesa/tree/main/scripts/shmesa), runs RSP-LNA, and appends one output record per successful model. That makes the output easier to join to the Lab 1 GYRE tables and use for comparison plots. You do not need this extended version to complete the lab; it is included as reference code for anyone who wants to see a more automated implementation.

{{< /details >}}

## Suggested Further Reading

Method references:

- [Townsend and Teitler 2013, GYRE](https://ui.adsabs.harvard.edu/abs/2013MNRAS.435.3406T/abstract)
- [Paxton et al. 2019, MESA V](https://ui.adsabs.harvard.edu/abs/2019ApJS..243...10P/abstract)
- [Anderson et al. 2016, pulsation-convection coupling and Cepheid instability strip edges](https://www.aanda.org/articles/aa/full_html/2016/07/aa28031-15/aa28031-15.html)

Pulsation and P-L references:

- [Smolec et al. 2026, MESA Cepheid grid III](https://arxiv.org/abs/2603.26111)
- [Bono et al. 1999, theoretical Cepheid P-L, P-C, and P-L-C relations](https://ui.adsabs.harvard.edu/abs/1999ApJ...512..711B/abstract)
- [Espinoza-Arancibia et al. 2022, period change rates of LMC Cepheids using MESA](https://ui.adsabs.harvard.edu/abs/2022MNRAS.517.1538E/abstract)
