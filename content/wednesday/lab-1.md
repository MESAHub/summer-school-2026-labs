---
weight: 1
author: Tryston Raecke, Sunny Wong, Josh Wanninger, Michael Zingale
math: true
disableKinds: "rss"
---
# Minilab 1: Place Your Bets: Explode or Implode?


## Introduction

- (Briefly) What is the URCA Process and why is it important
- How this relates to the choice of nuclear reaction network
- Intro to lab -- From a starting White Dwarf composition, will build a nuclear net, then use varying accretion rates to map initial density at oxygen flame


### Helpful Links

The general Google drive for these Wednesday labs can be found [HERE]( FIXLINK ). 

More specifically, the files for Lab 1 can be found [HERE]( FIXLINK ). This drive contains the starting point, partial solutions (separated by task), and a full solution. You do **not** need to download the entire drive!

Lastly, it will be helpful to consult the [MESA documentation](https://docs.mesastar.org/en/latest/) throughout this lab.

## How to destroy a White Dwarf in 10(ish) easy steps!

Note throughout this lab expected tasks are outlayed specifically with: 
| 📋 TASK 0 |
|:--------|
| (insert stuff to do here) |

Additionally, there will be various
> [!WARNING]
> WARNINGS,

> [!NOTE]
> NOTES,

{{< details title="and hints (click me)" closed="true" >}}
to help you along.
{{< /details >}}

Values that need to be altered in the files will generally be marked with `!!!!!`, but feel free to look over the provided solutions if you get stuck!


### Step 0: Start Up

| 📋 TASK 1 |
|:--------|
| **Download** the starting point from the [Google Drive]( FIXLINK ) to a local working directory. |

This starting point is a standard set of MESA files complete with a precomputed 1.1 M<sub>&#9737;</sub> Oxygen-Neon (ONe) white dwarf model.

After downloading, your working directory should look like:

{{< filetree/container >}}
  {{< filetree/folder name="Starting Point" >}}
    {{< filetree/file name="clean" >}}
    {{< filetree/file name="mk" >}}
    {{< filetree/file name="re" >}}
    {{< filetree/file name="rn" >}}
    {{< filetree/file name="history_columns.list" >}}
    {{< filetree/file name="profile_columns.list" >}}
    {{< filetree/file name="inlist" >}}
    {{< filetree/file name="inlist_common" >}}
    {{< filetree/file name="inlist_accrete" >}}
    {{< filetree/file name="inlist_pgstar" >}}
    {{< filetree/file name="1.1Msun_ONe.mod" >}}
    {{< filetree/folder name="src" state="open" >}}
      {{< filetree/file name="run.f90" >}}
      {{< filetree/file name="run_star_extras.f90" >}}
    {{< /filetree/folder >}}
  {{< /filetree/folder >}}
{{< /filetree/container >}} 

At this stage, we are now ready to dive into some inlists!


### Step 1: Inlist

`inlist` serves as a direction point for the run, guiding the order and precedence of variables in various other inlist files. Given this, take a peak at `inlist`. What is the order that other inlists will be read? 

> [!NOTE]
> There is no task for this step! 


### Step 2: Inlist Common

`inlist_common` holds the set of defaults that we want to be common between various accretion runs. The primary point of this is to make changes to runs easier and more modular. Instead of having to sort through walls of variables for each change, the core functionality can be stored in... common.

Now let's look over the file. You will notice that some variables have already been set to help to more aggressively relax tolerance and help the model converge at later times.

{{< details title="Aside on miscellanous variable choices in `inlist_common`" closed="true" >}}
The work that will be done throughout this lab requires careful consideration of input physics for real science cases. !!! TODO !!!

{{< /details >}}

Starting with the top of the file, reset the initial age, reset the initial model number, turn on pgstar, and save our final model as `NAME`. TODO

| 📋 TASK 1 |
|:--------|
| In `&star_jobs`, **update `inlist_common`** to set initial age to 0, set initial model number to 0, turn on pgstar, and save our final model as `NAME` TODO|


{{< details title="Hint: What variables need to be changed?" closed="true" >}}
The parameters that should be updated/added are:
- `save_model_when_terminate`
- `save_model_filename`
- `set_initial_age`
- `initial_age`
- `set_initial_model_number`
- `initial_model_number`
- `pgstar_flag`

{{< /details >}}

{{< details title="Partial Solution" closed="true" >}}
```fortran
! save a model at the end of the run
    save_model_when_terminate = .false. !!!!!
    save_model_filename = ''            !!!!!

  ! initial model
    set_initial_age = .true. !!!!!
    initial_age = 0d0        !!!!!

    set_initial_model_number = .true. !!!!!
    initial_model_number = 0          !!!!!

  ! coulomb corrections
    ion_coulomb_corrections = 'PCR2009'
    electron_coulomb_corrections = 'Itoh2002'

  ! display on-screen plots
    pgstar_flag = .true.
    disable_pgstar_during_relax_flag = .false.
```
{{< /details >}}

Next, we want to record the point of oxygen ignition in the white dwarf, but **DO NOT** want to try running through explosion/collapse during these labs. Set the maximum temperature of the model to 10<sup>9.1</sup> K. 

| 📋 TASK 1 |
|:--------|
| In `&controls`, **update `inlist_common`** to stop the model once temperature reaches 10<sup>9.1</sup> K |

{{< details title="Hint: What variables need to be changed?" closed="true" >}}
The parameter that should be added is:
- `log_max_temp_upper_limit`

{{< /details >}}

{{< details title="Partial Solution" closed="true" >}}
```fortran
! when to stop

     log_max_temp_upper_limit = 9.1d0 !!!!!
```
{{< /details >}}

> [!WARNING]
> Don't forget to save your changes to the inlist!


### Step 3: Inlist Accrete

With the common variables set, now we can focus on the fun part: throwing material on the surface. We will control the reaction network of the model and the material accreted within `inlist_accrete`. Unlike our previous inlist, this file is mostly empty. 

Starting in `&star_jobs`, load in the downloaded model `1.1Msun_ONe.mod`, change the initial network to a file we will later create called `ONe.net`, and set the weak rates to those of Suzuki+2016[^1]. These Suzuki rates are critical for the treatment of degenerate O-Ne-Mg cores as these sd-shell electron capture and β-decay rates drive the URCA process. 


| 📋 TASK 1 |
|:--------|
| In `&star_jobs`, **update `inlist_accrete`** to load the `1.1Msun_ONe` model, change the initial nuclear network to `ONe.net`, and use the Suzuki rates.|

> [!NOTE]
> Remember, paths provided in the inlists are relative to the relavant `rn` executable. 

{{< details title="Hint: What variables need to be changed?" closed="true" >}}
The parameters that should be added are:
- `load_saved_model`
- `load_model_filename`
- `change_initial_net`
- `new_net_name`
- `use_suzuki_weak_rates`
{{< /details >}}

{{< details title="Partial Solution" closed="true" >}}
```fortran
  ! load previous model
    load_saved_model = .true.                   !!!!! 
    load_model_filename = '1.1Msun_ONe.mod'     !!!!!

  ! net
    change_initial_net = .true.  !!!!!
    new_net_name = 'ONe.net'     !!!!!

  ! weak rates
    use_suzuki_weak_rates = .true. !!!!!
```
{{< /details >}}

Next, we want to accrete material of a given composition at a given rate. This material need not be the same composition as the surface star and may be defined as mass fractions of a variety of species. 

In `&controls`, set the accretion to 10<sup>-6</sup> M<sub>&#9737;</sub> / year of equal mass fractions of Oxygen-16 and Neon-20. Also, set the log output directory to a more descriptive name, `LOGS_ONe_1d-6`.


| 📋 TASK 1 |
|:--------|
| In `&controls`, **update `inlist_accrete`** to rename the LOGS directory to `LOGS_ONe_1d-6` and set the accretion rate to 10<sup>-6</sup> M<sub>&#9737;</sub> / year of equal mass fractions of Oxygen-16 and Neon-20|

> [!NOTE]
> You will need to both explicitly stop MESA from accreting the same composition as the surface and flag that the new accretion composition will be given as mass fractions.

{{< details title="Hint: What variables need to be changed?" closed="true" >}}
The parameters that should be added are:
- `mass_change`
- `accrete_same_as_surface`
- `accrete_given_mass_fractions`
- `num_accretion_species`
- `accretion_species_id`
- `accretion_specia_xa`
{{< /details >}}

{{< details title="Hint: How is accreting material defined?" closed="true" >}}
The accretion of various species is primarily governed by two arrays: `accretion_species_id` and `accretion_specia_xa`. Additionally, `num_accretion_species` provides MESA with an expectation of the length of these two arrays. 

The `id` of a particular species is defined through abbreviated isotopic hyphen notation (minus the hyphen) as <\Chemical Symbol><\Mass Number>. For example, Selenium-80 is se80 and Nickel-56 is ni56. More information on the variety of isotopes available in MESA can be found in `$MESA_DIR/chem/public/chem_def.f90`

The `xa` is the mass fraction of the particular species, some decimal value less than or equal to 1. 

Therefore, if we wanted to accrete only Hydrogen-2, we would use:
```fortran
    ! Just H2
    num_accretion_species = 1
    accretion_species_id(1) = 'h2'
    accretion_species_xa(1) = 1d0 
```

{{< /details >}}

> [!NOTE]
> Note, arrays in fortran are 1-indexed, so the first entry in an array is array(1) and the second is array(2). 

{{< details title="Partial Solution" closed="true" >}}
```fortran
  ! accretion

    mass_change = 1d-6                     !!!!!

    accrete_same_as_surface = .false.      !!!!!
    accrete_given_mass_fractions = .true.  !!!!!

    ! O and Ne
    num_accretion_species = 2
    accretion_species_id(1) = 'o16'  !!!!!
    accretion_species_xa(1) = 0.50d0 !!!!!
    accretion_species_id(2) = 'ne20' !!!!!
    accretion_species_xa(2) = 0.50d0 !!!!!

  ! output

    log_directory = 'LOGS_ONe_1d-6' !!!!!
```
{{< /details >}}


> [!WARNING]
> Don't forget to save your changes to the inlist!


### Step 4: Building a Nuclear Network


| 📋 TASK 1 |
|:--------|
| **update `ONe.net`** to include the above isotopes |

| 📋 TASK 1 |
|:--------|
| **update `ONe.net`** to include the above isotopes |

> [!WARNING]
> Don't forget to save your changes!


### Step 5: History/Profile Columns


| 📋 TASK 5 |
|:--------|
| **Uncomment**  in `history_columns.list`. 
 **Uncomment**  in `profile_columns.list`. |

> [!WARNING]
> Don't forget to save your changes to the inlist!


### Step 6: Inlist Pgstar

| 📋 TASK 1 |
|:--------|
| **update `inlist_pgstar`** to ... |

> [!WARNING]
> Don't forget to save your changes to the inlist!


### Step 7: Run the Model!

| 📋 TASK 1 |
|:--------|
| **Run** the model! Observe the...  |

> [!IMPORTANT]
> Do not forget to `./clean`, then `./mk`, then `./rn`


### Step 8: Run Star Extras !!

| 📋 TASK 1 |
|:--------|
| In `run_star_extras`, **Add** an additional history column for neutrino luminosity ...  |

> [!WARNING]
> Don't forget to save your changes to run_star_extras!

### Step 9: Plan for the future (Update nuclear network and run)

Add the following nuclei to the model:


| 📋 TASK 1 |
|:--------|
| **Update** `ONe.net` to include the above inert nuclei.  |


Now, the stopping condition should be modified to save a copy of the model right when the density crosses into thresholds that will be more... exciting. Set the stopping condition such that the final model will be produced when

Run through stopping condition

| 📋 TASK 1 |
|:--------|
| **Run** the model (Again)! Observe the...  |

> [!IMPORTANT]
> Do not forget to `./clean`, then `./mk`, then `./rn`


## BONUS: Magnetization Station

Magnetic fields can alter the interior structure of white dwarfs, driving higher masses, while increasing instability. Modify the magnetic field of the star in 5 regimes. Track the different final masses at ignition.



## References
[^1]: https://iopscience.iop.org/article/10.3847/0004-637X/817/2/163
[^2]: https://arxiv.org/pdf/2601.16918 (Figure 8)

[^2]:
