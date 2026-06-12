---
weight: 4
author: Sunny Wong
math: true
disableKinds: "rss"
---
# Just-a-module

## Introduction (EOS)

In this tutorial, we'll show some examples on how to use the EOS module outside of MESA. 

### Plotter

The `eos` module comes with a `plotter` that you can use as a stand-alone. This is especially handy for debugging. 

#### Step 1: Set up

| 📋 TASK 1a|
|:--------|
| Copy the `plotter` outside of `MESA`. |

For example, 
```
cp -r $MESA_DIR/eos/plotter <your work directory>/eos_plotter
cd <your work directory>/eos_plotter
```

| 📋 TASK 1b|
|:--------|
| Edit `make/makefile_base`. Comment out the line `MESA_DIR = ../../..` (line 3) using `#`.  |

It should now look like
```
# MESA_DIR = ../../..
```

| 📋 TASK 1c|
|:--------|
| Edit `src/eos_plotter.f90`. At line 70, replace `my_mesa_dir = '../..'` with the path to your `$MESA_DIR`.  |

You can quickly remind yourself where your `$MESA_DIR` is, with the following command:
```
echo $MESA_DIR
```

Line 70 of your `src/eos_plotter.f90` should now look something like 
```
my_mesa_dir = '/Users/swong/work/mesa-26.04.1
```

| 📋 TASK 1d|
|:--------|
| Now let's clean and compile: `./clean && ./mk`. |

{{< details title="What do you see?" closed="true" >}}

You should see something like
```
FC ../src/eos_plotter.f90
../src/eos_plotter.f90:393:55:

  393 |             p = exp(res(i_lnPgas)) + (1d0 / 3d0) * crad * pow4(T)
      |                                                       1
Error: Symbol 'crad' at (1) has no IMPLICIT type
../src/eos_plotter.f90:522:23:

  522 |       lnT = log10T*ln10
      |                       1
Error: Symbol 'ln10' at (1) has no IMPLICIT type; did you mean 'lnd'?
make: *** [eos_plotter.o] Error 1
```

Wait... Why doesn't `MESA` know what the constants are? 

{{< /details >}}

| 📋 TASK 1e|
|:--------|
| Edit your `src/eos_plotter.f90` again. Change the declarations near the top of the file, so that `MESA` knows about the constant definitions. Compile again. |

{{< details title="Partial solution" closed="true" >}}

Near the top, add the line
```
use const_def
```

The top of your `src/eos_plotter.f90` should look like
```
program eos_plotter

   use eos_def
   use eos_lib, only: eos_ptr, eosDT_get
   use chem_def
   use chem_lib
   use const_lib, only: const_init
   use math_lib
   use num_lib, only : dfridr
   use utils_lib, only: set_nan
   use const_def !!! NEW

   ...
```

>[!Note]
> This is specific to version `26.04.1` and will change in the future. 

{{< /details >}}


#### Step 2: Edit inlist_plotter

Before we actually run the plotter, let's first change what it outputs:
| 📋 TASK 2a|
|:--------|
| Open `inlist_plotter` and take a quick look at the contents. |

At lines 88 - 95, you'll see
```
!### pick which quantities to plot against
! valid options are Rho, T, X, Z

xname = 'Rho'
yname = 'T'

! xname = 'X'
! yname = 'Z'
```

The plotter allows us to plot some EOS quantity as a function of `xname` and `yname`, which in this case are the density and temperature (you can also pick hydrogen mass fraction $X$ and the metal mass fraction $Z$, but I haven't had to do this). 

Next, in lines 97 - 103, you'll see
```
!### pick number of points
! values for non-xname, non-yname variables are ignored

nT = 100
nRho = 100
nX = 100
nZ = 100
```

In our case, this means we'll take 100 temperature points and 100 density points. The $X$ and $Z$ variables are ignored because they are not our `xname` and `yname`. 

What are the ranges? In lines 105 - 132, you'll read
```
!### pick plot limits

! center/delta takes precedence over min/max
! center is used when var is not xname/yname

...

! logT_center = 7.3d0
! logRho_center = 0d0

! delta_logT = 0.1
! delta_logRho = 0.1

logT_min = 3
logT_max = 10

logRho_min = -15
logRho_max = 10

```

All this together means that we'll ask MESA to give us EOS quantities for 100 $\log T$ points from 2 to 10, and 100 $\log \rho$ points from -15 to 10.  


| 📋 TASK 2b|
|:--------|
| Set `logT_min = 3.5d0` instead. Mainly just so we're not asking MESA for outputs at too low temperatures (you can try though). Then `./rn`. |

{{< details title="What should you see?" closed="true" >}}

>[!Caution]
> If you see a bunch of python errors, that's okay. What's important is that we have a new file called `eos_plotter.dat`. Check and make sure that it's there. We can always plot the results online. 

>[!Tip]
> If you get a bunch of python errors, try commenting out the line `text.usetex:True` in `mesa_eos_regions.mplstyle`. 



You should see the following plot pop out:
![landscape](/wednesday/jam-eos_plotter.png)

If you look at your directory, you'll also see `eos_plotter.dat` as well as the following plot:
![landscape](/wednesday/jam-eos_regions.png)

`eos_plotter.dat` essentially contains, as a function of $\log \rho$ and $\log T$, which EOS source MESA is using. Each integer gives represents an EOS source:
```
eosdT = 0 (blended)
HELM = 1
OPAL_SCVH = 2
FreeEOS = 3
PC = 4
Skye = 5
CMS = 6
ideal = 7
```

{{< /details >}}


#### Step 3: Plot logP instead

By default, the `eos` `plotter` plots the EOS source that MESA is using. These options are controlled by the `i_var` variable at line 68. If `i_var=0`, MESA will tell you which EOS sources it's using, and lines 39 - 63 tell you what values to use if you want some other EOS quantity. 

```
!### pick which eos quantity to plot
! below for convenience: truth in eos_def.f90
! i_lnPgas = 1
! i_lnE = 2
! i_lnS = 3
! i_mu = 4
! i_lnfree_e = 5
! i_eta = 6
! i_grad_ad = 7
! i_chiRho = 8
! i_chiT = 9
! i_Cp = 10
! i_Cv = 11
! i_dE_dRho = 12
! i_dS_dT = 13
! i_dS_dRho = 14
! i_gamma1 = 15
! i_gamma3 = 16
! i_phase = 17
! i_latent_ddlnT = 18
! i_latent_ddlnRho = 19
! i_frac_HELM = 20
! i_frac_OPAL_SCVH = 21
! i_frac_FreeEOS = 22
! i_frac_PC = 23
! i_frac_Skye = 24
! i_frac_CMS = 25

! zero value used for special logic in the plotter
! regions = 0 (also use special script regions.py)

i_var = 0
```

| 📋 TASK 3|
|:--------|
| Modify `inlist_plotter` so that it plots `lnPgas`. This is the gas pressure, not accounting for radiation pressure. |
>[!Note]
> The EOS plotter gives quantities that are in *natural* logarithm. 

{{< details title="Partial solution" closed="true" >}}

You just need to set `i_var = 1`. Now you can `./rn`. 

{{< /details >}}

{{< details title="What should you see?" closed="true" >}}

>[!Caution]
> If you see a bunch of python errors, that's okay. What's important is that we have a new file called `eos_plotter.dat`. Check and make sure that it's there. We can always plot the results online. 

![landscape](/wednesday/jam-eos_plotter_lnPgas.png)

Note that this quantity is in natural logarithm. But you can also see where the EOS uses ideal gas. 

{{< /details >}}

#### Step 4: Change the composition

In `inlist_plotter`, we picked $\log T$ and $\log \rho$ to be our variables. What is the composition then? 

Well, at line 110 and 111, we have `X_center = 0.70` and `Z_center = 0.02`. These are read by the plotter:
| 📋 TASK 4a|
|:--------|
| Peruse the contents of `src/eos_plotter.f90`. Identify where it sets the composition. |

{{< details title="Partial solution" closed="true" >}}

Lines 226 - 304 have some logical expression to set the hydrogen mass fraction $X$ and metal mass fraction $Z$. Then line 306 does a call to the subroutine to `Set_Composition`, before the program actually makes an EOS call by `call eos_call(&
            handle, i_eos, species, chem_id, net_iso, xa, &
            Rho, log10Rho, T, log10T, &
            res, d_dlnd, d_dlnT, d_dxa, ierr)`. 

{{< /details >}}

| 📋 TASK 4b|
|:--------|
| Peruse the contents of the `Set_Composition` subroutine, and try to understand how it sets the composition. |

{{< details title="Partial solution" closed="true" >}}

The subroutine starts at line 465. 

Lines 469 - 482 basically just set some identifiers for some isotopes, to be passed among the `eos_plotter`, MESA's `net` and `chem` modules (because say, id=1 doesn't refer to the same isotopes in `net` and `chem`). The ids in `eos_plotter` are defined at line 16 if you're curious: `integer, parameter :: h1=1, he3=2, he4=3, c12=4, n14=5, o16=6, ne20=7, f20=8, o20=9, &
      mg24=10, na24=11, ne24=12, si28=13, fe56=14`. 

Finally, lines 504 - 509 set the mass fractions of various isotopes:
```
xa = 0d0
xa(h1) = X
xa(c12) = 0.5d0*Z
xa(o16) = 0.5d0*Z
xa(fe56) = 0.0
xa(he4) = 1d0 - xa(h1) - xa(c12) - xa(o16) - xa(fe56)
```

It basically sets the hydrogen mass fraction $X$, splits the metal mass fraction $Z$ between ${^{12}\rm{C}}$ and ${^{16}\rm{O}}$, and leave the rest to helium. 

{{< /details >}}


| 📋 TASK 4c|
|:--------|
| Modify the `Set_Composition` subroutine, so that it gives you 99\% ${^{4}\rm{He}}$ and 1\% ${^{14}\rm{N}}$. This would be useful for post-main sequence stars, for example. **Complile and run** again. |

{{< details title="Partial solution" closed="true" >}}

Set 
```
xa = 0d0
!xa(h1) = X
!xa(c12) = 0.5d0*Z
!xa(o16) = 0.5d0*Z
!xa(fe56) = 0.0
xa(n14) = 0.01d0
xa(he4) = 1d0 - xa(n14) !- xa(h1) - xa(c12) - xa(o16) - xa(fe56)
```

Now you're ready to compile and run again. 

{{< /details >}}

{{< details title="What you should see" closed="true" >}}

You may see the terminal spitting out things like
```bash
write /Users/mesa/work/mesa-26.04.1/data/eosDT_data/cache/mesa-eosDT_00z00x.bin
write /Users/mesa/work/mesa-26.04.1/data/eosDT_data/cache/mesa-eosDT_02z00x.bin
```
if MESA has never had this composition cached before. This shows that MESA is caching EOS data for $Z = 0.02$ and $X = 0$, and $Z = 0$ and $X = 0$. It will interpolate between these two for our target $Z = 0.01$. 

Then the following plot shows up:
![landscape](/wednesday/jam-eos_plotter_lnPgas_He0.99_N0.01.png)

>[!Note]
> You may see features in this plot coming from blends between different EOS's. 


{{< /details >}}

#### Visualizing `eos_plotter.dat`

The EOS plotter outputs a text file called `eos_plotter.dat`, which contains the EOS quantities we specified in `inlist_plotter`, as a function of $\log_{10} \rho$ and $\log_{10} T$. Here we show an example of how we can visualize this. 

Go to [this](https://drive.google.com/drive/folders/1WXGQXeOltcUsRPIKlDxFFr7Ae_WJDNM_?usp=drive_link) Google Colab notebook, **make a copy**, follow the instructions there and plot your own logPgas. 

#### Final remarks

There are many other things you can do with the EOS plotter. 

- For now we have been using the default EOS blend, but you can imagine changing the blend a little bit, or even implement your own EOS in the mix. In `inlist_plotter` there is a whole `&eos` section where you can add the EOS controls, just like you would for MESA star. Take a look [here](https://docs.mesastar.org/en/latest/eos/defaults.html) at the options. 
- You can also check the partial derivatives of EOS quantities. These are the `doing_partial` controls in `inlist_plotter`. Sometimes there are regions where the partial derivatives are pretty bad and lead to convergence issues, especially at the blend regions between different EOS's. 
- You can also get EOS quantities interatively without the plotter, this is well-documented by Frank Timmes [here](https://docs.mesastar.org/en/latest/using_mesa/just_a_module.html#equation-of-state). 


## Introduction (kap)

### Plotter

The `kap` module also comes with a `plotter` that you can use as a stand-alone. This is especially handy for debugging. 

#### Step 1: Set up

| 📋 TASK 1a|
|:--------|
| Copy the `plotter` outside of `MESA`. |

For example, 
```
cp -r $MESA_DIR/kap/plotter <your work directory>/kap_plotter
cd <your work directory>/kap_plotter
```

| 📋 TASK 1b|
|:--------|
| Edit `make/makefile_base`. Comment out the line `MESA_DIR = ../../..` (line 3) using `#`.  |

It should now look like
```
# MESA_DIR = ../../..
```

| 📋 TASK 1c|
|:--------|
| Edit `src/kap_plotter.f90`. At line 70, replace `my_mesa_dir = '../..'` with the path to your `$MESA_DIR`.  |

You can quickly remind yourself where your `$MESA_DIR` is, with the following command:
```
echo $MESA_DIR
```

Line 77 of your `src/kap_plotter.f90` should now look something like 
```
my_mesa_dir = '/Users/swong/work/mesa-26.04.1
```

| 📋 TASK 1d|
|:--------|
| Now let's clean and compile: `./clean && ./mk`. |


#### Step 2: Setting up and Making First Plot

| 📋 TASK 2|
|:--------|
| Now let's edit `inlist_plotter`. |

- In line 9 of the `&kap` section, set `Zbase = 0.02d0` , for a $Z = 0.02$ mixture. 
- In line 33 of the `&plotter` section, make sure that
```
doing_partial = .false.
doing_dfridr = .false.
doing_d_dlnd = .false.
```
We won't look at partial derivatives today. 

- At line 59, set `X_center = 0.7d0` and `Z_center = 0.02d0`, we'll be using $X = 0.7$, $Z = 0.02$. 
- At line 70 - 74, comment the lines (with `!`)
```
!logT_center = 6d0
!logRho_center = -2d0

!delta_logT = 8d0
!delta_logRho = 24d0
```
- At lines 76 - 80, uncomment the lines and set
```
logT_min = 3.0d0
logT_max = 7.0d0

logRho_min = -10d0
logRho_max = 6d0
```

Finally, 
```
./rn
```

{{< details title="What do you see?" closed="true" >}}

>[!Caution]
> If you see a bunch of python errors, that's okay. What's important is that we have a new file called `kap_plotter.dat`. Check and make sure that it's there. We can always plot the results online. 

If python works, you should see a plot like this:
![landscape](/wednesday/jam-kap_plotter.png)

We can visualize this with the Google Colab notebook [here](https://drive.google.com/drive/folders/1WXGQXeOltcUsRPIKlDxFFr7Ae_WJDNM_?usp=drive_link). Make sure you **make a copy**, follow the instructions there and plot your own opacity table. 

You should be able to produce a plot like this:
![landscape](/wednesday/jam-kap_plotter_notebook.png)


{{< /details >}}

#### Step 3: Changing `kap` options

You can also change the opacity options in `inlist_plotter`, using the options [here](https://docs.mesastar.org/en/latest/reference/kap.html). 

For instance, you can change the low temperature opacity from Ferguson et al. 2005 to Freedman et al. 2008. 


| 📋 TASK 3|
|:--------|
| Now let's edit `inlist_plotter` to have it use Freedman et al. 2008 for low temperature opacities, and run. |

{{< details title="Partial solution" closed="true" >}}

In the `&kap` section of your `inlist_plotter`, add
```
kap_lowT_prefix = 'lowT_Freedman11'
```

{{< /details >}}



{{< details title="What do you see?" closed="true" >}}

If python works, you should see a plot like this:
![landscape](/wednesday/jam-kap_plotter_Freedman.png)
which indeed looks different than before.

If this is your first time using the Freedman low-T opacities, your terminal should spit out something like this:
```bash
write /Users/swong/work/mesa-26.04.1/data/kap_data/cache/lowT_Freedman11_z0.02.bin
write /Users/swong/work/mesa-26.04.1/data/kap_data/cache/lowT_Freedman11_z0.04.bin
```

And if you visualize this with the Google Colab notebook [here](https://drive.google.com/drive/folders/1WXGQXeOltcUsRPIKlDxFFr7Ae_WJDNM_?usp=drive_link), you should be able to see a plot like the following:
![landscape](/wednesday/jam-kap_plotter_Freedman_notebook.png)

{{< /details >}}


#### Other things you can do

- You can modify `inlist_plotter` to have the plotter output partial derivatives of the opacity. Sometimes this is useful for debugging. 
- You can explore the effects of using different opacity sources, or even supply your own opacity. 
- Much like in the `eos` `plotter`, you can set your own composition by modifying `src/kap_plotter.f90`. 