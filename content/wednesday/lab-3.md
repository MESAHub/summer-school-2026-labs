---
weight: 1
author: Tryston Raecke, Josh Wanninger, Sunny Wong, Michael Zingale
math: true
disableKinds: "rss"
---
# Minilab 3: They all go broke

So far we have changed the nuclear net to include more reactions, and looked at the effect of Urca cooling from the $^{23}\rm{Na}$-$^{23}\rm{Ne}$ pair on the stellar structure. 

We have been using an accretion rate $\dot{M}= 10^{-6} M_{\odot} \rm{yr}^{-1}$ and weak reaction rates from Suzuki et al. 2016. But what if we have different accretion histories, or reaction rates? 

Now we will do a crowdsourcing to look at how the evolution changes with the accretion rate $\dot{M}$, reaction networks, and reaction rates. 
The goal is to look at how they change the core properties at the onset of oxygen ignition, because whether an electron-capture supernova undergoes a thermonuclear explosion or core-collapse (implosion) is extremely sensitive to the central density. 

## Crowdsourcing

### Step 0: Start up

| 📋 TASK 1 |
|:--------|
| **Download** the starting point from the [Google Drive]( FIXLINK ) to a local working directory. |

The starting point is a very simple setup. 


### Step 1: Pick a model

| 📋 TASK 2 |
|:--------|
|  Go to the spreadsheet [here]( FIXLINK ). Pick any combination of the accretion rate, reaction network and reaction rates provided. Users with more cores should pick more computationally expensive ones. |


### Step 2: Changing the accretion rate

| 📋 TASK 3 |
|:--------|
| Edit `inlist_accrete` to set the accretion rate that you chose. |



{{< details title="What variable needs to be changed?" closed="true" >}}

{{< /details >}}



{{< details title="Partial solution" closed="true" >}}

In `&controls`, set `mass_change = <your value>`. 

{{< /details >}}

### Step 3: Build your network

| 📋 TASK 3 |
|:--------|
| **Edit `example.net`** to add the nuclear species and reactions connecting them. **Click on the tabs below** to review the instructions for your specific net. |

> [!NOTE]
> Some of these nets are the same in labs 1 and 2. Feel free to use them. Check the general hints if you need help. 

{{< details title="ONe.net" closed="true" >}}
Species to include:
- ${^{1}\rm{H}}$
- ${^{4}\rm{He}}$
- ${^{16}\rm{O}}$
- ${^{20}\rm{Ne}}$
- ${^{20}\rm{F}}$
- ${^{20}\rm{O}}$
- ${^{23}\rm{Na}}$
- ${^{24}\rm{Mg}}$
- ${^{25}\rm{Mg}}$
- ${^{28}\rm{Si}}$

Reactions to include:
- ${^{16}\rm{O}} + {^{16}\rm{O}} \to \rm{products}$ (specifically, use the reaction ```r1616```)
- ${^{20}\rm{Ne}} + {e^{-}} \to {^{20}\rm{F}} + \nu_{e}$
- ${^{20}\rm{F}} \to {^{20}\rm{Ne}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{20}\rm{F}} + {e^{-}} \to {^{20}\rm{Ne}} + \nu_{e}$
- ${^{20}\rm{O}} \to {^{20}\rm{F}} + {e^{-}} + \bar{\nu}_{e}$

{{< details title="Partial solutions" closed="true" >}}
Your net should have the following: 
```fortran
add_isos(
    h1
    he4
    o16
    ! for Ne20 - F20 - O20
    ne20
    f20
    o20
    ! for other accreted species
    na23
    mg24
    mg25
    ! for O ignition
    si28
)

add_reactions(
    ! for oxygen ignition
    r1616
    ! for Ne20 - F20 - O20
    r_ne20_wk_f20
    r_f20_wk-minus_ne20
    r_f20_wk_o20
    r_o20_wk-minus_f20
)
```

{{< /details >}}

{{< /details >}}



{{< details title="ONeMg.net" closed="true" >}}
Species to include:
- ${^{1}\rm{H}}$
- ${^{4}\rm{He}}$
- ${^{16}\rm{O}}$
- ${^{20}\rm{Ne}}$
- ${^{20}\rm{F}}$
- ${^{20}\rm{O}}$
- ${^{23}\rm{Na}}$
- ${^{24}\rm{Mg}}$
- ${^{24}\rm{Na}}$
- ${^{24}\rm{Ne}}$
- ${^{25}\rm{Mg}}$
- ${^{28}\rm{Si}}$

Reactions to include:
- ${^{16}\rm{O}} + {^{16}\rm{O}} \to \rm{products}$ (specifically, use the reaction ```r1616```)
- ${^{20}\rm{Ne}} + {e^{-}} \to {^{20}\rm{F}} + \nu_{e}$
- ${^{20}\rm{F}} \to {^{20}\rm{Ne}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{20}\rm{F}} + {e^{-}} \to {^{20}\rm{Ne}} + \nu_{e}$
- ${^{20}\rm{O}} \to {^{20}\rm{F}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{24}\rm{Mg}} + {e^{-}} \to {^{24}\rm{Na}} + \nu_{e}$
- ${^{24}\rm{Na}} \to {^{24}\rm{Mg}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{24}\rm{Na}} + {e^{-}} \to {^{24}\rm{Ne}} + \nu_{e}$
- ${^{24}\rm{Ne}} \to {^{24}\rm{Na}} + {e^{-}} + \bar{\nu}_{e}$

{{< details title="Partial solutions" closed="true" >}}
Your net should have the following: 
```fortran
add_isos(
    h1
    he4
    o16
    ! for Ne20 - F20 - O20
    ne20
    f20
    o20
    ! for Mg24 - Na24 - Ne24
    mg24
    na24
    ne24
    ! for other accreted species
    na23
    mg25
    ! for O ignition
    si28
)

add_reactions(
    ! for oxygen ignition
    r1616
    ! for Ne20 - F20 - O20
    r_ne20_wk_f20
    r_f20_wk-minus_ne20
    r_f20_wk_o20
    r_o20_wk-minus_f20
    ! for Mg24 - Na24 - Ne24
    r_mg24_wk_na24
    r_na24_wk-minus_mg24
    r_na24_wk_ne24
    r_ne24_wk-minus_na24
)
```

{{< /details >}}

{{< /details >}}


{{< details title="ONeNa.net" closed="true" >}}
Species to include:
- ${^{1}\rm{H}}$
- ${^{4}\rm{He}}$
- ${^{16}\rm{O}}$
- ${^{20}\rm{Ne}}$
- ${^{20}\rm{F}}$
- ${^{20}\rm{O}}$
- ${^{23}\rm{Na}}$
- ${^{23}\rm{Ne}}$
- ${^{24}\rm{Mg}}$
- ${^{25}\rm{Mg}}$
- ${^{28}\rm{Si}}$

Reactions to include:
- ${^{16}\rm{O}} + {^{16}\rm{O}} \to \rm{products}$ (specifically, use the reaction ```r1616```)
- ${^{20}\rm{Ne}} + {e^{-}} \to {^{20}\rm{F}} + \nu_{e}$
- ${^{20}\rm{F}} \to {^{20}\rm{Ne}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{20}\rm{F}} + {e^{-}} \to {^{20}\rm{Ne}} + \nu_{e}$
- ${^{20}\rm{O}} \to {^{20}\rm{F}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{23}\rm{Na}} + {e^{-}} \to {^{23}\rm{Ne}} + \nu_{e}$
- ${^{23}\rm{Ne}} \to {^{23}\rm{Ne}} + {e^{-}} + \bar{\nu}_{e}$

{{< details title="Partial solutions" closed="true" >}}
Your net should have the following: 
```fortran
add_isos(
    h1
    he4
    o16
    ! for Ne20 - F20 - O20
    ne20
    f20
    o20
    ! for Na23 - Ne23
    na23
    ne23
    ! for other accreted species
    mg24
    mg25
    ! for O ignition
    si28
)

add_reactions(
    ! for oxygen ignition
    r1616
    ! for Ne20 - F20 - O20
    r_ne20_wk_f20
    r_f20_wk-minus_ne20
    r_f20_wk_o20
    r_o20_wk-minus_f20
    ! for Na23 - Ne23 pair
    r_na23_wk_ne23
    r_ne23_wk-minus_na23
)
```

{{< /details >}}

{{< /details >}}



{{< details title="ONeMgNa.net" closed="true" >}}
Species to include:
- ${^{1}\rm{H}}$
- ${^{4}\rm{He}}$
- ${^{16}\rm{O}}$
- ${^{20}\rm{Ne}}$
- ${^{20}\rm{F}}$
- ${^{20}\rm{O}}$
- ${^{23}\rm{Na}}$
- ${^{23}\rm{Ne}}$
- ${^{24}\rm{Mg}}$
- ${^{24}\rm{Na}}$
- ${^{24}\rm{Ne}}$
- ${^{25}\rm{Mg}}$
- ${^{28}\rm{Si}}$

Reactions to include:
- ${^{16}\rm{O}} + {^{16}\rm{O}} \to \rm{products}$ (specifically, use the reaction ```r1616```)
- ${^{20}\rm{Ne}} + {e^{-}} \to {^{20}\rm{F}} + \nu_{e}$
- ${^{20}\rm{F}} \to {^{20}\rm{Ne}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{20}\rm{F}} + {e^{-}} \to {^{20}\rm{Ne}} + \nu_{e}$
- ${^{20}\rm{O}} \to {^{20}\rm{F}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{24}\rm{Mg}} + {e^{-}} \to {^{24}\rm{Na}} + \nu_{e}$
- ${^{24}\rm{Na}} \to {^{24}\rm{Mg}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{24}\rm{Na}} + {e^{-}} \to {^{24}\rm{Ne}} + \nu_{e}$
- ${^{24}\rm{Ne}} \to {^{24}\rm{Na}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{23}\rm{Na}} + {e^{-}} \to {^{23}\rm{Ne}} + \nu_{e}$
- ${^{23}\rm{Ne}} \to {^{23}\rm{Ne}} + {e^{-}} + \bar{\nu}_{e}$

{{< details title="Partial solutions" closed="true" >}}
Your net should have the following: 
```fortran
add_isos(
    h1
    he4
    o16
    ! for Ne20 - F20 - O20
    ne20
    f20
    o20
    ! for Mg24 - Na24 - Ne24
    mg24
    na24
    ne24
    ! for Na23 - Ne23
    na23
    ne23
    ! for other accreted species
    mg25
    ! for O ignition
    si28
)

add_reactions(
    ! for oxygen ignition
    r1616
    ! for Ne20 - F20 - O20
    r_ne20_wk_f20
    r_f20_wk-minus_ne20
    r_f20_wk_o20
    r_o20_wk-minus_f20
    ! for Mg24 - Na24 - Ne24
    r_mg24_wk_na24
    r_na24_wk-minus_mg24
    r_na24_wk_ne24
    r_ne24_wk-minus_na24
    ! for Na23 - Ne23 pair
    r_na23_wk_ne23
    r_ne23_wk-minus_na23
)
```

{{< /details >}}

{{< /details >}}



{{< details title="ONeMg2Na.net" closed="true" >}}
Species to include:
- ${^{1}\rm{H}}$
- ${^{4}\rm{He}}$
- ${^{16}\rm{O}}$
- ${^{20}\rm{Ne}}$
- ${^{20}\rm{F}}$
- ${^{20}\rm{O}}$
- ${^{23}\rm{Na}}$
- ${^{23}\rm{Ne}}$
- ${^{24}\rm{Mg}}$
- ${^{24}\rm{Na}}$
- ${^{24}\rm{Ne}}$
- ${^{25}\rm{Mg}}$
- ${^{25}\rm{Na}}$
- ${^{25}\rm{Ne}}$
- ${^{28}\rm{Si}}$

Reactions to include:
- ${^{16}\rm{O}} + {^{16}\rm{O}} \to \rm{products}$ (specifically, use the reaction ```r1616```)
- ${^{20}\rm{Ne}} + {e^{-}} \to {^{20}\rm{F}} + \nu_{e}$
- ${^{20}\rm{F}} \to {^{20}\rm{Ne}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{20}\rm{F}} + {e^{-}} \to {^{20}\rm{Ne}} + \nu_{e}$
- ${^{20}\rm{O}} \to {^{20}\rm{F}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{24}\rm{Mg}} + {e^{-}} \to {^{24}\rm{Na}} + \nu_{e}$
- ${^{24}\rm{Na}} \to {^{24}\rm{Mg}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{24}\rm{Na}} + {e^{-}} \to {^{24}\rm{Ne}} + \nu_{e}$
- ${^{24}\rm{Ne}} \to {^{24}\rm{Na}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{23}\rm{Na}} + {e^{-}} \to {^{23}\rm{Ne}} + \nu_{e}$
- ${^{23}\rm{Ne}} \to {^{23}\rm{Ne}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{25}\rm{Mg}} + {e^{-}} \to {^{25}\rm{Na}} + \nu_{e}$
- ${^{25}\rm{Na}} \to {^{25}\rm{Mg}} + {e^{-}} + \bar{\nu}_{e}$
- ${^{25}\rm{Na}} + {e^{-}} \to {^{25}\rm{Ne}} + \nu_{e}$
- ${^{25}\rm{Ne}} \to {^{25}\rm{Ne}} + {e^{-}} + \bar{\nu}_{e}$

{{< details title="Partial solutions" closed="true" >}}
Your net should have the following: 
```fortran
add_isos(
    h1
    he4
    o16
    ! for Ne20 - F20 - O20
    ne20
    f20
    o20
    ! for Mg24 - Na24 - Ne24
    mg24
    na24
    ne24
    ! for Na23 - Ne23
    na23
    ne23
    ! for Mg25 - Na25 - Ne25
    mg25
    na25
    ne25
    ! for O ignition
    si28
)

add_reactions(
    ! for oxygen ignition
    r1616
    ! for Ne20 - F20 - O20
    r_ne20_wk_f20
    r_f20_wk-minus_ne20
    r_f20_wk_o20
    r_o20_wk-minus_f20
    ! for Mg24 - Na24 - Ne24
    r_mg24_wk_na24
    r_na24_wk-minus_mg24
    r_na24_wk_ne24
    r_ne24_wk-minus_na24
    ! for Na23 - Ne23 pair
    r_na23_wk_ne23
    r_ne23_wk-minus_na23
    ! for Mg25 - Na25 - Ne25
    r_mg25_wk_na25
    r_na25_wk-minus_mg25
    r_na25_wk_ne25
    r_ne25_wk-minus_na25
)
```

{{< /details >}}

{{< /details >}}



{{< details title="General hint for adding isotopes" closed="true" >}}
For adding an isotope without automatically connecting it to others, add the following in your net
```fortran
add_isos(
    <isotope name>
)
```
{{< /details >}}



{{< details title="General hint for reaction names" closed="true" >}}
For adding reactions, add the following in your net
```fortran
add_reactions(
    <reaction name>
)
```
You can find the full list of reaction names [here](https://docs.mesastar.org/en/latest/net/nets.html#creating-a-custom-net), but you'll just need:
- Electron capture reactions $X + e^{-} \to Y$ have the form ```r_x_wk_y```. 
- Beta decay reactions $Y \to X + e^{-}$ have the form ```r_y_wk-minus_x```. 
- Alpha capture reactions that release a photon $ C + \alpha \to D + \gamma $ have the form ```r_c_ag_d```. (Think: ```a``` for alpha, ```g``` for gamma). 
{{< /details >}}

### Step 4: Use your network

| 📋 TASK 4 |
|:--------|
| Edit `inlist_accrete` to have it use your specific network. |

> [!NOTE]
> You can do the following sanity check: 
> In ``star_job`` in ``inlist_common``, set ``show_net_species_info = .true.`` and ``show_net_reactions_info = .true.``. 
> Then do ``./rn`` and let MESA run for a few steps. MESA will first print out the species and reactions in the net. 
> Once you see that, just do ``ctrl+c`` to stop. 

> [!WARNING]
> If you haven't yet, do ``./clean && ./mk`` first.



### Step 5: Set reaction rate source

So far we have been using the Suzuki et al. rates, but with new experimental and theoretical data, some of these rates could change. In this crowdsourcing exercise, some of you will be implementing custom rates provided by us, or ask MESA to calculate weak reaction rates on the fly. 

Check the Google spreadsheet [here](LINK) to remind yourself which rates you picked. 

> [!NOTE]
> Not everyone will get to implement custom rates / MESA on-the-fly weak rates, but there will be plenty of time at the end of this lab. Come back here for bonus points! 

-----

{{< tabs items="Suzuki Rates,Custom Weak Rates,Special (on-the-fly) Weak Rates" >}}

<!-- Suzuki rates -->
{{< tab name="Suzuki Rates" >}}

#### Step 5: Using Suzuki Rates

| 📋 TASK 5 |
|:--------|
| **Edit your inlist** to ask MESA to use Suzuki weak rates. |

{{< details title="Hint: which inlist option?" closed="true" >}}
You can easily search for this: 
```fortran
grep -r suzuki $MESA_DIR/star/defaults
```
{{< /details >}}

{{< details title="Partial solutions" closed="true" >}}
You need this one line in your ``star_job`` section of your inlist:
```fortran
use_suzuki_weak_rates = .true.
```
{{< /details >}}

> [!NOTE]
> The Suzuki tables only cover $A=17-28$. 

{{< /tab >}}

<!-- Custom weak rates -->
{{< tab name="Custom Weak Rates" default="true" >}}

You can supply your own tabulated weak rates to MESA. Here we will show you how to use this feature. 

> [!NOTE]
> You can also do this for *regular* reactions, but here we'll show you how to use custom *weak* reaction rates. 

#### Step 5a: Tell MESA to use a custom rate table

We first need to tell MESA the location of the directory (which we'll call `tables_custom`) to find the tabulated custom rates. This is an inlist option. 

{{< details title="Hint: how to find this inlist option?" closed="true" >}}
Look up ``rate_table`` in ``$MESA_DIR/star/defaults/``:
```bash
grep -r rate_table $MESA_DIR/star/defaults/
```
{{< /details >}}

{{< details title="Partial Solution" closed="true" >}}
Add the following to the ``star_job`` section of your inlist:
```fortran
rate_table = 'tables_custom'
```
{{< /details >}}

#### Step 5b: Download data

| 📋 TASK 5b |
|:--------|
| **Download** the weak rate tables [here]() to your working directory and **unzip** it. |

After that, your working directory should look like:

{{< filetree/container >}}
  {{< filetree/folder name="work directory" >}} .
    {{< filetree/file name="other things" >}} .
    {{< filetree/folder name="tables_custom" >}} .
        {{< filetree/file name="weak_rate_list.txt">}}  .
        {{< filetree/file name="on-the-fly_r_f20_wk_o20.h5">}} .
        {{< filetree/file name="other h5 files" >}} .
    {{< /filetree/folder >}}
  {{< /filetree/folder >}}
{{< /filetree/container >}}

Each ``h5`` file contains the rates for each weak reaction, for example, ``on-the-fly_r_f20_wk_o20.h5`` for the electron capture reaction ${^{20}\rm{F} + e^{-} \to {^{20}\rm{O}}}$. 

#### Step 5c: Edit weak_rates.list

Once we point MESA to `rates_dir`, it will look for `rate_list.txt` (for regular reactions, which we won't modify) and `weak_rate_list.txt` (for weak reactions), *if* they exist. 
These two lists tell MESA the reaction names and the corresponding file names. 

| 📋 TASK 5c |
|:--------|
| **Add** the following four reactions to  **`weak_rate_list.txt`**. Take a look at `weak_rate_list.txt` to see what is needed. |
- ${^{20}\rm{Ne}} + e^{-} \to {^{20}\rm{F}} + \nu_{e}$
- ${^{20}\rm{F}} \to {^{20}\rm{Ne}} + e^{-} + \bar{\nu}_{e}$
- ${^{20}\rm{F}} + e^{-} \to {^{20}\rm{O}} + \nu_{e}$
- ${^{20}\rm{O}} \to {^{20}\rm{F}} + e^{-} + \bar{\nu}_{e}$

> [!WARNING]
> We have already included the other weak reactions for you. Do *not* remove any of the other reactions. 

{{< details title="Hint" closed="true" >}}
The format is as follows:
```fortran
<reaction name> <h5 file name>
```
{{< details title="What is the reaction name format again?" closed="true" >}}
For electron capture reactions ($X + e^{-} \to Y + \nu_{e}$), the format is `r_x_wk_y`. 
For beta decay reactions ($Y \to X + e^{-} + \bar{\nu}_{e}$), the format is `r_x_wk-minus_y`. 
{{< /details >}}
{{< /details >}}

{{< details title="Partial solution" closed="true" >}}
You need to add the following to `weak_rate_list.txt`: 
```fortran
r_ne20_wk_f20 'on-the-fly_r_ne20_wk_f20.h5'
r_f20_wk-minus_ne20 'on-the-fly_r_f20_wk-minus_o20.h5'
r_f20_wk_o20 'on-the-fly_r_f20_wk_o20.h5'
r_o20_wk-minus_f20 'on-the-fly_r_o20_wk-minus_f20.h5'
```
{{< /details >}}

{{< /tab >}}

<!-- Special rates -->
{{< tab name="blah" >}}

blah

{{< /tab >}}

{{< /tabs >}}



Now you're ready to go!

### Step 6: Declaring Bankrupcy

| 📋 TASK 6 |
|:--------|
| The only thing stopping your white dwarf from getting bankrupt is just you hitting ``./rn``. **Record the central density of your model in the Google spreadsheet** at the end of the run. |

> [!WARNING]
> If you haven't yet, do ``./clean && ./mk`` first.


## Review reaction flow with pynucastro

We can easily visualize the reaction flow with the ``pynucastro`` and build up some intuition. 
Go to [this](blah) Google colab notebook and go through the exercises. 

## Bonus exercises 

We have done many things in this lab to ensure short runtimes. Here are a few suggested exercises you can try towards building a better model. 

Do **not** attempt these all at once! Your run will be unbearably slow. 

### Bigger reaction networks



### Time Resolution

### Spatial Resolution

### Skye EOS


