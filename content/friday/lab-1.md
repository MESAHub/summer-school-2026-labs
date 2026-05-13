---
weight: 2
title: Lab 1 - Evolving a Cepheid into the Instability Strip
linkTitle: Lab 1
---

# Lab 1: Evolving a Cepheid into the Instability Strip

**_Disclaimer_** : it might be possible that the tone is not coherent in the entirety of the lab instructions (I went a bit more unhinged in the last part) let me know if i should tone the last part down or make the beginning less formal

In this lab you will learn how to evolve a classical Cepheid model, with an initial mass in the $3$-$8\,M_\odot$ range. The evolution will be divided in two steps:

1. **Step 1**: you will start from the Zero Age Main Sequence (ZAMS) and stop when a threshold in effective temperature $T_{\mathrm{eff}}$ is reached.

2. **Step 2**: you will resume the previous run and simulate the evolution all the way through Helium burning, until reaching Helium depletion in the core.

While the simulation runs in Step 2 you'll get to watch your star experience a blue loop and move through the instability strip, while GYRE runs automatically during the pulsational phase!

During this second part of the run, you will also save some models (called `.mod` files), that will be reused in the next labs.

## Let's get it started in here: setting up the work directory

**Task 1**: Create your working directory for this lab.

Select a name for the directory you will be working in (it could be something like ```~/ MESA_ss_2026/friday``` for example).
You may also place the working directory somewhere other than your home directory.

{{< details title="Answer 1" closed="true" >}}

Here's how to create your working directory and then move inside it.

```bash
mkdir -p ~/MESA_ss_2026/friday
cd ~/MESA_ss_2026/friday
```

The useful ```mkdir -p``` command creates a directory and includes all the needed parent directories. So if the parent directory does not exist, it will be created automatically.
{{< /details >}}

**Task 2**: Download and unzip the input directory.

We have already prepared an input directory to help you getting started with this lab: you can find it [here](https://mesastar.org/summer-school-2026/lodging/). **the link is a placeholder for now**.

Download the work directory into the  ```~/ MESA_ss_2026/friday``` directory you just created, unpack it, and move into it.

{{< details title="Answer 2" closed="true" >}}

Here's how to unzip the input folder

```bash
unzip lab1_input.zip 
cd lab1_input
```

{{< /details >}}

## Cepheid goes brrr: stopping conditions in the ```run_star_extras.f90```

**Task 1**: change the initial mass of the star.  

Discuss among the people at your table and pick an initial mass in the range $3$-$8\,M_\odot$. Feel free to choose the mass you prefer!

> [!IMPORTANT]
> Make sure that each person at your table has chosen a different initial mass value: you will need to compare your results later!

The next step is to give instructions to MESA about the value of initial mass you just chose. To do so, open the ```inlist_to_he_dep``` file with your favourite text editor, and have a look at it: try to find the correct spot to define the initial mass!

{{< details title="Answer 1" closed="true" >}}

You should look for the ```&controls``` namelist in the ```inlist_to_he_dep``` file, and you will find something like this:

```fortran
   ! ====== TODO: set the initial mass here! ======
   initial_mass = 4.5d0
```

Change the value of the ```initial_mass``` variable with the number you just chose!
{{< /details >}}

Great, now MESA knows what mass we should _start_ to simulate. However, a MESA run is not ready to start until we know **when to _stop_**!

**Task 2**: Implementing a custom stopping condition in the ```run_star_extras.f90``` file.

In this first part of the run, we want to stop the simulation when the star is at the base of the Red Giant Branch (RGB). In this case, the most efficient way to do it is to consider a _stopping condition_ based on the **effective temperature** of the star.

However, in MESA there is **no pre-defined stopping condition that could do it**, so you need to implement it yourself, and the best way to do it is to play with the ```run_star_extras.f90``` file!

_First thing first_: open the ```run_star_extras.f90``` file with your favourite text editor and look for the ```extras_finish_step``` subroutine. This subroutine will be called at the end of each evolutionary step, to control if the conditions to stop the evolution are met.

Now we have collected here some important information for you, that might help you with this task:

* The temperature you want your model to stop at is $\log(T_{\mathrm{eff}}) \simeq 3.7 $
* To access the value of $T_{\mathrm{eff}}$ for the current evolutionary step in the ```run_star_extras.f90``` file, we need to use a pointer to the star. The way to do so is the following:

```fortran
s% Teff
```

> [!CAUTION]
> What you get by writing what is in the section above is a _number_,  **not a variable**!

* If you want to make the logarithm of a number in fortran, you should use

```fortran
log_of_number = safe_log10(number)
```

* We have already initialized a variable for you called ```logTeff``` in the code that you can use to store the logarithm of the effective temperature
* In fortran the '_less than something_' operator can be written as ```.le.```

* The syntax to make an ```if``` statement in fortran is the following:

```fortran
if (condition_you_want_to_meet) then
    what_happens
endif
```

Try and code it yourself, but if you are have some trouble don't hesitate to ask for help or click on the answer below!

{{< details title="Answer 2" closed="true" >}}

Here's how to implement the stopping condition based on the effective temperature of the star:

```fortran
! == TODO: add stopping condition for effective temperature! ==
         logTeff = safe_log10(s% Teff)
         if(logTeff .le. 3.7d0) then
            extras_finish_step = terminate
            write(*, *) '== end of the RGB! =='
            s% termination_code = t_extras_finish_step
         end if
```

{{< /details >}}

To check that everything is working correctly, let's first **compile** the model using

```bash
./mk
```

If no errors or warnings pop up, you are all set! Now run the model using

```bash
./rn
```

During this first run you will see the star evolving through the main sequence up to the base of the RGB, and will be the base on which we will be building the second part of the simulation!

## Ah yes, the remix: stopping condition in the ```inlist_to_he_dep```

At this point, the star has reached the base of the RGB. Now we want it to evolve until the end of Helium burning, but with the setup we have now this is not going to happen.

Indeed, with the current stopping condition we cannot progress past this point, because the limit in temperature has already been reached...we need to change it and **choose a different condition**!

**Task1**: Comment or remove the previous stopping condition.

Open again the ```run_star_extras.f90``` file and look for the stopping condition you just implemented. Once you find it, take extra care in commenting (or deleting) every line that you wrote!

> [!TIP]
> To comment lines in fortran, simply add a ```!``` at the beginning of the line.

Now, since we are changing the ```run_star_extras.f90``` file, we also need to change the executable. In order to effectively remove the stopping condition based on the temperature from the next part of the evolution, we need to delete the previous ```star``` file from the folder. Now make a new executable file using

```bash
./mk
```

**Task 2**: Setting a new stopping condition.

In this second part of the run, we want to stop the simulation when Helium is depleted in the core of the star. Luckily, in this case MESA provides a pre-made stopping condition for when the mass fraction of an isotope goes below a user-set value. Can you find it in the documentation?

> [!TIP]
> Have a look at the ```controls``` section [here](https://docs.mesastar.org/en/latest/reference/controls.html#).

> [!TIP]
> Alternatively you can take a look at the ```controls.defaults``` file in ```$MESA_DIR/star/defaults```.

Once you have found the right command, implement the stopping condition in your inlist!

In this case, we want to stop the simulation when the mass fraction of leftover Helium in the core goes below ```1d-4```.

{{< details title="Answer 2" closed="true" >}}

Here's how to implement the stopping condition based on the amount of leftover Helium in the core:

```fortran
   ! == TODO: add a stopping condition here! ==
   ! we want the second part of the run to stop when
   ! the mass fraction of he4 drops below 1d-4
   xa_central_lower_limit_species(1) = 'he4'
   xa_central_lower_limit(1) = 1d-4
```

{{< /details >}}

Amazing! Now you are ready to continue your simulation!
> [!NOTE]
> Since the changes that we made in the ```inlist_to_he_dep``` are not introducing new code into MESA, we **don't need** to **make a new executable**!

Great, we have a new executable...but how do we continue the run without losing what we just computed?
> [!CAUTION]
> Do **not** run the model yet with ```./rn```: this will start a brand new model from the ZAMS!

## Oh no the run stopped... anyway: ```./re```

A very powerful feature of MESA is the possibility to restart a simulation from previous steps in the evolution.

This lab is a perfect example of this: we have just run a simulation for a star that has reached the base of the RGB. If we want to evolve it further (like up to Helium depletion), there is no need to make a new simulation from scratch: **restart** the one you have just stopped!

The way to do it is by using ```photos``` files. These are files written by MESA in binary code, like 'snapshots' taken during the evolution of the star. You can find them in the ```photos/``` directory.

> [!CAUTION]
> These files are **machine-specific**: so no, you cannot share your photo file with your group mate and expect to obtain the same result!

What we want to do now is to restart our simulation from the last photo MESA took at the end of the previous simulation.

Look into the output from your terminal; you should see something like this

```bash
save photos/x00000384 for model 384
termination code: extras_finish_step
```

Copy the number you see next to ```photos``` (in this case x00000384): this is the file name of the last photo file we are looking for!

Now you are ready to restart your run using

```bash
./re x00000384
```

> [!CAUTION]
> You need to change the number after ```./re``` with the file name of your last photo file!

Restarts can cause your history file to jump around as restarts only append to the existing `history.data` file. That is, if you run a track to model number 500 then restart from model number 300, the original models will remain in the history file. So any post processing code that expects the model numbers to increase monotonically will struggle. The other consequence of this is that you cannot change the history column outputs between restarts without causing an error.

Now is also a good time to look a bit deeper at the `run_star_extras` file that we provided. In previous labs, you used GYRE as a post-processing code on profile files saved by MESA. There is also a way to run GYRE on-the-fly during the evolution, which is what we will use in this lab. In order to use GYRE in this way we have to load the GYRE library with the statement

```fortran
   use gyre_mesa_M
```

at the beginning of the `run_star_extras` file. We also have added a few variables to pass the values returned by GYRE from one routine within `run_star_extras` to another. The next necessary step is to set up GYRE in the `extras_startup` routine. No matter what you are using GYRE for, these two steps are always necessary!

Scrolling down further to the `data_for_extra_history_columns` routine, you should see that here we just pass each of the columns we want to save using the variables defined at the start of the file. However these values are not calculated here. Instead we calculate them in the `extras_finish_step`.

After the usual variable declarations and getting the `star_info` data structure, there is a logical called `call_gyre` that is initially set to false. This structure can be useful if you don't want to call GYRE on every single step which can significantly increase the run time of a given evolutionary track (depending on what kind of star you're evolving).

We then have a few lines of code which use the `x_integer_ctrl(1:3)` parameters to set other variables. This isn't strictly necessary, but it can be nice to have variables with meaningful names. We then zero out the variables that we saw used in `data_for_extra_history_columns`. As you saw we are only calling GYRE every `s% x_integer_ctrl(1)` time steps, so if we left these variables undefined the time steps during which we don't call GYRE would just keep their values from the previous time step. This can be a bit confusing so by setting everything to zero we ensure that it is clear during which timesteps GYRE is actually called.

The code then checks if we need to call GYRE during this time step. If we do then there is some additional set up we need to do before calling GYRE. The first is to get the stellar structure data that will be passed to GYRE. This is accomplished with the `star_get_pulse_data` subroutine. This routine has three logical input parameters, take a moment to search the code base and try to figure out what each parameter controls.

{{< details title="Answer" closed="true" >}}

To find the source code, you can use `shmesa grep star_get_pulse_data`. This searches all the MESA source code regardless of whether you are in `$MESA_DIR`. As we want to find where the routine is defined we can ignore any line that begins with `call` or is in a print statement which leaves only

```none
$MESA_DIR/star/public/star_lib.f90: star_get_pulse_data => get_pulse_data, & 
```

looking at this file we find that this function points to another function in the `pulse` module called `get_pulse_data`. Using another `shmesa grep` call we can see that this function is defined in `$MESA_DIR/star/private/pulse.f90` and by examining this file find that the three logical variables correspond to `add_center_point`, `keep_surface_point`, and `add_atmosphere`. We'll keep them set to `.false.` for now.

{{< /details >}}

After getting the pulse data, we now need to put it into a form that GYRE can handle. Take a look at `$MESA_DIR/gyre/public/gyre_mesa_m.f90` to see if you can figure out the correct subroutine to call.

> [!TIP]
> You might want to take another look at the `star_get_pulse_data` call. We've named some variables the same as are used in the GYRE module subroutine to help you.

{{< details title="Answer" closed="true" >}}

The correct routine is `set_model` and the necessary code is

```fortran
call set_model(global_data, point_data, s%gyre_data_schema)
```

{{< /details >}}

We then write a header to the terminal so that you know what information is being printed, set a few parameters we'll discuss in a moment and

```fortran
call get_modes(mode_l, process_mode_cepheid, ipar, rpar)
```

As noted in the comments:

```fortran
! The subroutine calls GYRE to find the modes. 
! After each mode is found, it calls the subroutine process_mode_cepheid defined below
! Integer parameters are passed with ipar and real parameters are passed with rpar
! These two arrays allow us to pass information back and forth with the process mode subroutine 
! However we choose to use the xtra#_array values that are a part of the star_info structure, so indexing is less confusing 
```

We then move the information returned by GYRE to the variables used by `data_for_extra_history_columns`.

The last additional steps in this subroutine check whether we need to save a `.mod` file based on the effective temperature. We will use these models for the later labs. This temperature limit is just to ensure that these later labs run smoothly. **Need to add directions on how to set `save_mod_Teff_limit` based on results from Eb's testing here**

## Noice, what now? Changing the ```pgplot``` window _during_ the run!

Ok you have started the final part of the run for your lab, but there is still plenty you can do!
You might have already noticed from the MESA simulations in the previous days, that a ```pgplot``` panel with figures will pop up when you start running. Do you know you can change that _while the model is running_? Crazy!

Let's take advantage of this awesome feature, shall we?

**Task 1**: Add the instability strip

Since we are looking at the evolution of a Cepheid star, an extremely useful feature we can add to out Hertzsprung-Russell diagram (HRD) is the instability strip. In this region, stars usually start to show pulsations, and we want to make sure whether the model you are running is entering this phase or not.

For this feature, MESA already provides a built-in command to show the two edges (respectively blue/hot and red/cool) of the instability strip to your HRD.

First of all, open the ```inlist_pgstar``` file with your favorite text editor. Then paste this line into the file (_where_ you put it is not strictly relevant).

```fortran
show_HR_classical_instability_strip = .true.
```

After doing so, make sure to **_save the file_**!

In the next step of the evolution, you will see the two lines magically appear on the HRD on your screen, TA-DAA!

![mesa output](is_hrd.png)

**_Disclaimer_**  (if you don't like the screenshot remove it, i don't know how to make it smaller)
> [!NOTE]
> This instability strip is a rough guess meant to guide the eye, and so it may not correspond exactly to the instability strip we obtain from these labs.

## Hooray! You survived the setup - let's talk about science!

**_Disclaimer_** : maybe I need to get more work done on these questions, but if you have suggestions/want to make changes feel free

Even though you will not be changing the rest of these plots, it's still interesting to take a look at them: we can get some very interesting information from them.
During the evolution you should see something like this:

![grid](grid_lab1.png)
There are a total of 5 panels:

1. **HRD**: This is the Hertzsprung-Russell diagram, to which you have now added two lines. These are the edges of the Instability Strip, a region of the HRD where stars pulsate. What is your model doing right now? Is it entering the strip or not?

2. **density/temperature**: This is a density/temperature plot, showing the different regimes of the equations of state in which each point in the interior of a star is. Can you distinguish which one of the two extremes is the core and which one is the surface? in which regime is the interior of the star? Does it change throughout the evolution? What is the difference between the surface and the core?

3. **Combined panel**: In this panel you can see 3 figures stacked on top of each other. From the top down you can see, respectively, the chemical abundances in the interior of the star, the energy generation, and the internal mixing processes, all as a function of the mass coordinate. How is the energy transported in the star? can you see any changes while the model is evolving?

4. **opacity**: In this plot you can see the value of opacity throughout the interior of the star, for each evolutionary step. Notice the x axis: it is a function of the logarithm of the optical depth. How is opacity changing in the star during the evolution? can you link it to the energy transport mechanism?

5. **radius and luminosity**: Finally in this panel you can see how radius, temperature and luminosity evolve during the evolution of the star.

You might notice that even once your star has crossed into the instability strip, it doesn't pulsate. For a first order explanation of why this is the case, the fundamental period of a Cepheid star can be approximated as $P_F \approx 0.37 t_{dym}$ where $t_{dyn} = 2 \pi \sqrt{R_{\ast}^3/(GM_{\ast})}$ is the dynamical time scale. This value (in sec) and time step in seconds are shown in your pgplot text summary. How do the two compare? (The solution to getting Cepheids to pulsate as MESA evolves is a bit more complicated than just dropping the timestep, but that will be explored in lab 3.)

## To blue loop or not to blue loop? That is the question

After your simulation are completed, take a look at the last ```.png``` file that MESA saved, and compare it to those of the other people at your table.
Can you answer the following questions? Share possible hypotheses with the folks at your table!

* Which masses make the cleanest blue loops?
* Which models actually enter the instability strip?
* How does the Cepheid candidate phase depend on mass?
* Which saved structures are the best starting points for Lab 2?

-----
-----
-----
## stuff written by Eb: to be removed once the instructions are completed

## Directory

`content/friday/MESA_models/lab1_evolve_a_cepheid/cepheid_evolution_gyre_in_mesa/`

## Goal

- evolve a Cepheid model into the instability strip
- watch the blue loop during core helium burning
- run GYRE in MESA while the star is in the Cepheid phase
- save `.mod` files that Lab 2 can reuse

## What Students Do

1. Pick a mass in the $3$-$8\,M_\odot$ range. The cleanest class split is to assign masses in $0.5\,M_\odot$ steps.
2. Build and run the Lab 1 work directory.
3. Use PGSTAR and the history output to follow the track into core helium burning.
4. Let the modified `run_star_extras` call GYRE in MESA during the helium-burning part of the run.
5. Save the `.mod` files written during the Cepheid phase and record the matching `log L` and `log T_eff`.

```bash
cd content/friday/MESA_models/lab1_evolve_a_cepheid/cepheid_evolution_gyre_in_mesa
./mk
./rn
```

> [!NOTE]
> In this setup, `src/run_star_extras.f90` turns on regular GYRE calls only during core helium burning and writes `.mod` files into `mod_dir/`.

## What the Class Should Produce

- an HR diagram with the strip-crossing models marked
- a shared table with mass, `log L`, `log T_eff`, and saved model names
- a bank of helium-burning `.mod` files for Lab 2

## TA Prep

- decide ahead of time how the class mass grid will be split across tables
- check that each table knows where the saved `.mod` files are being written
- make sure the class records which saved models are the best Cepheid candidates
- have one or two fallback masses ready in case a run needs to be swapped

{{< details title="TA note: what to emphasize in discussion" closed="true" >}}

Keep the discussion centered on a few concrete questions:

- Which masses make the cleanest blue loops?
- Which models actually enter the instability strip?
- How does the Cepheid candidate phase depend on mass?
- Which saved structures are the best starting points for Lab 2?

{{< /details >}}

## Suggested Reading

- [Ziółkowska et al. 2024, MESA Cepheid grid I](https://ui.adsabs.harvard.edu/abs/2024ApJS..274...30Z/abstract)
- [Ziółkowska et al. 2026, MESA Cepheid grid II](https://arxiv.org/abs/2602.08109)
