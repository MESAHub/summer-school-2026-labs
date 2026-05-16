---
weight: 4
title: Lab 3 - The Hertzsprung Progression
linkTitle: Lab 3
---

In this lab you will take one of your saved Cepheid models from Lab 1, use a non-linear pulsation setup to kick it into motion, and inspect the resulting waveform. Your goal is to identify where the bump appears in the cycle and combine your result with the rest of the class to reconstruct the Hertzsprung progression.

This is the non-linear pulsation lab for Friday. That means the details are a little more technical than in the previous labs, but your job is still very concrete:

1. start from a good Cepheid model
2. run the non-linear setup
3. inspect the light-curve shape
4. decide where the bump appears

## Background

Many classical Cepheids show a distinctive "bump" in their waveform. The figure below shows a few examples of folded Cepheid light curves observed by the OGLE study:

![OGLE](OGLE_compilation.png)

The location of that bump changes with the pulsation period. In the standard picture, this is related to a near `2:1` resonance between the second overtone and the fundamental mode, so a useful quantity to keep in mind is

$$
P_2/P_0 \approx 0.5.
$$

As the stellar structure changes across the instability strip, the bump shifts from the descending branch, through the middle of the cycle, and onto the rising branch. In this lab, you will see that progression directly in non-linear MESA models.

## Setting up the work directory

Download `lab3_work_dir.zip` from this [Google Drive](https://drive.google.com/file/d/11S0DjI8fPOw3Szli0Zpn-k8VdDDfP7YQ/view?usp=drive_link), unzip it into some empty directory, and `cd` into that directory. You'll see that it already contains the inlists you will need. However, we need to provide TDC with a starting model to make an envelope model from and track the pulsations, just as we did with RSP in Lab 2. To that end, copy the `.mod` files you created in Lab 1:

```bash
cp -r /path/to/your/lab1/mod_dir/ .
```

> [!IMPORTANT]
> Keep your Lab 1 and Lab 3 runs in separate working directories.

Alternatively, you can download the models from the [Lab 1 mod file solutions](https://drive.google.com/drive/folders/1jBEtn-JCkOq15l9cT3Z_L_jecpIAqeKs?usp=share_link), which are grouped by mass.

> [!IMPORTANT]
> Lab 3 uses a saved `.mod` file from Lab 1. It does **not** use a `photos/` restart file from Lab 1.


## Main Goal

By the end of this lab, your group should be able to answer:

- What is the pulsation period of your non-linear Cepheid model?
- Does your Cepheid model develop a bump?
- Where is the bump in the waveform?
- How does that compare with the rest of the class sample?

## Task 1: Choose a Starting Model

Take a look inside `mod_dir/`. These are the saved stellar structures that Lab 3 can use.

The filenames are written in the form

```text
modelNumber_currentMass_effectiveTemperature_luminosity.mod
```

**Question:** What would make an interesting model to simulate in further detail using TDC?

{{< details title="Click here to open the hint" closed="true" >}}

Choose a model that:

- is in the Cepheid part of the blue loop
- preferably showed positive fundamental-mode growth in Lab 1 or Lab 2
- is part of the shared class sample, so different groups cover different periods

If you completed Lab 2, an especially good choice is a model with a relatively large fundamental-mode growth rate. If you also estimated that `P_0/P_2` is close to `0.5`, that makes the model even more interesting for this lab.

{{< /details >}}

> [!TIP]
> If you completed Lab 2, the best starting point is usually a model that showed a relatively large growth rate in the linear analysis.

> [!NOTE]
> These `.mod` files come from the second part of Lab 1, after you restarted the evolution with `./re` and let the star pass through the Cepheid phase while GYRE was running during the evolution.

> [!CAUTION]
> In Lab 1, restarting with `./re` appends to the existing `history.data` file. That means model numbers in the history output may not increase monotonically. If you go back to Lab 1 to recover period or growth information for a saved model, keep that in mind while matching rows in `history.data`.

## Task 2: Edit the Lab 3 Inlist

Open `inlist_pulses` in your editor.

Find the line

```fortran
load_model_filename = 'mod_dir/YOUR_MODEL.mod'
```

For your first run:

- update `load_model_filename` so it points to the model you copied into your local `mod_dir/`

> [!NOTE]
> In this setup, MESA loads the saved stellar structure, removes the core, remeshes the envelope for time-dependent convection, and then uses a GYRE kick to seed the fundamental radial mode.

## Task 3: Choose and set an initial kick

It can take a very long time for a MESA TDC model to start pulsating "naturally". Therefore, we enforce a given radial velocity on the envelope to get the pulsation going, known as an "initial kick". The closer this kick is to the final pulsational radial velocity, the faster a bump in the light curve will develop.

From the figure below, read off a reasonable initial kick for your chosen model.

![kicks](initial_kicks.png)

Now add this value into your `inlist_pulses`. **Question:** Can you find which variable stores the initial kick?

{{< details title="Hint: where to look" closed="true" >}}

There exists no dedicated field for the initial kick of a Cepheid in MESA, so the official MESA documentation won't be of help.

Instead, think about which variables one uses when defining custom quantities in a MESA inlist.

{{< /details >}}


{{< details title="Answer" closed="true" >}}

Find and update this line in the `&controls` of *inlist_pulses*:

```fortran
    x_ctrl(6) = 10d0 ! initial vsurf (kms)
```

{{< /details >}}

> [!CAUTION]
> In real scientific applications, it is safest to give the Cepheid a small initial kick and give the model a long time to converge to its final value. In this lab, however, it is okay to risk using a larger kick to save time.

## Task 4: Compile and Run the Model

First compile the work directory:

```bash
./clean
./mk
```

> [!TIP]
> Make sure you are running inside your extracted Lab 3 work directory before calling `./clean`, `./mk` or `./rn`.

If the compilation succeeds, start the non-linear run:

```bash
./rn
```

> [!WARNING]
> These inlists are set up so this TDC run continues **indefinitely**. It is up to you to decide when to end the run using `Ctrl+C` on Linux or `Cmd+C` on macOS.
> Be warned, this will likely take at least 10 minutes. In the meantime, read through the tasks below. If you reach the end of these tasks and your waveform has not stabilised, take a look at the _If You Are Still Waiting on a Run_ section.


## Task 5: Watch the Diagnostics

The PGSTAR panels are by far the most important diagnostics for this lab. For most students, they already summarise nearly everything that matters for deciding whether the pulsation is developing well and whether a bump is visible.

If you want to know where the supporting output is written, the run also saves files in:

- `png_pulsation/`
- `LOGS_pulsation/`
- `photos/`

> [!TIP]
> Compare your PGSTAR animation with the other students at your table. This is often the fastest way to see how different models behave.

## Task 6: Decide Whether the Run Is Good Enough

For the purpose of this lab, the run is useful once you can see that the kick has produced a coherent pulsation and the amplitude is either:

- still clearly growing
- or close to a repeating finite-amplitude cycle

Signs that the run is doing the right thing:

- `growth` is positive for at least part of the run
- `delta_R`, `delta_logL`, or `delta_Mag` are no longer consistent with numerical noise
- the light, radius, or velocity curves begin to repeat from cycle to cycle

You can see an example of healthy, developed pulsation below.

![pgstar](pgstar_example_labeled.gif)


The five panels labeled with a red number are the most relevant. They show

1. Hertzsprung-Russell diagram. Initially, we expect an ellipsoidal path until the bump develops.
2. luminosity variation in solar luminosity over time, also called the light curve
3. absolute magnitude variation over time
4. radial variation over time
5. radial velocity profile. The initial kick should be plainly visible here


Signs that you should stop and rethink:

- the run exits immediately
- the model never develops a clear periodic signal
- the waveform looks obviously pathological rather than pulsational

> [!IMPORTANT]
> You do not need a perfect production-quality non-linear model. You only need a waveform that is good enough to classify the bump.

{{< details title="What if I accidentally ended my run too early?" closed="true" >}}

If the run stops but has already written restart photos, you can continue from the most recent one:

```bash
./re
```

To restart from a specific photo file:

```bash
./re photo_name
```

This is useful if the model is progressing normally but simply needs more cycles before the bump becomes easy to classify.

Just as in Lab 1, these `photos/` files are for continuing your own run on your own machine.

{{< /details >}}

## Task 7: Inspect the Waveform

Now look at the waveform and decide where the bump appears in the cycle.

Start with the PGSTAR plot. For almost everyone, this will be the easiest and clearest place to identify the bump.

If you want to double-check what you are seeing, you can also look at:

- the saved plots in `png_pulsation/`
- the time series in `LOGS_pulsation/history.data`

If possible, inspect more than one diagnostic. The bump is often easiest to see in a light curve in luminosity or `delta_Mag`, but the radius and surface-velocity curves can help you decide whether a feature is real.

Use the following simple classification:

- `descending branch`: the bump appears after maximum light while the curve is falling
- `middle`: the bump is near the middle of the cycle and not clearly tied to either branch
- `rising branch`: the bump appears before maximum light while the curve is rising
- `no clear bump`: use this only if the waveform is genuinely ambiguous

> [!TIP]
> Do not spend too long debating a borderline case. If the bump is ambiguous, record that uncertainty and move on.

## Task 8: Record Your Result

Add one row for your successful model to the shared class table.

At minimum, record:

- model filename
- initial mass
- `log L` and `log T_eff`, if available from Lab 1
- fundamental period
- whether the pulsation was clearly established
- bump classification
- a short note such as `clear bump`, `weak bump`, or `needed restart`

Once the class table starts to fill up, sort the entries by period and look for the bump progression across the sample.

## Questions for Discussion

As the class table fills in, discuss these questions at your table:

- how does bump location change with period?
- where does the bump move from the descending branch to the rising branch?
- does the class sample support the idea that the morphology is tied to the `P_2/P_0 \approx 0.5` resonance?
- what does the TDC waveform show that the linear analysis in Lab 2 could not show on its own?

## If You Are Still Waiting on a Run

These TDC runs can take a long time to converge, often more than `10 minutes`. If your model is still running and you have some idle time, use that time to do one or more of the following:

- review your Lab 2 notes and make sure your expected period is written down
- look at the shared class table and decide which period range is still undersampled
- inspect the output files you already have and make a preliminary guess about the bump
- compare what you are seeing in PGSTAR with what appears in `history.data`

## Task 9: If You Have Extra Time

If your group finishes the core lab early, here are the most useful next steps, in recommended order:

1. compare your TDC result directly with the linear information you already gathered in Lab 2
2. look more carefully at how the bump appears in luminosity, radius, and velocity together
3. compare your PGSTAR animation with the other students at your table
4. make a movie of your PGSTAR output

You do not need to complete all of these. Pick the next one that feels most useful.

### Option A: Compare Back to Lab 2

If you completed Lab 2, compare your non-linear result with the linear information you already had for the same model.

Ask yourself:

- did a model with positive linear growth turn into a useful non-linear pulsator?
- is the non-linear period similar to the period you expected from the linear analysis?
- did the model you thought would be interesting actually produce a clear bump?

This is a nice way to connect the Friday labs together.

If you also estimated where `P_2/P_0` is closest to `0.5`, compare that expectation with the waveform shape you actually see in the TDC run.

### Option B: Compare Different Diagnostics

If you have a clearly pulsating model, compare the bump location in:

- luminosity-related behavior
- radius
- surface velocity

You may find that the bump is easier to identify in one diagnostic than another. Record that in your notes if it helps explain your classification.

### Option C: Compare with Other Students at Your Table

If several people at your table have useful runs, compare them directly:

- do the bumps appear in different parts of the cycle?
- do the PGSTAR animations suggest a smooth progression across period?
- which models develop the clearest bump?

### Option D: Making a movie

Isn't that animated PGSTAR window neat? Unfortunately, it vanishes once you end the run. Luckily, a bunch of `.png` files are output by MESA, which can be used to recreate the animated PGSTAR plots. You could either flick through them in an image viewer or combine them into a proper movie. MESA comes packaged with some tools to make such movies. To do so, run the following in your terminal:

```bash
images_to_movie "png_pulsation/*.png" my_Cepheid_movie.mp4
```

> [!TIP]
> This `images_to_movie` command lives in the MESA SDK. If the command above ever fails, double-check that the SDK is initialised using `echo $MESASDK_ROOT`.

## Troubleshooting

{{< details title="The run cannot find the model file" closed="true" >}}

Check that:

- the file really exists inside `TDC_Cepheid/mod_dir/`
- `load_model_filename` matches the filename exactly
- you are running from inside `TDC_Cepheid/`

{{< /details >}}

{{< details title="The run builds, but the pulsation never becomes obvious" closed="true" >}}

Try these in order:

- verify that you chose a genuine Cepheid candidate from Lab 1
- switch to a model that has a larger fundamental-mode growth rate in the Lab 2 spreadsheet
- restart with `./re` and let it continue longer
- switch to a fallback model rather than spending the whole lab debugging one difficult case

{{< /details >}}

{{< details title="I am not sure whether I am seeing a real bump" closed="true" >}}

Compare more than one diagnostic:

- light curve in luminosity or `delta_Mag`
- radius variations
- surface velocity

If the same feature appears consistently in more than one place, it is more likely to be real. If not, mark the case as uncertain and move on.

{{< /details >}}

## Challenge Problems

If your group finishes early, try one of these:

- use your Lab 2 linear results to estimate where `P_2/P_0` is closest to `0.5`, then see whether that corresponds to the most interesting waveform shape
- compare the bump location in luminosity, radius, and velocity and decide which diagnostic is most useful
- if you find an unstable radial overtone case, record it as a comparison case, but keep your main focus on the fundamental-mode Hertzsprung progression

### Bonus coding task: time-average the light curve over one cycle

If you would like a more coding-focused extension, modify `run_star_extras` so that it measures a cycle-averaged quantity from the non-linear light curve and compares that average with the corresponding static value from the original model.

One possible version of this task is:

1. identify one full pulsation cycle after the model has reached a reasonably repeatable waveform
2. measure a quantity over that cycle, such as luminosity or magnitude
3. compute the time average over the cycle
4. compare that cycle-averaged value with the static value from the original stellar model

For example, you might compare:

- cycle-averaged luminosity versus the original static luminosity
- cycle-averaged magnitude versus the magnitude implied by the static model

> [!NOTE]
> A simple arithmetic average over output points is not always the same as a true time average if the output sampling is uneven. A better version of this task is to weight the average by the timestep or by the time interval between samples.

Here is one reasonable way to implement this:

#### Step 1: Find the relevant source files

The most useful files to inspect are:

- `src/run_star_extras.f90`
- `src/run_star_extras_TDC_pulsation.inc`
- `src/run_star_extras_TDC_pulsation_defs.inc`

The existing Lab 3 setup already computes per-cycle quantities such as:

- `period`
- `delta_logL`
- `delta_Mag`
- `KE_growth_avg`

and writes them out through the extra-history-column machinery. That makes this a natural place to add one or two more derived quantities.

#### Step 2: Choose what you want to average

Start with one quantity only. Good choices are:

- luminosity
- `log_L`
- a magnitude-like quantity

The simplest first version is to time-average luminosity over one completed pulsation cycle.

#### Step 3: Decide what you will compare against

Pick the corresponding static quantity from the original model. For example:

- cycle-averaged luminosity compared with the model luminosity before the non-linear pulsation becomes large
- cycle-averaged magnitude compared with the magnitude implied by the static luminosity

You do not need to design a perfect scientific definition here. The point is to compare a static value with the value implied by the non-linear cycle.

#### Step 4: Accumulate the average over one cycle

As the run advances, keep track of:

- the value of the quantity you are averaging
- the elapsed time associated with each sample
- the running weighted sum over the current cycle
- the total elapsed time over the current cycle

In other words, your code should conceptually build something like

$$
\langle X \rangle = \frac{\sum X_i \Delta t_i}{\sum \Delta t_i}
$$

over one pulsation cycle.

> [!TIP]
> If you want a simpler first attempt, you can average over the samples within one cycle without time weighting. Just be clear in your notes that this is an approximation.

{{< details title="Hint for Step 4: where could you store the running sums?" closed="true" >}}

One natural place is `src/run_star_extras_TDC_pulsation_defs.inc`, where the Lab 3 setup already stores period-related quantities such as `period`, `delta_logL`, and `delta_Mag`.

You could add a few new variables there, for example:

- a running weighted sum
- a running total time
- the most recent cycle-averaged value
- the difference between the cycle average and the static value

Then update those variables during the evolution in the same part of the code where the period-related diagnostics are already being assembled.

{{< /details >}}

{{< details title="Partial solution for Step 4: example accumulator variables" closed="true" >}}

One possible pattern is to add a few variables to `src/run_star_extras_TDC_pulsation_defs.inc`, for example:

```fortran
      real(dp) :: cycle_sum_L_dt, cycle_sum_dt
      real(dp) :: cycle_avg_L, cycle_avg_L_minus_static
      real(dp) :: static_L
```

Here the idea is:

- `cycle_sum_L_dt` stores the running weighted sum `sum(L * dt)`
- `cycle_sum_dt` stores the running sum `sum(dt)`
- `cycle_avg_L` stores the final cycle-averaged luminosity
- `cycle_avg_L_minus_static` stores the comparison with the static model value
- `static_L` stores the reference luminosity from the starting model

You do not have to use exactly these variable names, but keeping the names explicit will make your code much easier to debug.

{{< /details >}}

#### Step 5: Reset the accumulators at the start of a new cycle

The existing pulsation code already keeps track of completed cycles and period-level information. Use that logic to decide when one cycle has ended and the next has begun.

At the end of each completed cycle:

- compute the average
- save the result somewhere
- reset the running sums for the next cycle

{{< details title="Hint for Step 5: where is the existing cycle logic?" closed="true" >}}

Look in `src/run_star_extras_TDC_pulsation.inc`, especially in the code that already updates:

- `num_periods`
- `period`
- `delta_R`
- `delta_logL`
- `delta_Mag`

That is the part of the setup that already knows when one pulsation cycle has been completed.

{{< /details >}}

{{< details title="Partial solution for Step 5: example update and reset logic" closed="true" >}}

At each timestep, you could accumulate your weighted sums with something like:

```fortran
         cycle_sum_L_dt = cycle_sum_L_dt + s% L(1) * s% dt
         cycle_sum_dt   = cycle_sum_dt   + s% dt
```

Then, when the existing period logic determines that one full cycle has been completed, you could compute and store the average:

```fortran
         if (cycle_sum_dt > 0d0) then
            cycle_avg_L = cycle_sum_L_dt/cycle_sum_dt
            cycle_avg_L_minus_static = cycle_avg_L - static_L
         end if
```

After saving the result for that completed cycle, reset the accumulators:

```fortran
         cycle_sum_L_dt = 0d0
         cycle_sum_dt   = 0d0
```

This is only a sketch, but it shows the basic structure:

1. accumulate during the cycle
2. compute the average at cycle end
3. reset for the next cycle

{{< /details >}}

#### Step 6: Expose the new quantity in the history output

Once you have computed your new cycle-averaged quantity, add it to the custom extra history columns so it appears in `history.data`.

That means updating the part of the code that currently exports values like:

- `period`
- `growth`
- `delta_R`
- `delta_Mag`

You can either:

- replace one of the less important bonus outputs for your experiment, or
- increase the number of extra history columns and append your new quantity

{{< details title="Hint for Step 6: which routines control the extra history output?" closed="true" >}}

The relevant routines are:

- `TDC_pulsation_how_many_extra_history_columns`
- `TDC_pulsation_data_for_extra_history_columns`

These are in `src/run_star_extras_TDC_pulsation.inc`.

If you add new output columns, remember to update both:

- the number of extra columns
- the names and values written into those columns

{{< /details >}}

{{< details title="Partial solution for Step 6: example history-column changes" closed="true" >}}

Suppose you want to add two new history columns:

- the cycle-averaged luminosity
- the difference between that value and the static luminosity

Then one possible change is:

```fortran
      TDC_pulsation_how_many_extra_history_columns = 13
```

instead of `11`.

Then append the new columns in `TDC_pulsation_data_for_extra_history_columns`, for example:

```fortran
         names(i) = 'cycle_avg_L'; vals(i) = cycle_avg_L; i=i+1
         names(i) = 'cycle_avg_L_minus_static'; vals(i) = cycle_avg_L_minus_static; i=i+1
```

Make sure that:

- the number of columns matches the number of values you write
- the names are short enough to be readable in `history.data`
- the quantities are in units you understand when you interpret them later

{{< /details >}}

#### Step 7: Recompile and rerun

If you want to start and kick a new TDC model after editing the Fortran source:

```bash
./clean
./mk
./rn
```

If you want to continue from a previously saved TDC run after recompiling:

```bash
./clean
./mk
./re
```

#### Step 8: Compare the non-linear average with the static value

Once your new quantity appears in the output, compare:

- the cycle-averaged value obtained with TDC
- the corresponding static value from the original model

You can do this for one cycle or for several successive cycles if the run is still evolving.

#### Step 9: Interpret what you find

Write down a short conclusion:

- are the two values nearly the same?
- is there a systematic offset?
- does the offset shrink or grow as the pulsation settles?
- does averaging luminosity directly give a different answer than averaging a magnitude-like quantity?

> [!TIP]
> Keep this as a bonus task. The goal is not to build a perfect analysis pipeline, just to explore whether the non-linear cycle average differs in an interesting way from the static model value.

## Suggested Reading

- [Farag et al. 2026, self-consistent nonlinear classical Cepheid pulsations during stellar evolution with MESA](https://arxiv.org/abs/2603.15766)
- [Bono, Marconi, and Stellingwerf 2000, the Hertzsprung progression](https://ui.adsabs.harvard.edu/abs/2000A%26A...360..245B/abstract)
- [Marconi et al. 2024, the Hertzsprung progression of classical Cepheids in the Gaia era](https://ui.adsabs.harvard.edu/abs/2024MNRAS.529.4210M/abstract)
