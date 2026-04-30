---
weight: 1
author: Tryston Raecke, Sunny Wong, Josh Wanninger, Michael Zingale
math: true
---
# Minilab 1: Place Your Bets: Explode or Implode?


## Introduction

- (Briefly) What is the URCA Process and why is it important
- How this relates to the choice of nuclear reaction network
- Intro to lab -- From a starting White Dwarf composition, will build a nuclear net, then use varying accretion rates to map initial density at oxygen flame


### Helpful Links

The general Google drive for these Wednesday labs can be found [HERE]( FIXLINK ). 
More specifically, the files for Lab 1 can be found [HERE]( FIXLINK ). This drive contains the starting point, partial solutions (separated by task), and a full solution. You do **not** need to download the entire drive!


## Instructions

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

Notes:
observe O ignition in O/Ne WD (ONe.net)
	small network (p, He4, O16, Ne20, F20, O20, Si28)
	stopping condition at log T ~ 9.1 – can’t handle a flame
run star extras prep
	look at neutrino energy in pgstar
custom stopping condition
	add inert nuclei in prep for reactions in later labs
	save a model that can be used with larger net in next lab

### Step 0: Start Up

| 📋 TASK 1 |
|:--------|
| **Download** the starting point from the [Google Drive]( FIXLINK ) to a local working directory. |

This starting point is a standard set of MESA files complete with a precomputed 1.1 M<sub>&#9737;</sub> white dwarf model.

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

`inlist_common` holds the set of defaults that we want to be common between various accretion runs. The primary point of this is to make changes to runs easier and more modular. Instead of having to sort through walls of variables for each change, the core functionality can be stored in common.

Now let's look over the file. You will notice that some variables have already been set to help to more aggressively relax tolerance and help the model converge at later times.

Starting with `&star_jobs`, ...

| 📋 TASK 1 |
|:--------|
| In `&star_jobs`, **update `inlist_common`** to turn on ___ |


{{< details title="Hint: What variables need to be changed?" closed="true" >}}

....

{{< /details >}}

Next in `&controls`,

| 📋 TASK 1 |
|:--------|
| In `&controls`, **update `inlist_common`** to turn on ___ |


### Step 3: Inlist Accrete

Starting with `&star_jobs`, ...

| 📋 TASK 1 |
|:--------|
| In `&star_jobs`, **update `inlist_accrete`** to turn on ___ |


{{< details title="Hint: What variables need to be changed?" closed="true" >}}
...


{{< /details >}}

Next in `&controls`, ...

| 📋 TASK 1 |
|:--------|
| In `&controls`, **update `inlist_accrete`** to turn on ___ |


### Step 4: Building a Nuclear Network


| 📋 TASK 1 |
|:--------|
| **update `ONe.net`** to include the above isotopes |

| 📋 TASK 1 |
|:--------|
| **update `ONe.net`** to include the above isotopes |


### Step 5: History/Profile Columns


| 📋 TASK 5 |
|:--------|
| **Uncomment**  in `history_columns.list`. 
 **Uncomment**  in `profile_columns.list`. |


### Step 6: Inlist Pgstar

| 📋 TASK 1 |
|:--------|
| **update `inlist_pgstar`** to ... |


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

Run through stopping condition

| 📋 TASK 1 |
|:--------|
| **Run** the model (Again)! Observe the...  |

> [!IMPORTANT]
> Do not forget to `./clean`, then `./mk`, then `./rn`


## BONUS



## References
[^1]:

[^2]:
