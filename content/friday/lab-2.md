---
weight: 3
title: Lab 2 - Linear Analysis in GYRE vs LNA (from RSP)
linkTitle: Lab 2
---

*Lab written by: Lynn Buchele (lead TA), Ebraheem Farag (lecturer), Mathijs Vanrespaille, Sofia Mesini, and Andy Santarelli

## Background

In lab 1, we evolved a star through the instability strip and used GYRE (on-the-fly within MESA) to calculate the expected periods and growth rates of the fundamental radial mode $(l = 0, n = 0)$. In the next lab, we'll use MESA to further evolve one model and see the pulsations develop. However, we want to choose a model where the pulsations will actually be stable. We could use the output of GYRE to determine this, but GYRE's non-adiabatic calculations use some approximations that aren't necessarily valid for Cepheid stars.

Specifically, GYRE uses the frozen-convection approximation, which assumes that the oscillations do not perturb the convective flux. While this approximation is reasonable for smaller amplitude pulsations, the large amplitude of the pulsations in Cepheids *do* perturb the convective flux.

To account for this, we’ll now use a different pulsation tool included in MESA: the Radial Stellar Pulsations (RSP) code. Specifically, we'll use RSP's linear non-adiabatic  functionality (LNA, sometimes also called LINA). We will also be constructing a graph that shows the period-luminosity relationship that makes Cepheid stars so important for measuring astronomical distances.

## Science Goals

1. Find a model where stable pulsations are expected in the fundamental radial mode.
2. Determine the period-luminosity relation from our models.
3. Check the agreement between GYRE non-adiabatic calculations and RSP-LNA.

## MESA Goals

1. Use RSP's linear analysis tool to determine both periods and growth rates of the fundamental and first overtone modes.
2. Bonus: Learn how to use simple bash scripts to automate running MESA with many different parameters.

## Lab Directions

For this lab we’ll be using the models that you saved from Lab 1. If your run did not complete, use the [Lab 1 GYRE file solutions](https://drive.google.com/drive/folders/1woaPSSlIvNQADA5Eg-SGO0N11gXHa-S2?usp=share_link) and the `history.data` file in the subdirectory for your initial mass. It would also be good to grab the saved MESA model from your track, found in the [Lab 1 mod file solutions](https://drive.google.com/drive/folders/1jBEtn-JCkOq15l9cT3Z_L_jecpIAqeKs?usp=share_link), which are zipped by mass.

### Setting up

Recall, that in lab 1 we saved the GYRE results for the fundamental radial mode and the first and second overtones in the history file. We'll now use that information to look for models where we expect pulsations in the fundamental mode to be excited. These are the modes with positive growth rates.

#### Task: Find a model and add your information to the spreadsheet

Look through your history file from lab 1 to find a model with a positive growth rate (in the fundamental mode): please add the luminosity, GYRE F_period, and GYRE F_growth to [this spreadsheet](https://docs.google.com/spreadsheets/d/1dVK0vpzgsAy0S7OG-qMyJlmwItwbp1JeB8B-xScV8WI/edit?usp=drive_link). Please also add your name or initials in the first column so you know which row contains your data.

As more people add their models, we should see a clear relationship between the period and luminosity values.

#### Task: Set up RSP work directory

Now that we have the results from GYRE in the spreadsheet, we want to get values from RSP-LNA as a comparison. Although we are using the results of lab 1, we want to create a new working directory since we'll be using different inlists to run RSP. You can find the [starting working directory here](https://drive.google.com/file/d/1MFZ4UsVcrvNBqcccYJmqZQhli_A8DGjP/view?usp=share_link).

Download and upzip this file into a new working directory (not into your lab 1 working directory).

### Set up RSP inlist

There are a few inlist parameters you will need to change in `inlist_rsp_Cepheid`. The place for each addition is marked with `!!!`. If you wish to test your skills at reading MESA documentation, take a moment now to search the documentation to determine for yourself what needs to be changed. Otherwise use the hints for each section provided in the drop downs.

#### Task: Set up the `star_job` inlist section

Add the control necessary to use RSP to the `star_job` section of the inlist. RSP does not read in a model and so please also set the starting model number to match the model whose information you added to the spreadsheet.

{{< details title="`star_job` parameters" closed="true" >}}

These are the controls which should be set in the `star_job` section of `inlist_rsp_cepheid`.

```fortran
      create_RSP_model = .true.

      set_initial_model_number = .true.
      initial_model_number = ! Your model number here
```

{{< /details >}}

For consistency with the GYRE results obtained in lab 1, we keep the same settings in both the `eos` and `kap` sections of the inlist. We do however wish to turn on the colors module.

#### Task: Turn on the `colors` module

We will be using the V and I band magnitudes to compute an additional parameter and so we need to enable the `colors` module.

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

 Using the model you chose from Lab 1, set the parameters in the `controls` section of `inlist_rsp_cepheid` using the values from the model you added to the spreadsheet. Use the values of `photosphere_X` and `photosphere_Z` to set the composition.

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
Check that the in the outer regions of the model the `RSP_X` value you entered matches the `h1` and that your calculated value of Y matches the `he4` values.
> 3. Double check that you are inputting your values in the units expected by RSP: mass in Msun, Teff in K, L in Lsun, X and Z as mass fractions.

### Run RSP LNA

#### Task: Once you have set necessary inlist controls, run MESA in the normal way

> [!TIP]
> Since this is new working directory, don't forget to compile MESA before calling it.

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

then try following the suggestion made in the error message and increase `RSP_T_anchor_tolerance` to `1d-4`. If this still doesn't, work then you are likely trying to build a model outside of regime that RSP's model builder can handle. Please pick another model and try again.

{{< /details >}}

If you have tried 2 models and have not gotten RSP to converge, please consult the list here: to find a model number for your mass that should work. !!!!EB: Can you create this list and add a link here?

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

Using your terminal output, add your RSP results for the fundamental period, growth rate, and Wessenheit index to the shared spreadsheet (put this on the same line as your GYRE results).

To fill in our diagrams a little bit more, repeat this process (changing the inlist parameters and running RSP LNA) for different timesteps from your lab 1 results.

> [!NOTE]
> Take a look at your original `history.data` file from lab 1. Do you need to change the values of `RSP_X` and `RSP_Z` when running a new model?

You should aim to run 2-3 models. For lab 3, when we'll evolve the pulsations, it's best to start with a model that has a positive growth rate from RPS-LNA. If your first model had a positive growth rate for the fundamental mode, then note down that model number. If the fundamental growth rate was negative, try choosing a model in the middle of the instability strip for your next run (even if the GYRE growth rate was negative).

>[!TIP]
> You can use the png output saved from lab 1 to easily check which models are in the instability strip.

If your second model also has a negative growth rate, consult this list to find a good model number for your selected mass. !!!!EB: Can you add the link to the 'good' model numbers list here as well?

### As the spreadsheet fills in discuss the following questions at your table

- How similar are the periods returned by GYRE and RSP for the same model?
- How similar are the growth rates returned by GYRE and RSP for the same model?
- Compare the period-luminosity relations between the two codes. Are there any major differences?
- How do the period-luminosity relations compare to the period-Wesenheit relations?

### Bonus task: Batch running RSP

After setting up RSP for several different parameter combinations, you might notice that doing this manually is a little bit tedious (and if you're anything like me, very prone to human error). For the bonus task, you can try your hand at automating these runs. For this, focus first on the RSP information.

The starting working directory includes a `batch_LNA.sh` template for this bonus task. You can fill in that template, adapt it, or replace it with your own script.

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
- For the batch run, you will need to write one row of LNA data to an output file for each model. You will need to figure out the control necessary to trigger this output and modify the file opening so that the output is not overwritten when you call MESA again for each new model (the keyword `position` in the fortran `open` call may be useful). You may also want to double check the units of this output.

{{< /details >}}

#### Option 3: Take my hand

Start from these [partially complete solutions](https://drive.google.com/file/d/1YXyy03R6unwUVqn8J1Ej9TOM1ZmYnyoz/view?usp=share_link) which use the method described in the hint above. They include a starter `batch_LNA.sh` and output-writing scaffold; all the changes you need to make are marked with `!!!`.

#### Option 4: Show me how it's done

{{< details title="Small changes to the solutions files you still need to make" closed="true" >}}

This is a [complete set of solutions](https://drive.google.com/file/d/1q_ieQpw9ggKxSQ-5eoDLMWcuXlMX4hrQ/view?usp=share_link) with comments explaining the code. Read through the code to understand what is happening and then run it using your results from lab 1.

If you use these solutions files directly, you still need to pass the correct path for your `mod_dir` from lab 1 to `batch_LNA.sh`. The supplied script updates `initial_model_number`, `RSP_mass`, `RSP_Teff`, and `RSP_L` from the `.mod` filenames. Set `RSP_X` and `RSP_Z` in `inlist_rsp_Cepheid` to the composition you want to use before launching the bash script using the command `./batch_LNA.sh`. If you get a permissions error simply run `chmod u+x batch_LNA.sh` and try to run the script again.

{{< /details >}}

> [!TIP]
> For options 2-4, your output will be a whitespace-separated table. Most spreadsheet programs (Excel, LibreOffice Calc, GoogleSheets) can import this kind of text file. Then, the columns of this new spreadsheet can easily be copied into the class spreadsheet.

### Bonus task part 2

If you have completed your batch RSP-LNA runs, try to also add the GYRE period and growth rate values to the spreadsheet. **Hint**: Remember, this information is saved in the output of lab 1 and so you don't need to rerun any models.

<!--## Even more automation To add after testing

When we did these runs to generate the data for the plots in the lecture slides, we made a few changes to automate a few more things. For those interested, we provide and describe this directory below.

{{< details title="Set up used for fully automated batch runs" >}}

**!!!! EB: add a discussion of your approach to fully automating this work here.**

{{< /details >}}-->

## Suggested Further Reading

Method references:

- [Townsend and Teitler 2013, GYRE](https://ui.adsabs.harvard.edu/abs/2013MNRAS.435.3406T/abstract)
- [Paxton et al. 2019, MESA V](https://ui.adsabs.harvard.edu/abs/2019ApJS..243...10P/abstract)
- [Anderson et al. 2016, pulsation-convection coupling and Cepheid instability-strip edges](https://www.aanda.org/articles/aa/full_html/2016/07/aa28031-15/aa28031-15.html)

Pulsation and P-L references:

- [Smolec et al. 2026, MESA Cepheid grid III](https://arxiv.org/abs/2603.26111)
- [Bono et al. 1999, theoretical Cepheid P-L, P-C, and P-L-C relations](https://ui.adsabs.harvard.edu/abs/1999ApJ...512..711B/abstract)
- [Espinoza-Arancibia et al. 2022, period change rates of LMC Cepheids using MESA](https://ui.adsabs.harvard.edu/abs/2022MNRAS.517.1538E/abstract)
