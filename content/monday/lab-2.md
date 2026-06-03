+++
date = '2026-04-06T13:38:04+02:00'
draft = false
title = 'Lab 2 - Exploring MESA Custom Colors!'
+++

*Authors: Eliza Frankel (lead TA), Niall Miller, Joey Mombarg - Lecturer: Yaguang Li — MESA Summer School 2026, Tetons, Wyoming*

The MESA colors module allows us to generate synthetic photometry while running MESA stellar evolution models! It is a great way to merge observational and theoretical astronomy. With the colors module, we can specify what filter system and stellar atmosphere we want to use, and on top of regular MESA outputs (effective temperature, luminosity, age, etc.) we get bolometric magnitude, M$_{bol}$, bolometric flux, F$_{bol}$, and many synthetic magnitudes. For more information on the colors module, look at the [documentation](https://docs.mesastar.org/en/26.4.1/test_suite/custom_colors.html) or look at `$MESA_DIR/colors/defaults/colors.defaults`.


One major age dating technique for stellar populations is through the use of isochrones. Isochrones are single-aged, chemically homogeneous populations that show a snapshot of stellar evolution. They're made by evolving stars with the same chemical composition but different initial masses, and then finding what point in evolution each star is at at a particular age. Larger stars burn hotter and brighter, leaving the main sequence much quicker than a lower mass star. For example, at 10 Gyr we can see a 0.8 $M_{\odot}$ still on the main sequence, while a 5 $M_{\odot}$ star will be long past the Red Giant Branch. Because of this, we can build isochrones and use them to determine the age of stellar populations. One caveat to this is that they use the assumption that all the stars are at relatively the same distance and formed from the same materials at relatively the same time. _The best stellar populations to use isochrones when age dating stars is in clusters because we can make these assumptions._

This figure shows a series of isochrones at different ages between 0.03 Gyr to 10 Gyr, made using MIST. As the population gets older, the shape of the isochrone changes too!
<img width="450" height="600" alt="isochrones" src="https://github.com/user-attachments/assets/b115dfa9-6604-4531-9b04-d7dfb6481184" />



In this lab, we'll learn how atmospheric boundary conditions and the convective mixing length parameter can impact stellar evolution in both observational and theoretical coordinates. Together, we'll also build isochrones to explore other techniques for age dating stellar populations and planet hosts.


### Step 1 - Directory Prep

Last lab we made a working directory that has everything we want to start lab 2. The first thing we will do is copy lab 1 into a new working directory:

```bash
cp -r work_lab1 work_lab2
cd work_lab2
```
Let's clean this directory and get rid of our outputs from Lab 1:

```bash
./clean
./mk
rm -r 1Msun_Z0p0134_Omega5000nHz_no_magnetic_braking ! Make this the name of your output directory defined in lab 1
```
In Lab 1, we explored magnetic braking. Let's make sure it's off for this lab in `&controls`:

```fortran
! Enable magnetic braking.
use_other_torque    = .false.
```

(A clean working directory can be downloaded [here](https://drive.google.com/drive/folders/1qebaN8Qt6e1nqiEHkt9A0T-jfyPIzXCE) under the name work_lab2.zip)

### Step 2 - Building the inlist

For this lab, we are going to start with the same inlist as before, but we'll be adding a few things.
We will be changing parameters in `&colors`, `&controls`, and the `inlist_pgstar`. Let's start with `&colors`.

> [!TIP]
> As you edit your inlists, make sure to leave comments by using `!`. It's a good thing to get in the habit of & is very helpful when looking back at old codes!



#### Setting up Custom Colors in `&colors`

This is where we can enable synthetic photometry and determine what filters we'd like to use. Let's look through the [documentation](https://github.com/MESAHub/mesa/tree/main/colors).

The first thing we need to do is to make sure the colors module is on. By default, custom colors is turned off.

```fortran
! Turns on Custom Colors
use_colors = .true.
```

Next, we need to provide the file path to a filter system, stellar atmosphere, and VEGA SED. For this lab, we want to use the 2MASS filters, Kurucz 2003 atmosphere tables, and vega_flam.csv as our Vega SED reference file.

**Task:** `cd $MESA_DIR/data/colors_data/` to look for 2MASS, Kurucz2003, and vega_flam.csv and add them to your inlist:

> [!Note]
> There are two Kurucz 2003 atmosphere tables in Custom Colors - let's use `Kurucz2003all/`

```fortran
  ! Points to the directory where filters are 
  instrument =     !!!!!

  ! Choice of stellar atmosphere tables
  stellar_atm =     !!!!!

  ! Points to the reference SED file for Vega
  vega_sed =     !!!!!
  ```

  {{< details title="Hint" closed="true" >}}

  ```fortran
  instrument = '/data/colors_data/ADD/FILTERS/HERE'
  stellar_atm = '/data/colors_data/ADD/MODELS/HERE/'
  vega_sed = '/data/colors_data/VEGA_SED/HERE/'
  ```
  {{< /details >}}


  {{< details title="Solution" closed="true" >}}

  ```fortran
  instrument = '/data/colors_data/filters/2MASS/2MASS'
  stellar_atm = '/data/colors_data/stellar_models/Kurucz2003all/'
  vega_sed = '/data/colors_data/stellar_models/vega_flam.csv'
  ```

  {{< /details >}}
  

> [!CAUTION]
> Proper syntax is important! Make sure that for the `instrument` directory there _isn't_ a '/' at the end, but for `stellar_atm` there _is_ a '/'

Now let's decide the distance of the star (in cm). For apparent magnitude, you can do any distance you want. For absolute magnitude, the distance should be 10 parsecs, or 3.0857 x 10<sup>19</sup> cm. 

**Task:** Update the distance parameter to be 10 pc



{{< details title="Solution" closed="true" >}}

```fortran

  ! Distance to star in cm for synthetic photometry
  distance = 3.0857d19
```

{{< /details >}}

The last thing we need to do to make sure Custom Colors works in the `inlist` file.
**Question** Do you see anything pointing to `&colors`?


{{< details title="Answer" closed="true" >}}

No! Add the following lines of code to make sure MESA includes Custom Colors:

```fortran
&colors

   read_extra_colors_inlist(1) = .true.
   extra_colors_inlist_name(1) = 'inlist_project'

/ ! end of colors namelist

```

{{< /details >}}


#### `&controls`

This is the section with the main stellar evolution parameters. Our goal is to change the stellar input parameters to see how they change evolution! Keep the same stellar mass you used in Lab 1, but let's change the output directory to something simple:

`log_directory = 'LOGS'`

The first thing we want to change is how the atmospheric boundary conditions are controlled. Look through the _controls_ tab under star defaults in the [documentation](https://docs.mesastar.org/en/26.4.1/reference.html) to the right parameters to change. What does it control specifically?


{{< details title="Hint" closed="true" >}}

The section atmospheric boundary conditions has everything we'll need to start. `atm_option` is the main parameter we'll use. This changes how surface temperature (Tsurf) and surface pressure (Psurf) are evaluated at outer boundary conditions.

{{< /details >}}

Lets first use a **T($\tau$)** relationship. This defines how the atmospheric pressure structure is obtained by integrating the hydrostatic equilibrium equation,

$$
\frac{dP}{d\tau} = \frac{g}{\kappa}.
$$

Here, we assume that gravity, _g_, is spatially constant. There are 4 options for the **T($\tau$)** relationship: `Eddington`, `solar_Hopf`, `Krishna_Swamy`, and `Trampedach_solar`. 
{{< details title="Information on T($\tau$) options" closed="true" >}}

   * `Eddington` - The Eddington grey relation says that the effective temperature is equal to the physical temperature at an optical depth of 2/3:
   $T^{4}(\tau) = \frac{3}{4} T^{4}_{\rm eff}(\tau + \frac{2}{3}$)
   * `solar_Hopf` - A function calibrated to the Sun, using a grey T($\tau$) relation (ie opacity is independent of wavelength). Is more realistic near the photosphere
   * `Krishna_Swamy` - Also calibrated to the Sun and uses a grey T($\tau$) relation.  
   * `Trampedach_solar` - Uses 3D hydrodynamic simulations and models realistic radiative transfer

  By switching between these model atmospheres, we can change the $T_{\rm eff}$, depth of convection zones, location of the red giant branch, and solar calibrations.

  {{< /details >}}
  
We'll start with the Eddington relation which is already defined in our inlist.


#### `inlist_pgstar`

For this lab, we are only going to use an HR diagram and a plot showing 2MASS magnitudes. You can either start with a blank inlist_pgstar (erase everything between `&pgstar` and `/ ! end of pgstar namelist` to copy the code below, or you can download the inlist_pgstar from [here](https://drive.google.com/drive/folders/1qebaN8Qt6e1nqiEHkt9A0T-jfyPIzXCE?usp=drive_link).


  ```fortran
&pgstar

   ! see star/defaults/pgstar.defaults

   ! MESA uses PGPLOT for live plotting and gives the user a tremendous
   ! amount of control of the presentation of the information.


   ! show HR diagram
   ! this plots the history of L,Teff over many timesteps
   HR_win_flag = .true.

   ! To save HR diagram as png
   HR_file_flag = .true.
   HR_file_dir = 'png'
   HR_file_prefix = 'hr_'



   ! set window size (aspect_ratio = height/width)
   HR_win_width = 6
   HR_win_aspect_ratio = 1.0


   ! Magnitude Magnitude diagram
   History_Track2_win_width = 6
   History_Track2_win_aspect_ratio = 1.0

   ! To save mag mag diagrams
   History_Track2_file_flag = .true.
   History_Track2_file_dir = 'png'
   History_Track2_file_prefix = 'mag_'

   History_Track2_win_flag = .true.
   History_Track2_xname = 'J'
   History_Track2_yname = 'Ks'
   History_Track2_title = '2MASS Magnitudes'
   History_Track2_xaxis_label = 'J mag'
   History_Track2_yaxis_label = 'Ks mag'
   History_Track2_reverse_xaxis = .true.
   History_Track2_reverse_yaxis = .true.



/ ! end of pgstar namelist


```

> [!TIP]
> For `inlist_pgstar` to work, there needs to be a blank new line after `/ ! end of pgstar namelist`. If you copy the file above and get the error `Fortran runtime error: End of file`, make sure to add a new line to the end of `inlist_pgstar`

{{< details title="What should your pgstar plots look like?" closed="true" >}}
Once your star leaves the pre main sequence, two windows will show up on your screen. Here is an example of what the plots will show for a 1 M$_{\odot}$ star.

<img width="300" height="300" alt="hr" src="https://github.com/user-attachments/assets/4712e8c0-cab8-4ad6-b59c-7a4c5eebf1b2" /> <img width="300" height="300" alt="mags" src="https://github.com/user-attachments/assets/90ca6023-c855-437d-a37c-5c12837cc762" />



{{< /details >}}

### Step 3 - Isochrone Building

Isochrones are a snapshot of stellar evolution, showing how stars evolve differently at the same age depending on their initial masses. To visualize this, we'll run one stellar track and record the $T_{\rm eff}$ and log(L) at 1, 3, 5, 7, and 9 Gyr. **Use the same mass as in lab 1**


**Task:** Start the model run using `./rn`. Once your star is done evolving, copy the values for "$T_{\rm eff}$" and "log(L)" from the terminal window into this [Google spreadsheet](https://docs.google.com/spreadsheets/d/1C88C5V2siCAaK8-3qgAZoNc9-9IH-RTIqFVetXQc3EM/edit?usp=sharing) (make sure you switch to the tab labeled "Lab 2" at the bottom)


As everyone finishes filling out the spreadsheet, we'll get to see an isochrone being built!



### Step 4 - Changing parameters and running

#### Boundary Conditions

For this lab, we want to explore the different atmospheric boundary conditions and the mixing length parameter, $\alpha_{\rm MLT}$. Start with just changing the boundary conditions.

In `&controls` above, we chose the Eddington T_tau relationship. Before we start running MESA, let's change one more parameter in `&controls` - because we want to compare how different parameters change evolution, we need to change the output file name so they don't overwrite each other. Make sure you give your new history file a descriptive name, for example if you are running a 1 $M_{\odot}$ star using the T_tau Eddington relationship, a good name would be: 

```fortran
! Changes the name of your history file
star_history_name = '1p0Msun_TtauEddington_history.data'
```

Now you can `./rn` and watch the star evolve. 

Once it is done, try using a different atmospheric boundary condition and see what changes!

{{< details title="Hint" closed="true" >}}

There are many different combinations you can try! First, try changing `atm_T_tau_relation` to `solar_Hopf`, `Krishna_Swamy`, or `Trampedach_solar`. 

> [!CAUTION]
> Remember to change `star_history_name` to include the changes to atmospheric boundary conditions!

{{< /details >}}

You can also change `atm_option` to something other than a T($\tau$) relation, but be sure that you're using all the right parameters. 

{{< details title="Other `atm_option` " closed="true" >}}

  If you wanted to try model atmosphere tables for photosphere, you could try using the `photosphere` option. To do this, we need to change one line of code and add another:

   ```fortran
    ! Change from 'T_tau' to 'table' to use precalculated tables from model atmospheres
    atm_option = 'table'

    ! Add this line to specify which atmosphere table surface temperature and pressure use
    ! For more options other than photosphere, take a look [here](https://docs.mesastar.org/en/26.4.1/reference/controls.html#atm-table)
    atm_table = 'photosphere'
   ```

{{< /details >}}



Once you've explored how the atmospheric boundary conditions change evolution, set `atm_T_tau_relation` back to `Eddington`. * If you changed `atm_option` to something other than 'T_tau', go ahead and change it back, too.

#### Mixing length parameter, $\alpha_{\rm MLT}$

As we know, MESA is a 1 dimensional stellar evolution code which means it has to be creative when modeling 3D processes. In order to model energy transport in stars, MESA utilizes mixing length theory (MLT), which is the standard 1D parameterization of convection. One of the key parts of MLT is the mixing length parameter, $\alpha_{\rm MLT}$. This is a unitless value that represents the convective efficiency of a region (i.e. what fraction of energy transport is being moved by convection rather than radiation). By changing $\alpha_{\rm MLT}$, we can drastically change a star's main sequence lifetime, opacity, and more!

Look through the controls default parameters again and find the mixing length parameter, or $\alpha_{\rm MLT}$. What value have we been using? 

{{< details title="Hint" closed="true" >}}
Check under the tab "mixing parameters" for the controls defaults
{{< /details >}}

{{< details title="Answer" closed="true" >}}
The default value is `mixing_length_alpha = 2.0d0`
{{< /details >}}

The solar mixing length parameter for the Eddington T($\tau$) atmospheric boundary condition is around 1.80. Add the solar mixing length parameter to `&controls` and remember to change the name of your output history file so you know what the input parameters are. In this case, you could name your history file something like:

```fortran
star_history_name = '1p0Msun_alphaMLT1p80_history.data'
```

Each star has a different mixing length parameter, so you can't always use the solar value. For example, $\alpha$ Centauri A and B have mixing lengths that are 0.932 $\alpha_{MLT,\odot}$ and 1.095 $\alpha_{MLT,\odot}$, respectively ([Joyce & Chaboyer 2018b](https://ui.adsabs.harvard.edu/abs/2018ApJ...864...99J/abstract)). Try changing the value of `mixing_length_alpha` and running a model for either $\alpha$ Centauri A or B.



> [!TIP]
> You can't use math in an inlist, so if you wanted to have twice the mixing length, write `mixing_length_alpha = 3.6d0` rather than `mixing_length_alpha = 2 * 1.8d0`

Choose at least 1 more objects from the following table and run a model for each, changing the history file name so we can plot them soon. _Make sure you keep the same mass as you used in Lab 1!_

| Object  | Type | Mixing Length  | Source |
| :---- | :-- |:---- |:-- |
| M92 | Metal poor globular cluster | 0.90 $\alpha_{MLT,\odot}$ | [Joyce & Chaboyer 2018a](https://ui.adsabs.harvard.edu/abs/2018ApJ...856...10J/abstract) |
| HD 140283 | Subgiant | 0.88 $\alpha_{MLT,\odot}$ | [Joyce & Chaboyer 2018a](https://ui.adsabs.harvard.edu/abs/2018ApJ...856...10J/abstract) |
| HIP 54639 | Main sequence | 0.28 $\alpha_{MLT,\odot}$ |[Joyce & Chaboyer 2018a](https://ui.adsabs.harvard.edu/abs/2018ApJ...856...10J/abstract)  |
| HIP 106924| Main sequence | 0.52 $\alpha_{MLT,\odot}$ | [Joyce & Chaboyer 2018a](https://ui.adsabs.harvard.edu/abs/2018ApJ...856...10J/abstract)  |
| KIC 1430163 | Star | 1.2 $\alpha_{MLT,\odot}$ | [Viani et al. 2018](https://iopscience.iop.org/article/10.3847/1538-4357/aab7eb/pdf) |
| KIC 1435467 | Star | 1.15 $\alpha_{MLT,\odot}$ | [Viani et al. 2018](https://iopscience.iop.org/article/10.3847/1538-4357/aab7eb/pdf) |



#### Comparing different atmospheric boundary conditions and mixing length parameters

Now, go to the [Google Colab](https://colab.research.google.com/drive/1rFAu8UN0CC3GWllJfNyk7uV50FksOKok?usp=sharing) and make a copy of it.

Follow the instructions in the document to upload the different history files we made and visualize how changing the atmospheric boundary conditions and mixing length parameter can impact stellar evolution. 


### Inlist Solutions

{{< details title="Final inlist solutions!" closed="true" >}}

Here is what your inlist should look like! You can also download a copy from [here](https://drive.google.com/drive/folders/1qebaN8Qt6e1nqiEHkt9A0T-jfyPIzXCE?usp=drive_link) to make sure you get the lab working.

<details>
<summary>inlist_project</summary>

```fortran
&star_job

      pause_before_terminate = .true.
      show_log_description_at_start = .true.

      history_columns_file = 'custom_history_columns.list'
      profile_columns_file = 'custom_profile_columns.list'

      ! pgstar
      pgstar_flag = .true.

      ! pre main sequence
      create_pre_main_sequence_model = .true.
      pre_ms_T_c = 9.9d5 ! Initial central temperature.

      ! initial rotation
      new_omega =  3.1416d-5 ! 5000nHz
      set_near_zams_omega_steps = 15

      ! initial metal fractions
      initial_zfracs = 6 ! AGSS09_zfracs



/ ! end of star_job namelist

&eos

/ ! end of eos namelist

&kap

      !opacities with AGSS09 abundances
      kap_file_prefix = 'OP_a09_nans_removed_by_hand'
      kap_lowT_prefix = 'lowT_fa05_a09p'
      kap_CO_prefix   = 'a09_co'

      use_Type2_opacities = .false.


/ ! end of kap namelist

&controls

      ! ZAMS limit
      Lnuc_div_L_zams_limit = 0.95

      ! uniform viscosity

      ! initial mass
      initial_mass = 1d0

      ! initial He and Z
      initial_z = 0.0134
      initial_y = 0.2485

      ! stopping criterion
      xa_central_lower_limit_species(1) = 'h1'
      xa_central_lower_limit(1) = 0.01

      ! output
      log_directory = 'LOGS'
      history_interval = 1
      star_history_name = '1p0Msun_alphaMLT1p80_history.data'   !!!!!!!

      ! atmosphere options
      atm_option = 'T_tau'  !!!!!!!
      atm_T_tau_relation = 'Eddington'  !!!!!!!
      atm_T_tau_opacity = 'varying'  !!!!!!!

      ! Enable magnetic braking.
      use_other_torque    = .false.

      ! Mixing length parameter
      mixing_length_alpha = 1.80d0  !!!!!!!

/ ! end of controls namelist


&pgstar

! We set the pgstar controls in a seperate inlist instead.

/ ! end of pgstar namelist

&colors

      ! This turns on custom colors
      use_colors = .true.

      ! Points to the directory where you house the filters
      ! For 2MASS it is, H.dat, J.dat, Ks.dat
      ! Can download other filter systems using SED-tools
      instrument = '/data/colors_data/filters/2MASS/2MASS'

      ! Your choice of stellar atmosphere table
      stellar_atm = '/data/colors_data/stellar_models/Kurucz2003all/' 

      ! Distance to star in cm for synthetic photometry
      ! If you set the distance to 10 parsecs (3.0857d19), you will have absolute magnitude
      ! For any other distance, custom colors will give apparent magnitude
      distance = 3.0857d19  ! 10 parsecs in cm (Absolute Magnitude)

      ! Exports a full calculated SED at every profile interval
      ! Needed if you want to plot the SED
      make_csv = .true.
      colors_results_directory = 'SED'  ! Directory the fully calculated SED will go to


      ! Defines the zero-point system for magnitude calculations
      mag_system = 'Vega'

      ! Points to the reference SED file for Vega
      vega_sed = '/data/colors_data/stellar_models/vega_flam.csv'

/ ! end of colors namelist
```
</details>

<details>
  <summary>inlist_pgstar</summary>

  ```fortran
  &pgstar

   ! see star/defaults/pgstar.defaults

   ! MESA uses PGPLOT for live plotting and gives the user a tremendous
   ! amount of control of the presentation of the information.

   ! show HR diagram
   ! this plots the history of L, Teff over many timesteps
   HR_win_flag = .true.


   ! set window size (aspect_ratio = height/width)
   HR_win_width = 6
   HR_win_aspect_ratio = 1.0


   ! Color Color diagram
   History_Track2_win_width = 6
   History_Track2_win_aspect_ratio = 1.0

   History_Track2_win_flag = .true.
   History_Track2_xname = 'J'
   History_Track2_yname = 'Ks'
   History_Track2_title = '2MASS Magnitudes'
   History_Track2_xaxis_label = 'J mag'
   History_Track2_yaxis_label = 'Ks mag'
   History_Track2_reverse_xaxis = .true.
   History_Track2_reverse_yaxis = .true.



/ ! end of pgstar namelist
```

</details> 

{{< /details >}}

### Bonus task - More than one filter system

In this lab, we used the Custom Colors module to visualize 2MASS magnitudes. What if you want to compare more than one filter system at the same time?

{{< details title="Bonus Task - More than one filter system" closed="true" >}}

**Make sure you finish the rest of this lab and return to this if you have time!**

Sometimes you want to use more than one filter system. To do this with Custom Colors, we must look into the data structure more. Follow these steps to make a joint Gaia-2MASS filter system you can use:

``` terminal
! in **one step above**your working directory
mkdir data
cd data
mkdir filters
cd filters
mkdir GAIA_2MASS
cd GAIA_2MASS

cp -r $MESA_DIR/data/colors_data/filters/GAIA/GAIA/*.dat .
cp -r $MESA_DIR/data/colors_data/filters/2MASS/2MASS/*.dat .
```


Now that you've made this joint filter system, let's make a file called `GAIA_2MASS` and open it in your preferred text editor. Now add all the filters to use. For Gaia and 2MASS, it should look like:

```fortran
G.dat
Gbp.dat
Grp.dat
Grvs.dat
H.dat
J.dat
Ks.dat
```

Finally, you can replace the line for 'instrument' in `&colors` with

```fortran
instrument = '../data/filters/GAIA_2MASS'
```

** A completely working version of this can be downloaded [here](https://drive.google.com/drive/folders/1qebaN8Qt6e1nqiEHkt9A0T-jfyPIzXCE) called 'BONUS_data_multiple_filters.zip'. Make sure this is in the directory **above** your working directory for it to work!

{{< /details >}}

### Bonus Task - Mixing Length Parameter

If you've finished the lab early you can explore the atmospheric boundary conditions and mixing length parameter more. What happens if you keep both parameters the same but change the mass? What about changing mass and $\alpha_{\rm MLT}$? Mass and b
