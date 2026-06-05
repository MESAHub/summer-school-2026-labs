---
title: "Lab 3: Beyond the Core: Echoes of Overshoot"
author: Meng Sun (Lead), Caleb Eastlund, Ducheng Lu, Daniel Lecoanet (Lecturer)
weight: 3
math: true
toc: true
linkTitle: Lab 3
---

## Overview and Starting Files

In this lab, we will study how different convective boundary mixing prescriptions affect stellar evolution, internal structure, and g-mode pulsations. There are three treatments of mixing near the top boundary of a hydrogen burning convective core:

1. step overshooting,
2. exponential overshooting,
3. convective penetration.

The main goal is to understand how these mixing prescriptions modify the near-core chemical-gradient region and the Brunt–Väisälä frequency profile. These structural differences may leave measurable signatures in stellar eigenmodes.

We use a two-step evolution. Taking the step overshooting case as an example:

1. `inlist_step_ov_ZAMS` evolves the model from the pre-main sequence to the ZAMS and saves the ZAMS model for the next step.
2. `inlist_step_ov_MS` starts from the saved ZAMS model and evolves the star to a later main-sequence phase. During this step, MESA also outputs `.GYRE` files for the asteroseismic analysis.

<!-- Before running the models, remember to replace all placeholder values such as

```fortran
X.X
``` -->

<!-- with the parameter values assigned in the [spreadsheet](https://docs.google.com/spreadsheets/d/1v9Dq4AV1ZGssSdy1lQE3uiXW0afyK1mRk9uvBgGOaGI/edit?usp=sharing). -->

<!-- For the current grid, use:

```text
Step overshooting:
0.02, 0.14, 0.28

Exponential overshooting:
0.002, 0.014, 0.028
``` -->

In the first part of the lab, we will build MESA models using different mixing prescriptions. Next, we will inspect their internal structures at an intermediate main-sequence stage. Finally, we will use GYRE to compute g-mode frequencies, compare them with a reference set of modes, and identify the best-fit model.

**[Here](/tuesday/downloads/lab3/day2_lab3.zip) is the working directory to get you started.**

<a id="skeleton_inlists"></a>
Additionally, we have prepared the **incomplete** inlists for the two-step evolution:
<!-- - [`inlist_XXXXX_ZAMS`](/tuesday/downloads/lab3/inlist_XXXXX_ZAMS), which you will modify to compute the ZAMS models;
- [`inlist_XXXXX_MS`](/tuesday/downloads/lab3/inlist_XXXXX_MS), which you will modify to compute the MS models. -->
{{<details title="`inlist_XXXXX_ZAMS`, for evolution up to ZAMS" closed="true">}}
```fortran
&star_job

    pgstar_flag = .false. ! Turn off the pgstar graphical interface.

    ! begin with a pre-main sequence model
    create_pre_main_sequence_model = .true.
    load_saved_model = .false.

    ! save a model at the end of the run
    save_model_when_terminate = .true.
    ! Filename of the saved ZAMS model. This will be used as the initial model for the next evolutionary run.
    save_model_filename = './LOGS_XXXXX/XXXXX_ZAMS.model'	 !!! To-do

    ! will be changed on the fly post C depletion
    new_net_name =  'cno_extras_o18_to_mg26_plus_fe56.net'	! 'mesa_45.net'
    show_net_species_info = .false.

    initial_zfracs = 8			! Set the initial metal mixture.

/ ! end of star_job namelist


&eos
/ ! end of eos namelist


&kap

    use_Type2_opacities = .true.	! Use Type 2 opacity tables, which allow changes in C/O abundances.
    Zbase = 0.02000d0			! Base metallicity used for the opacity tables.
    kap_file_prefix = 'OP_a09_nans_removed_by_hand' ! Opacity table prefix. Here this selects the OP A09 opacity table.

    ! Use cubic interpolation in hydrogen mass fraction X and in metallicity Z.
    cubic_interpolation_in_X = .true.
    cubic_interpolation_in_Z = .true.

/ ! end of kap namelist


&controls

    initial_mass = X.Xd0		! in Msun units !!! To-do
    initial_z = 0.02000d0

! Mixing
    ! min_D_mix = 1000.0000d0		! Minimum diffusion coefficient for mixing
    ! set_min_D_mix = .true.

    use_Ledoux_criterion = .true.	! Use the Ledoux criterion for convective stability.
    MLT_option = 'Cox'			! Use the Cox formulation of mixing-length theory.
    mixing_length_alpha = 1.8d0

    do_conv_premix = .true.		! Enable convective premixing.
    predictive_mix(1) = .false.		! Turn off predictive mixing for this boundary.
    predictive_zone_type(1) = 'any'	! Apply this predictive-mixing setting to any zone type.
    predictive_zone_loc(1) = 'core'	! Apply this predictive-mixing setting to the convective core.
    predictive_bdy_loc(1) = 'top'	! Apply this predictive-mixing setting to the top boundary of the convective core.

! Overshooting
    overshoot_zone_type(1) =                !!! To-do
    overshoot_zone_loc(1) =                 !!! To-do
    overshoot_bdy_loc(1) =                  !!! To-do

    ! options: 'exponential', 'step', 'other'
    overshoot_scheme(1) =                   !!! To-do

    overshoot_f(1) = X.X                    !!! To-do
    overshoot_f0(1) =                       !!! To-do
    overshoot_D_min = 1d-2

! add superadiabatic reduction for massive stars
    use_superad_reduction = .true.	! Enable superadiabatic gradient reduction. This can help numerical stability.
    superad_reduction_Gamma_limit = 0.5d0	! Gamma threshold for applying superadiabatic reduction.
    superad_reduction_Gamma_limit_scale = 5d0
    superad_reduction_Gamma_inv_scale = 5d0
    superad_reduction_diff_grads_limit = 1d-3

! Atmosphere

    atm_option = 'T_tau'		! Use a T-tau atmospheric boundary condition.
    atm_T_tau_relation = 'Eddington'	! Use the Eddington T-tau relation.
    atm_T_tau_opacity = 'varying'	! Use varying opacity in the T-tau atmosphere.

! Wind

    hot_wind_scheme = 'Dutch'
    cool_wind_RGB_scheme = 'Dutch'
    cool_wind_AGB_scheme = 'Dutch'
    Dutch_scaling_factor = 0.8d0

! Solver

    energy_eqn_option = 'dedt'		! Use the dE/dt form of the energy equation.
    use_gold_tolerances = .true.

! Resolution

    max_allowed_nz = 10000000		! Maximum allowed number of mesh cells.
    mesh_delta_coeff = 0.4		! Mesh resolution control. Smaller values give finer spatial resolution.
    time_delta_coeff = 0.5		! Timestep control. Smaller values give smaller timesteps.
    varcontrol_target = 1d-4		! Target accuracy for timestep control.
    min_allowed_varcontrol_target = 1d-5
    num_cells_for_smooth_gradL_composition_term = 10
    threshold_for_smooth_gradL_composition_term = 0.02
    num_cells_for_smooth_brunt_B = 10
    threshold_for_smooth_brunt_B = 0.1

! When to stop

    stop_near_zams = .true.

! Output
    log_directory = 'LOGS_XXXXX'            !!! To-do

/ ! end of controls namelist


&pgstar
/ ! end of pgstar namelist

```
{{</details>}}

{{<details title="`inlist_XXXXX_MS`, for evolution on the MS" closed="true">}}
```fortran
&star_job

    pgstar_flag = .false.


  ! begin with a pre-main sequence model
    create_pre_main_sequence_model = .false.
    load_saved_model = .true.
    load_model_filename =                                  !!! To-do


  ! save a model at the end of the run
    save_model_when_terminate = .true.
    save_model_filename = './LOGS_XXXXX/XXXXX_TAMS.model'  !!! To-do


   ! change_net = .true.
   ! change_initial_net = .true.

! will be changed on the fly post C depletion
    new_net_name =  'cno_extras_o18_to_mg26_plus_fe56.net' ! 'mesa_45.net'
    show_net_species_info = .false.

    initial_zfracs = 8

/ ! end of star_job namelist


&eos
/ ! end of eos namelist


&kap

    use_Type2_opacities = .true.
    Zbase = 0.02000d0
    kap_file_prefix = 'OP_a09_nans_removed_by_hand'

    cubic_interpolation_in_X = .true.
    cubic_interpolation_in_Z = .true.

/ ! end of kap namelist


&controls

! Mixing
    ! set_min_D_mix = .true.
    ! min_D_mix = 1000.0000d0

    use_Ledoux_criterion = .true.
    MLT_option = 'Cox'
    mixing_length_alpha = 1.8d0

    do_conv_premix = .true.
    predictive_mix(1) = .false.
    predictive_zone_type(1) = 'any'
    predictive_zone_loc(1) = 'core'
    predictive_bdy_loc(1) = 'top'

! Overshooting
    overshoot_zone_type(1) =        !!! To-do
    overshoot_zone_loc(1) =         !!! To-do
    overshoot_bdy_loc(1) =          !!! To-do
    
    ! options: 'exponential', 'step', 'other'
    overshoot_scheme(1) =           !!! To-do 

    overshoot_f(1) =                !!! To-do
    overshoot_f0(1) =               !!! To-do
    overshoot_D_min = 1d-2

! add superadiabatic reduction for massive stars
    use_superad_reduction = .false.
    superad_reduction_Gamma_limit = 0.5d0
    superad_reduction_Gamma_limit_scale = 5d0
    superad_reduction_Gamma_inv_scale = 5d0
    superad_reduction_diff_grads_limit = 1d-3



! Atmosphere

    atm_option = 'T_tau'
    atm_T_tau_relation = 'Krishna_Swamy'
    atm_T_tau_opacity = 'varying'

! Wind

    hot_wind_scheme = 'Dutch'
    cool_wind_RGB_scheme = 'Dutch'
    cool_wind_AGB_scheme = 'Dutch'
    Dutch_scaling_factor = 0.8d0

! Solver

    energy_eqn_option = 'dedt'
    use_gold_tolerances = .true.

! Resolution

    max_allowed_nz = 10000000
    mesh_delta_coeff = 0.4
    time_delta_coeff = 0.5

    varcontrol_target = 1d-4
    min_allowed_varcontrol_target = 1d-5

    num_cells_for_smooth_gradL_composition_term = 10
    threshold_for_smooth_gradL_composition_term = 0.02

    num_cells_for_smooth_brunt_B = 10
    threshold_for_smooth_brunt_B = 0.1


! Output

    photo_interval = 50000
    log_directory = 'LOGS_XXXXX'                !!! To-do
    terminal_interval = 100
    do_history_file = .true.
    history_interval = 1
    star_history_name = 'XXXXX_MS.history'      !!! To-do

    write_profiles_flag = .true.
    max_num_profile_models = 99999
    profile_interval = 1
    profile_data_prefix = 'profile'
    profile_data_suffix = '.data'

    write_pulse_data_with_profile = .true.
    pulse_data_format = 'GYRE'
    add_atmosphere_to_pulse_data = .true.
    add_center_point_to_pulse_data = .true.
    keep_surface_point_for_pulse_data = .true.
    interpolate_rho_for_pulse_data = .true.

! When to stop

    xa_central_lower_limit_species(1) = 'h1'
    xa_central_lower_limit(1) = 0.1

    ! stop at C depletion
    x_logical_ctrl(1) = .true.
    ! stop at onset of core-collapse and switch to large network on the fly?
    ! not that this will overwrite the x_logical_ctrl(1)
    x_logical_ctrl(2) = .false.

    default_net_name = 'cno_extras_o18_to_mg26_plus_fe56.net'

/ ! end of controls namelist


&pgstar

/ ! end of pgstar namelist

```
{{</details>}}

You will create different inlists for the models with step overshoot, exponential overshoot, and penetrative convection by replacing the `XXXXX` by `step_ov`, `exp_ov`, and `PC`, respectively. In the next sections, we will modify the `!Overshoot` section of the `&control` namelist to tell MESA to run the model with different convective boundary mixing schemes.

>[!Tip]
> The lines to be modified in the inlists to be modified are marked with `!!! To-do`.
---

## Background: Standard Overshooting Prescriptions

In MESA, step and exponential overshooting are built-in prescriptions that can be controlled from the inlist. For both prescriptions, we apply overshooting at the top boundary of the convective core. In the inlists for overshooting models, fill the following lines below the comment `!Overshoot`:

```fortran
    overshoot_zone_type(1) = 'any'
    overshoot_zone_loc(1)  = 'core'
    overshoot_bdy_loc(1)   = 'top'
```

These lines tell MESA where the overshooting is applied:

- `any`: allow this prescription to be applied to any relevant convective boundary;
- `core`: apply it to a convective core;
- `top`: apply it at the outer edge of the convective core.

---

## Step Overshooting

Step overshooting assumes that the material is fully mixed out to a fixed distance beyond the formal convective boundary. Use the same location controls, but change the scheme:

```fortran
    overshoot_scheme(1) = 'step'

    overshoot_f(1) = X.Xd0
    overshoot_f0(1) = 0.005d0
    overshoot_D_min = 1d-2
```

The difference between `overshoot_f` and `overshoot_f0` is shown schematically below. `overshoot_D_min` sets the lower cutoff for the overshoot mixing diffusion coefficient.

<img src="https://mesa-leuven.4d-star.org/tutorials/monday/overshoot_explanation.png" width="650">

*Credit: 2025 MESA School in Leuven Day 1 tutorial material (by Dr. Poojan Agrawal).*

The convective boundary is where the convective diffusion coefficient drops to zero. MESA steps slightly inward from this boundary by a distance `overshoot_f0 * H_p`. The main overshooting length scale is controlled by `overshoot_f * H_p`, where `H_p` is the local pressure scale height.

---

## Exponential Overshooting

Exponential overshooting assumes that the mixing coefficient decreases smoothly outside the convective boundary.

A typical setup is

```fortran
    overshoot_scheme(1) = 'exponential' 

    overshoot_f(1) = X.XXd0
    overshoot_f0(1) = 0.005d0
    overshoot_D_min = 1d-2
```

In the model grid, we will vary `overshoot_f(1)`.

---

## Convective Penetration

This section is a guided code-reading exercise. The goal is to understand how the custom scheme is connected to MESA.

Convective penetration is different from standard MESA overshooting, where material beyond the convective boundary is chemically mixed, but the thermal structure is usually still treated as radiative. In convective penetration, convective motions penetrate into the formally stable region and can modify both the chemical composition and the thermal stratification. In the implementation used here, the penetration extent is computed inside `run_star_extras.f90`. 

In the inlists for the convective penetration runs, use

```fortran
    overshoot_scheme(1) = 'other'

    overshoot_f(1) = 0.00
    overshoot_f0(1) = 0.005d0
    overshoot_D_min = 1d-2
```

The key line is

```fortran
overshoot_scheme(1) = 'other'
```

This tells MESA to call the user-supplied overshooting routine from `run_star_extras.f90`. The coding part of this implementation is relatively complicated, so we have provided the code. Go ahead to copy and paste the content in your `run_star_extras.f90`.
<!-- [here](/tuesday/downloads/lab3/run_star_extras_solution.f90).  -->

{{<details title="Complete `run_star_extras.f90`" closed="true">}}
```fortran
! ***********************************************************************
!
!   Copyright (C) 2010-2019  Bill Paxton & The MESA Team
!
!   this file is part of mesa.
!
!   mesa is free software; you can redistribute it and/or modify
!   it under the terms of the gnu general library public license as published
!   by the free software foundation; either version 2 of the license, or
!   (at your option) any later version.
!
!   mesa is distributed in the hope that it will be useful,
!   but without any warranty; without even the implied warranty of
!   merchantability or fitness for a particular purpose.  see the
!   gnu library general public license for more details.
!
!   you should have received a copy of the gnu library general public license
!   along with this software; if not, write to the free software
!   foundation, inc., 59 temple place, suite 330, boston, ma 02111-1307 usa
!
! ***********************************************************************

      module run_star_extras

      use star_lib
      use star_def
      use const_def
      use math_lib
      use chem_def

      implicit none

      real (dp) :: m_core, mass_PZ, delta_r_PZ, alpha_PZ, r_core, rho_core_top
      ! real (dp) :: X_ini
      integer :: k_PZ_top, k_PZ_bottom
      logical :: doing_DBP = .false.

      !extra meshing controls
       real(dp) :: xtra_dist_below, xtra_dist_above_ov, xtra_dist_above_bv, xtra_coeff_mesh

       namelist /xtra_coeff_cb/ &
          xtra_dist_below, &
          xtra_dist_above_ov, &
          xtra_dist_above_bv, &
          xtra_coeff_mesh


      ! these routines are called by the standard run_star check_model
      contains

      ! include 'standard_run_star_extras.inc'

      subroutine extras_controls(id, ierr)
          integer, intent(in) :: id
          integer, intent(out) :: ierr
          type (star_info), pointer :: s

          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return

          s% extras_startup => extras_startup
          s% extras_start_step => extras_start_step
          s% extras_check_model => extras_check_model
          s% extras_finish_step => extras_finish_step
          s% extras_after_evolve => extras_after_evolve
          s% how_many_extra_history_columns => how_many_extra_history_columns
          s% data_for_extra_history_columns => data_for_extra_history_columns
          s% how_many_extra_profile_columns => how_many_extra_profile_columns
          s% data_for_extra_profile_columns => data_for_extra_profile_columns

          s% how_many_extra_history_header_items => how_many_extra_history_header_items
          s% data_for_extra_history_header_items => data_for_extra_history_header_items
          s% how_many_extra_profile_header_items => how_many_extra_profile_header_items
          s% data_for_extra_profile_header_items => data_for_extra_profile_header_items

          ! s% other_adjust_mlt_gradT_fraction => other_adjust_mlt_gradT_fraction_Peclet
          s% other_overshooting_scheme => extended_convective_penetration

          ! Add extra meshing
          s% use_other_mesh_delta_coeff_factor = .true.
          call read_inlist_xtra_coeff_core_boundary(ierr) ! Read inlist
          if (ierr /= 0) return
          s% other_mesh_delta_coeff_factor => mesh_delta_coeff_core_boundary

          ! if (.not. s%job% create_pre_main_sequence_model) then
            ! load_model_filename = 'ZAMS.mod'
            ! load_saved_model = .true.
          ! endif
          ! s% kap_rq% Zbase = Z_ini ! set Z for opacity tables


      end subroutine extras_controls


      subroutine extras_startup(id, restart, ierr)
          integer, intent(in) :: id
          logical, intent(in) :: restart
          integer, intent(out) :: ierr
          type (star_info), pointer :: s
          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return

          ! if (s%job% create_pre_main_sequence_model) then
          !     X_ini=s% center_h1
          !     s%job% save_model_when_terminate = .true.
          !     s% scale_max_correction = 0.1       ! to help pre-MS convergence
          !     s% job% save_model_filename = 'ZAMS.mod'
          ! endif

      end subroutine extras_startup


      integer function extras_start_step(id)
          integer, intent(in) :: id
          integer :: ierr
          type (star_info), pointer :: s
          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return
          doing_DBP = .false.
          extras_start_step = 0
      end function extras_start_step


      ! returns either keep_going, retry, backup, or terminate.
      integer function extras_check_model(id)
          integer, intent(in) :: id
          integer :: ierr
          type (star_info), pointer :: s
          logical :: do_retry
          integer k
          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return
          extras_check_model = keep_going

          ! Flag PZ as anonymous_mixing
          if (doing_DBP) then
            do k=k_PZ_bottom, k_PZ_top, -1
                s%mixing_type(k) = anonymous_mixing
            end do
          endif

          do_retry = .false.
          ! ! Save model when no longer on pre-main sequence and a convective core has appeared.
          ! ! The central hydrogen fraction needs to have decreased by a small amount,
          ! ! to make sure that core H-burning has started, and the star is near the ZAMS.
          ! if (s%job% create_pre_main_sequence_model) then
          !     if ((s%mixing_type(s%nz) .eq. convective_mixing) .and. (X_ini-s% center_h1 > 1d-6)) then
          !         extras_check_model = terminate
          !     endif
          ! endif

          ! by default, indicate where (in the code) MESA terminated
          if (extras_check_model == terminate) s% termination_code = t_extras_check_model
      end function extras_check_model


      integer function how_many_extra_history_columns(id)
          integer, intent(in) :: id
          integer :: ierr
          type (star_info), pointer :: s
          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return
          how_many_extra_history_columns = 7
      end function how_many_extra_history_columns


      subroutine data_for_extra_history_columns(id, n, names, vals, ierr)
          integer, intent(in) :: id, n
          character (len=maxlen_history_column_name) :: names(n)
          real(dp) :: vals(n)
          real(dp) :: r_cb
          integer :: k
          integer, intent(out) :: ierr
          type (star_info), pointer :: s
          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return

          call star_eval_conv_bdy_r(s, 1, r_cb, ierr)

          if (.not. doing_DBP) then
              mass_PZ=0
              delta_r_PZ=0
              alpha_PZ=0

              if (s% mixing_type(s% nz) /= convective_mixing) then
                  r_core = 0
                  m_core = 0
                  rho_core_top = 0
              else
                  call star_eval_conv_bdy_k(s, 1, k, ierr)
                  r_core = r_cb
                  m_core = s%m(k)
                  rho_core_top = s%rho(k)
              endif
          endif

          names(1) = 'm_core'
          names(2) = 'mass_pen_zone'
          names(3) = 'delta_r_pen_zone'
          names(4) = 'alpha_pen_zone'
          names(5) = 'r_core'
          names(6) = 'rho_core_top_pen'
          names(7) = 'r_cb'

          vals(1) = m_core/Msun
          vals(2) = mass_PZ/Msun
          vals(3) = delta_r_PZ/Rsun
          vals(4) = alpha_PZ
          vals(5) = r_core/Rsun
          vals(6) = rho_core_top
          vals(7) = r_cb/Rsun

      end subroutine data_for_extra_history_columns


      integer function how_many_extra_profile_columns(id)
          integer, intent(in) :: id
          integer :: ierr
          type (star_info), pointer :: s
          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return
          how_many_extra_profile_columns = 0
      end function how_many_extra_profile_columns


      subroutine data_for_extra_profile_columns(id, n, nz, names, vals, ierr)
          integer, intent(in) :: id, n, nz
          character (len=maxlen_profile_column_name) :: names(n)
          real(dp) :: vals(nz,n)
          integer, intent(out) :: ierr
          ! integer :: vals_nr
          type (star_info), pointer :: s
          integer :: k
          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return

      end subroutine data_for_extra_profile_columns


      integer function how_many_extra_history_header_items(id)
          integer, intent(in) :: id
          integer :: ierr
          type (star_info), pointer :: s
          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return
          how_many_extra_history_header_items = 0
      end function how_many_extra_history_header_items


      subroutine data_for_extra_history_header_items(id, n, names, vals, ierr)
          integer, intent(in) :: id, n
          character (len=maxlen_history_column_name) :: names(n)
          real(dp) :: vals(n)
          type(star_info), pointer :: s
          integer, intent(out) :: ierr
          ierr = 0
          call star_ptr(id,s,ierr)
          if(ierr/=0) return

          ! here is an example for adding an extra history header item
          ! also set how_many_extra_history_header_items
          ! names(1) = 'mixing_length_alpha'
          ! vals(1) = s% mixing_length_alpha
      end subroutine data_for_extra_history_header_items


      integer function how_many_extra_profile_header_items(id)
          integer, intent(in) :: id
          integer :: ierr
          type (star_info), pointer :: s
          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return
          how_many_extra_profile_header_items = 0
      end function how_many_extra_profile_header_items


      subroutine data_for_extra_profile_header_items(id, n, names, vals, ierr)
          integer, intent(in) :: id, n
          character (len=maxlen_profile_column_name) :: names(n)
          real(dp) :: vals(n)
          type(star_info), pointer :: s
          integer, intent(out) :: ierr
          ierr = 0
          call star_ptr(id,s,ierr)
          if(ierr/=0) return

          ! here is an example for adding an extra profile header item
          ! also set how_many_extra_profile_header_items
          ! names(1) = 'mixing_length_alpha'
          ! vals(1) = s% mixing_length_alpha

      end subroutine data_for_extra_profile_header_items


      ! returns either keep_going or terminate.
      ! note: cannot request retry or backup; extras_check_model can do that.
      integer function extras_finish_step(id)
          integer, intent(in) :: id
          integer :: ierr
          type (star_info), pointer :: s
          character (len=200) :: fname
          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return
          extras_finish_step = keep_going

          ! stop at carbon depletion
          if (s% x_logical_ctrl(1) .eqv. .true.) then
             if ((s%xa(s%net_iso(io16), s%nz) >= 0.5 ) .and. (s%xa(s%net_iso(ic12), s%nz) <= 1e-5)) then
                write(*,*) "Carbon depletion"
                extras_finish_step = terminate
                write(fname, fmt="(a10)") 'C_depl.mod'
                call star_write_model(s% id, fname, ierr)
             end if
          end if
          ! stop at onset of core-collapse
          if (s% x_logical_ctrl(2) .eqv. .true.) then
             ! don't stop at O depletion
             s% x_logical_ctrl(1) = .false.
             ! change net on the fly post C depletion
             if ((s%xa(s%net_iso(io16), s%nz) >= 0.5 ) .and. (s%xa(s%net_iso(ic12), s%nz) <= 1e-5)) then
                write(fname, fmt="(a10)") 'C_depl.mod'
                call star_write_model(s% id, fname, ierr)
                s% job% change_net = .true.
                s% job% change_initial_net = .true.
                s% job% new_net_name = "mesa_128.net"
                write(*,*) "Change net to ", s% job%new_net_name
                ! flip switch so we don't enter here again
                s% x_logical_ctrl(2) = .false.
             end if
          end if


          if (extras_finish_step == terminate) s% termination_code = t_extras_finish_step

      end function extras_finish_step


      subroutine extras_after_evolve(id, ierr)
          integer, intent(in) :: id
          integer, intent(out) :: ierr
          type (star_info), pointer :: s
          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return
      end subroutine extras_after_evolve

!!! CUSTOM

      subroutine other_adjust_mlt_gradT_fraction_Peclet(id, ierr)
          integer, intent(in) :: id
          integer, intent(out) :: ierr
          type(star_info), pointer :: s
          real(dp) :: fraction, Peclet_number, diffusivity    ! f is fraction to compose grad_T = f*grad_ad + (1-f)*grad_rad
          integer :: k
          logical, parameter :: DEBUG = .FALSE.

          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return

          if (s%D_mix(1) .ne. s%D_mix(1)) return  ! To ignore iterations where Dmix and gradT are NaNs

          if (s%num_conv_boundaries .lt. 1) then  ! Is zero at initialisation of the run
          if (DEBUG) then
              write(*,*) 'runstarex_gradT: skip since there are no convective boundaries'
          end if
          return
          endif

          do k= s%nz, 1, -1
              if (s%D_mix(k) <= s% min_D_mix) exit

              diffusivity = 16.0_dp * boltz_sigma * pow3(s% T(k)) / ( 3.0_dp * s% opacity(k) * pow2(s% rho(k)) * s% cp(k) )
              Peclet_number = s% conv_vel(k) * s% scale_height(k) * s% mixing_length_alpha / diffusivity

              if (Peclet_number >= 100.0_dp) then
                  fraction = 1.0_dp
              else if (Peclet_number .le. 0.01_dp) then
                  fraction = 0.0_dp
              else
                  fraction = (safe_log10(Peclet_number)+2.0_dp)/4.0_dp
              end if

              s% adjust_mlt_gradT_fraction(k) = fraction
          end do

      end subroutine other_adjust_mlt_gradT_fraction_Peclet


      subroutine extended_convective_penetration(id, i, j, k_a, k_b, D, vc, ierr)
          integer, intent(in) :: id, i, j
          integer, intent(out) :: k_a, k_b
          real(dp), intent(out), dimension(:) :: D, vc
          integer, intent(out) :: ierr
          type (star_info), pointer :: s

          logical, parameter :: DEBUG = .FALSE.
          real(dp) :: f, f2, f0
          real(dp) :: D0, Delta0
          real(dp) :: w
          real(dp) :: factor
          real(dp) :: r_cb, Hp_cb
          real(dp) :: r_ob, D_ob, vc_ob
          logical  :: outward
          integer  :: dk, k, k_ob
          real(dp) :: r, dr, r_step

          ! Evaluate the overshoot diffusion coefficient D(k_a:k_b) and
          ! mixing velocity vc(k_a:k_b) at the i'th convective boundary,
          ! using the j'th set of overshoot parameters. The overshoot
          ! follows the extended convective penetration scheme description by Mathias
          ! Michielsen, "Probing the shape of the mixing profile and of the thermal
          ! structure at the convective core boundary through asteroseismology",
          ! A&A, 628, 76 (2019)

          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return

          if ((i .ne. 1) .or. (s%mixing_type(s%nz) .ne. convective_mixing)) then
              write(*,'(A,i2,A,i2)') 'ERROR: dissipation_balanced_penetration can only be used for core convection, &
                    &so the first convective boundary. The routine got called for convective boundary number ',i, &
                    &', and the mixing type in the core was', s%mixing_type(s%nz)
              ierr = -1
              return
          end if

          call dissipation_balanced_penetration(s, id) !, m_core, mass_PZ, delta_r_PZ, alpha_PZ, r_core, rho_core_top)
          ! alpha_PZ is distance from core boundary outward, so add f0 to it to make PZ zone reach that region
          alpha_PZ = alpha_PZ + s%overshoot_f0(j)
          ! Extract parameters
          f = alpha_PZ                     ! extend of step function (a_ov)
          f0 = s%overshoot_f0(j)
          f2 = s%overshoot_f(j)            ! exponential decay (f_ov)

          D0 = s%overshoot_D0(j)
          Delta0 = s%overshoot_Delta0(j)

          if (f < 0.0_dp .OR. f0 <= 0.0_dp .OR. f2 < 0.0_dp) then
              write(*,*) 'ERROR: for extended convective penetration, must set f0 > 0, and f and f2 >= 0'
              write(*,*) 'see description of overshooting in star/defaults/control.defaults'
              ierr = -1
              return
          end if

          ! Evaluate convective boundary (_cb) parameters
          call star_eval_conv_bdy_r(s, i, r_cb, ierr)
          if (ierr /= 0) return

          call star_eval_conv_bdy_Hp(s, i, Hp_cb, ierr)
          if (ierr /= 0) return

          ! Evaluate overshoot boundary (_ob) parameters
          call star_eval_over_bdy_params(s, i, f0, k_ob, r_ob, D_ob, vc_ob, ierr)
          if (ierr /= 0) return

          ! Loop over cell faces, adding overshoot until D <= overshoot_D_min
          outward = s%top_conv_bdy(i)

          if (outward) then
              k_a = k_ob
              k_b = 1
              dk = -1
          else
              k_a = k_ob+1
              k_b = s%nz
              dk = 1
          endif

          if (f > 0.0_dp) then
              r_step = f*Hp_cb
          else
              r_step = 0.0_dp
          endif

          face_loop : do k = k_a, k_b, dk
              ! Evaluate the extended convective penetration factor
              r = s%r(k)
              if (outward) then
                  dr = r - r_ob
              else
                  dr = r_ob - r
              endif

              if (dr < r_step .AND. f > 0.0_dp) then  ! step factor
                  factor = 1.0_dp
              else
                  if ( f2 > 0.0_dp) then                ! exponential factor
                      factor = exp(-2.0_dp*(dr-r_step)/(f2*Hp_cb))
                  else
                      factor = 0.0_dp
                  endif
              endif

              ! Store the diffusion coefficient and velocity
              D(k) = (D0 + Delta0*D_ob)*factor
              vc(k) = (D0/D_ob + Delta0)*vc_ob*factor

              ! Check for early overshoot completion
              if (D(k) < s%overshoot_D_min) then
                  k_b = k
                  exit face_loop
              endif

          end do face_loop

          if (DEBUG) then
              write(*,*) 'step exponential overshoot:'
              write(*,*) '  k_a, k_b   =', k_a, k_b
              write(*,*) '  r_a, r_b   =', s%r(k_a), s%r(k_b)
              write(*,*) '  r_ob, r_cb =', r_ob, r_cb
              write(*,*) '  Hp_cb      =', Hp_cb
          end if

      end subroutine extended_convective_penetration



      subroutine dissipation_balanced_penetration(s, id)
         use eos_def
         use star_lib
         use kap_def
         type (star_info), pointer :: s
         integer, intent(in) :: id
         real(dp), parameter :: f = X.Xd0
         real(dp), parameter :: xi = 0.6d0
         integer :: k, j, ierr
         real(dp) :: Lint, V_CZ, Favg, RHS, dr, h, dLint
         real(dp) :: r_cb

         doing_DBP = .true.
         V_CZ = 0d0
         Lint = 0d0

         call star_eval_conv_bdy_k(s, 1, k, ierr)
         call star_eval_conv_bdy_r(s, 1, r_cb, ierr)
         k_PZ_bottom = k
         r_core = r_cb
         m_core = s%m(k)
         rho_core_top = s%rho(k)
         h = s%scale_height(k)

         ! prescription based on Jermyn A. et al (2022)  https://arxiv.org/pdf/2203.09525.pdf
         ! Equation A1 is used here.
         ! RHS refers to right-hand side of equation A1, and Lint the integrated
         ! luminosity on either left or right side of that equation

         ! Integrate over cells that are fully in CZ
         ! r and L_conv are face values, assume they change linear within cell
         do j=s%nz,k+1,-1
            if (j .eq. s%nz) then
                dr = s%r(j)
                Lint = Lint + s%L_conv(j)*0.5 * dr
            else
                dr = s%r(j) - s%r(j+1)
                Lint = Lint + (s%L_conv(j+1) + s%L_conv(j))*0.5 * dr
            endif
         end do

        ! Take cell that is partially convective
        ! convective part of cell k
        ! L_conv goes to 0 at edge of conv zone
         dr = r_cb - s%r(k+1)
         Lint = Lint + s%L_conv(k+1)*0.5 * dr

         ! Calculate target RHS
         V_CZ = 4d0/3d0 * pi * r_cb*r_cb*r_cb
         Favg = Lint / V_CZ
         RHS = (1d0 - f) * Lint
         Lint = 0d0

         ! Integrate over RZ until we find the edge of the PZ
         ! remainder of cell k (non-convective part)
         ! Do integration explicitely, f*xi*4*pi*r^2 is moved outside of integral
         dr = s%r(k) - r_cb
         dLint = xi * f * 4d0 * pi * (pow3(s%r(k))-pow3(r_cb))/3 * Favg + (s%L(k)*0.5 * (s%grada_face(k) / s%gradr(k) - 1d0)) * dr
         Lint = dLint

         ! If remainder of cell k would already satisfy Lint > RHS
         if (Lint > RHS) then
            dr = dr*(Lint - RHS)/dLint
            mass_PZ =  s%rho(k) * 4d0/3d0 * pi * (pow3(r_cb+dr) - pow3(r_cb)) !s%m(k) - m_core !only used for history output
            delta_r_PZ = dr
            alpha_PZ = delta_r_PZ / h
            k_PZ_top = k
            return
         end if
         ! Else calculate dL_int for each cell, untill the total integrated L > RHS
         do j=k-1,1,-1
            dr = s%r(j) - s%r(j+1)
            dLint = xi * f * 4d0 * pi * (pow3(s%r(j))-pow3(s%r(j+1)))/3 * Favg &
            + ( (s%L(j+1)*(s%grada_face(j+1) / s%gradr(j+1) - 1d0) +(s%L(j)*(s%grada_face(j) / s%gradr(j) - 1d0)) )*0.5 * dr)

            if (Lint + dLint > RHS) then
               dr = dr*(RHS - Lint)/dLint
               mass_PZ = s%m(j) - m_core !only used for history output
               delta_r_PZ = s%r(j+1)+dr - r_cb
               alpha_PZ = delta_r_PZ / h
               k_PZ_top = j
               return
            end if
            Lint = Lint + dLint
         end do

      end subroutine dissipation_balanced_penetration

      ! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      ! Other mesh routine
      subroutine mesh_delta_coeff_core_boundary(id, ierr)
          integer, intent(in) :: id
          ! real(dp), intent(in), dimension(:) :: eps_h, eps_he, eps_z
          integer, intent(out) :: ierr
          type (star_info), pointer :: s
          logical, parameter :: dbg = .false.
          integer :: k, k_max_N2comp
          real(dp) :: Hp, r_lower, r_upper_ov, r_upper_BV

          ierr = 0
          call star_ptr(id, s, ierr)
          if (ierr /= 0) return

          if (xtra_coeff_mesh == 1d0 .or. xtra_coeff_mesh < 0) return
          if (s% mixing_type(s% nz) /= convective_mixing) return  ! only enable for convective cores

          r_upper_ov=-1
          r_upper_BV=-1
          k_max_N2comp = MAXLOC(s% brunt_n2_composition_term(:), 1)
          ! Find boundary of convective core, and go inwards by the specified distance (in Hp)
          do k = s% nz, 1, -1
              if (s% mixing_type(k) == convective_mixing) then
                  continue
              else
                  Hp = s% scale_height(k)  !s% P(k)/(s% rho(k)*s% grav(k))
                  r_lower = max (s% r(s%nz), s% r(k) - xtra_dist_below*Hp)
                  exit
              endif
          end do

          do k = s% nz, 1, -1
              ! Start increasing the mesh once closer than the given distance (in Hp) to the core boundary
              if (s%r(k) > r_lower) then
                  if (xtra_coeff_mesh < s% mesh_delta_coeff_factor(k)) then
                      s% mesh_delta_coeff_factor(k) = xtra_coeff_mesh
                  end if
              else
                  cycle
              endif

              ! Go up to the given distance past the overshoot boundary
              if (r_upper_ov<0 .and. s% mixing_type(k) /= overshoot_mixing .and. s% mixing_type(k) /= convective_mixing) then
                  if (xtra_dist_above_ov > 0) then
                      Hp = s% scale_height(k) !s% P(k)/(s% rho(k)*s% grav(k))
                      r_upper_ov = min(s% r(1), s% r(k) + xtra_dist_above_ov*Hp)
                  else
                      r_upper_ov = 0
                  end if
              end if

              ! Go up to the given distance past the order in magnitude decrease in BV composition term, outwards of its maximum
              if (r_upper_BV<0 .and. k < k_max_N2comp .and. (s% brunt_n2_composition_term(k)*10 < maxval(s% brunt_n2_composition_term(:))) ) then
                  if (xtra_dist_above_bv > 0) then
                      Hp = s% scale_height(k) !s% P(k)/(s% rho(k)*s% grav(k))
                      r_upper_BV = min(s% r(1), s% r(k) + xtra_dist_above_bv*Hp)
                  else
                      r_upper_BV = 0
                  end if
              end if

              ! Stop increasing mesh when further than the specified distance from both the overshoot boundary and BV composition peak
              if (s% r(k) > r_upper_ov .and. s% r(k) > r_upper_BV .and. r_upper_ov >=0 .and. r_upper_BV >=0) exit
          end do

      end subroutine mesh_delta_coeff_core_boundary
      ! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      subroutine read_inlist_xtra_coeff_core_boundary(ierr)
          use utils_lib
          integer, intent(out) :: ierr
          character (len=256) :: filename, message
          integer :: unit

          filename = 'inlist_xtra_coeff_mesh'
          write(*,*) 'read inlist_xtra_coeff_mesh'

          ! set defaults
          xtra_dist_below = 0.1d0
          xtra_dist_above_ov = 0.1d0
          xtra_dist_above_bv = 0.1d0
          xtra_coeff_mesh = 0.15d0

          open(newunit=unit, file=trim(filename), action='read', delim='quote', iostat=ierr)
          if (ierr /= 0) then
              write(*, *) 'Failed to open control namelist file ', trim(filename)
          else
              read(unit, nml=xtra_coeff_cb, iostat=ierr)
              close(unit)
              if (ierr /= 0) then
                  write(*, *) 'Failed while trying to read control namelist file ', trim(filename)
                  write(*, '(a)') &
                  'The following runtime error message might help you find the problem'
                  write(*, *)
                  open(newunit=unit, file=trim(filename), action='read', delim='quote', status='old', iostat=ierr)
                  read(unit, nml=xtra_coeff_cb)
                  close(unit)
              end if
          end if

      end subroutine read_inlist_xtra_coeff_core_boundary

    end module run_star_extras

```
{{</details>}}

Before running the models, find the line in `run_star_extras.f90`

```fortran
real(dp), parameter :: f = X.Xd0
```

and replace `X.Xd0` with the value specified for your run (0.98, 0.86 or 0.72).

---

**In the next few sections, the task is to identify which parts of `run_star_extras.f90` are needed for the custom penetration scheme, understand what each part does, and then use the supplied solution file as the working implementation.**

### Guided Check 1: Define Extra Variables

Near the top of the module, after

```fortran
implicit none
```

the modified file defines extra variables that store information about the convective core and the penetration zone. For example, the implementation tracks quantities such as

```fortran
m_core ! the convective core mass
mass_PZ ! the mass of the penetration zone
delta_r_PZ ! the radial width of the penetration zone
alpha_PZ ! the dimensionless penetration extent
r_core ! the radius of the convective core boundary
rho_core_top ! the density at the top of the core
```


### Guided Check 2: Connect MESA to the Custom Overshooting Routine

Inside `extras_controls`, MESA must be told which custom routine to call when the inlist says

```fortran
    overshoot_scheme(1) = 'other'
```

The important line has the form

```fortran
s% other_overshooting_scheme => extended_convective_penetration
```

This is the hook that connects the inlist setting to the custom convective penetration routine. Therefore, the same `run_star_extras.f90` file can be used for the whole lab: the custom routine is only used when `overshoot_scheme(1) = 'other'`, while the step and exponential runs use MESA's built-in schemes.


### Guided Check 3: Add Extra History Columns

This is done by modifying two routines:

```fortran
how_many_extra_history_columns
data_for_extra_history_columns
```

The modified implementation writes seven extra history columns:

```fortran
m_core ! convective core mass
mass_pen_zone ! mass contained in the penetration zone
delta_r_pen_zone ! radial width of the penetration zone
alpha_pen_zone ! penetration-zone width in units of the local pressure scale height
r_core ! radius of the convective core boundary
rho_core_top_pen ! density near the top of the convective penetration zone
r_cb ! radius of the convective boundary
```


### Guided Check 4: Add the Custom Overshooting Routine

The main custom overshooting routine is called

```fortran
extended_convective_penetration
```

This routine does:

1. checks that the boundary is the top of a convective core;
2. calls another routine to compute the penetration-zone width;
3. uses the computed `alpha_PZ` as the width of a step like penetration region;
4. optionally attaches an exponential tail controlled by `overshoot_f(1)`;
5. returns the diffusion coefficient profile `D`.

A key line in this routine is

```fortran
call dissipation_balanced_penetration(s, id)
```

This computes the penetration zone extent.

Another important line is

```fortran
alpha_PZ = alpha_PZ + s%overshoot_f0(j)
```

This means that the final step like penetration region includes the computed penetration width plus the small offset set by `overshoot_f0`.

This is why we use

```fortran
overshoot_f(1) = 0.00
overshoot_f0(1) = 0.005
```


### Guided Check 5: Compute the Penetration Width

The penetration width is computed in the routine

```fortran
dissipation_balanced_penetration
```

This routine estimates how far the convective penetration zone should extend beyond the convective boundary. For this lab, let's focus on identifying how the code computes

```fortran
delta_r_PZ ! physical radial width of the penetration zone
alpha_PZ ! delta_r_PZ divided by the local pressure scale height
```

The key relation is

```fortran
alpha_PZ = delta_r_PZ / h
```

where `h` is the local pressure scale height near the convective core boundary.

### Guided Check 6: Optional: Extra Mesh Refinement

The modified implementation also includes an optional mesh refinement routine near the core boundary. This is useful because the Brunt–Väisälä frequency and the composition gradient can vary rapidly near the convective boundary. The relevant hook has the form

```fortran
s% use_other_mesh_delta_coeff_factor = .true.
s% other_mesh_delta_coeff_factor => mesh_delta_coeff_core_boundary
```

---

## Task 0. Model Grid

Each student should run only the assigned subset of models and record the result in the shared spreadsheet. A good default is to choose one initial mass, one mixing prescription, and one parameter value. If time allows, students with faster computers can help fill missing entries.

The suggested parameter space to explore is listed in the shared spreadsheet: [Lab 3 grid tracker](https://docs.google.com/spreadsheets/d/1v9Dq4AV1ZGssSdy1lQE3uiXW0afyK1mRk9uvBgGOaGI/edit?usp=sharing).

For each model, evolve from ZAMS to an evolved main-sequence model with centra hydrogen mass fraction of 0.1.

## Solution Files and Naming Conventions

<!-- >[!Important]
> At this point, in your working directory, you should have created in total six different based on the [two incomplete inlists]((#skeleton_inlists)) that we provided at the beginning. -->

If you want to check what you did, the solution files are available here: [inlists and run_star_extras solutions](https://github.com/astroscien/2026MESA-school-day2-lab3/tree/main).

Files contain placeholders such as `X.X`. Please replace these placeholders with your desired mixing parameters and initial stellar mass before running the models.

For the penetration-convection runs, remember that the main penetration strength parameter is coded in `run_star_extras.f90`. You should change

```fortran
real(dp), parameter :: f = X.Xd0
```
near line 536 to the desired value, then recompile with:

```bash
./clean
./mk
```
In the solution files, we use separate local output directories for the three mixing prescriptions:

```text
LOGS_step_ov
LOGS_exp_ov
LOGS_PC
```

For example, in the exponential overshoot ZAMS run, the saved model may be written as 

```fortran
save_model_filename = './LOGS_exp_ov/exp_ov_zams.model'
```
When you run a different parameter value, you may want to change the output directory or saved model filename to avoid overwriting previous runs.

## Example One Run
For step overshooting, two inlists are needed:
- `inlist_step_ov_ZAMS_solution`
- `inlist_step_ov_MS_solution`

Use `inlist_step_ov_ZAMS_solution` for the first-stage run, from the pre-main sequence to ZAMS. This run uses:

```fortran
stop_near_zams = .true.
```

and saves the ZAMS model. Then use `inlist_step_ov_MS_solution` for the second-stage run, from the saved ZAMS model to the late main sequence. This run loads the saved ZAMS file and stops when the central hydrogen abundance reaches 0.1:

```fortran
xa_central_lower_limit_species(1) = 'h1'
xa_central_lower_limit(1) = 0.1
```
The same two stage workflow should be followed for the exponential overshoot and penetration convection cases.

---

## Task 1. What to Record

For this lab, you need to record the seismic fit quality for each model. The shared Google Sheet already provides the target g-mode frequencies for `n_pg = -20` to `-10`. For each MESA+GYRE model, use the final MESA model, namely the profile with central hydrogen abundance closest to `Xc(H) = 0.1`.

### Where to Find the GYRE Eigenmodes

GYRE reports the eigenmodes in two places:

1. in the terminal output while GYRE is running;
2. in the GYRE summary/output files, if summary output is enabled in the GYRE inlist.

For a quick check, the terminal output is often enough. During the root-solving step, GYRE prints a table like this:

```text
Root Solving
   l    m    n_pg    n_p    n_g       Re(omega)       Im(omega)        chi n_iter
   1    0     -20      0     20  0.63087941E+00  0.00000000E+00 0.3165E-12      7
   1    0     -19      0     19  0.66841184E+00  0.00000000E+00 0.3904E-12      8
   1    0     -18      0     18  0.69832663E+00  0.00000000E+00 0.1748E-12      6
   ...
   1    0     -10      0     10  0.12513287E+01  0.00000000E+00 0.1019E-12      7
```

For this lab, use the dipole modes with

```text
l = 1
m = 0
n_pg = -20 to -10
```

Equivalently, for these g modes, you can identify them by

```text
n_g = 20 to 10
```

because `n_pg` is negative for g modes.

### Important: Frequency Units

Be careful with units. By default, GYRE prints the dimensionless angular frequency `omega`.

The terminal column

```text
Re(omega)
```

is the real part of the mode frequency. In this lab, we are running adiabatic oscillation calculations. This means that we ignore heat exchange during one oscillation cycle, so the modes do not grow or decay. Therefore, the eigenfrequencies are real numbers. In a non-adiabatic calculation, the eigenfrequency is generally complex. The real part gives the oscillation frequency, while the imaginary part describes mode growth or damping. A growing mode is unstable and may become observable if it reaches a detectable amplitude, while a damped mode is stable and tends to decay unless it is continuously excited.

### Compute the Fit Quality

Once the model and target frequencies are in the same units, compute an unweighted `Chi2` value:

```Python
Chi2 = np.sum((freq_model - freq_target)**2)
```

Record this `Chi2` value in the table cell corresponding to the model's initial mass and mixing parameter. After all models are filled in, the cell with the smallest `Chi2` identifies the best-fit model within this grid.

---

## Task 2. Compare the Structures at Xc(H) = 0.5

In this task, we compare the internal structures of the three mixing prescriptions at the same evolutionary stage. For each prescription, we will use the model whose central hydrogen abundance is closest to 0.5. The three MESA runs are stored in separate output directories: 

```text
LOGS_step_ov
LOGS_exp_ov
LOGS_PC
```

We have prepared a [Google Colab](https://colab.research.google.com/drive/15R6yXp027FNXOFXXpGG38xCHVap0nPp1#scrollTo=wkZW-0xDuxI3) to visualize the differences in the abundance profiles and the propagation diagrams. **However, in this case you need to zip your log directories and upload them, which can take some time since the file is quite large.**

{{<details title="Zipping the folders" closed="true">}}
```shell
zip -r LOGS_XXXXX.zip LOGS_XXXXX
```

Replace the placeholder XXXXX by the prescription(s) that you have run. 

This will print a lot of lines since you have a lot of profiles in the folder, if you want to suppress the terminal output, do:

```shell
zip -qr LOGS_XXXXX.zip LOGS_XXXXX
```
{{</details>}}

<!-- **If you have the package required (`numpy`, `pandas` and `matplotlib`) by the script, we strongly recommand you use the [python script](/tuesday/downloads/lab3/diff_mixing_profiles_in_mass.py) directly.**  -->
**If you have the package required (`numpy`, `pandas` and `matplotlib`) by the script, we strongly recommand you use the python script directly.** In this case, create a new file `diff_mixing_profiles_in_mass.py` in your working directory, copy the script there, save and do:
```shell
python3 diff_mixing_profiles_in_mass.py
```

{{<details title="Plotting script" closed="true">}}
```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from io import StringIO

plt.rcParams.update({
    "text.usetex": True,
    "font.family": "serif",
    "axes.labelsize": 16,
    "font.size": 16,
    "xtick.labelsize": 14,
    "ytick.labelsize": 14,
})

DAY = 86400.0  # day to sec
TARGET_XC = 0.5

runs = {
    name: path
    for name, path in {
        "step ov": Path("LOGS_step_ov"),
        "exp ov": Path("LOGS_exp_ov"),
        "PC": Path("LOGS_PC"),
    }.items()
    if path.exists()
}

styles = {
    "step ov": dict(color="C0", ls="-"),
    "exp ov":  dict(color="C1", ls="--"),
    "PC":      dict(color="C2", ls=":"),
}


def read_mesa_table(path):
    """
    Read a MESA history/profile file with standard MESA header format.
    """
    path = Path(path)
    lines = path.read_text(errors="replace").splitlines()

    blank = next(i for i, line in enumerate(lines) if not line.strip())

    cols = lines[blank + 2].split()
    data = "\n".join(lines[blank + 3:])

    return pd.read_csv(StringIO(data), sep=r"\s+", names=cols)


def read_profiles_index(logdir):
    """
    Read profiles.index or profile.index in a LOGS directory.
    """
    for name in ["profiles.index", "profile.index"]:
        path = logdir / name
        if path.exists():
            return pd.read_csv(
                path,
                sep=r"\s+",
                skiprows=1,
                names=["model_number", "priority", "profile_number"],
                comment="#",
            )

    raise FileNotFoundError(
        f"Cannot find profiles.index or profile.index in {logdir}"
    )


def find_history_file(logdir):
    """
    Find the main-sequence history file in a LOGS directory.
    Prefer *MS.history if available.
    """
    candidates = sorted(logdir.glob("*MS.history"))

    if not candidates:
        candidates = sorted(logdir.glob("*.history"))

    if not candidates:
        raise FileNotFoundError(f"No history file found in {logdir}")

    return candidates[0]


def find_profile_file(logdir, profile_number):
    """
    Find the profile file corresponding to a profile number.
    """
    profile_number = int(profile_number)

    candidates = [
        logdir / f"profile{profile_number}.data",
        logdir / f"profile{profile_number:05d}.data",
    ]

    for path in candidates:
        if path.exists():
            return path

    matches = sorted(logdir.glob(f"profile*{profile_number}*.data"))

    if matches:
        return matches[0]

    raise FileNotFoundError(
        f"Cannot find profile file for profile_number={profile_number} in {logdir}"
    )


def find_profile_at_xc(logdir, target=0.5):
    """
    Find the profile closest to target center_h1.

    Logic:
    1. Read the MS history file.
    2. Find model_number where center_h1 is closest to target.
    3. Use profiles.index to map model_number to profile_number.
    4. Read the corresponding profile file.
    """
    hist_file = find_history_file(logdir)
    hist = read_mesa_table(hist_file)
    pidx = read_profiles_index(logdir)

    if "center_h1" not in hist.columns:
        raise KeyError(f"{hist_file} does not contain center_h1")

    if "model_number" not in hist.columns:
        raise KeyError(f"{hist_file} does not contain model_number")

    # Find the target model in history.
    idx = np.argmin(np.abs(hist["center_h1"].to_numpy() - target))
    row_h = hist.iloc[idx]
    target_model_number = int(row_h["model_number"])

    # Find the corresponding saved profile.
    matched = pidx[pidx["model_number"] == target_model_number]

    if len(matched) == 0:
        # If the exact model was not saved as a profile, use the nearest saved model.
        j = np.argmin(
            np.abs(pidx["model_number"].to_numpy() - target_model_number)
        )
        matched = pidx.iloc[[j]]

    row_p = matched.iloc[0]
    saved_model_number = int(row_p["model_number"])
    profile_number = int(row_p["profile_number"])

    prof_file = find_profile_file(logdir, profile_number)
    prof = read_mesa_table(prof_file)

    print(
        f"{logdir.name:12s} | "
        f"history = {hist_file.name:20s} | "
        f"target model = {target_model_number:6d} | "
        f"saved model = {saved_model_number:6d} | "
        f"profile = {prof_file.name:16s} | "
        f"center_h1 = {row_h['center_h1']:.6f}"
    )

    return prof


def main():
    fig, (ax_abun, ax_prop) = plt.subplots(
        2,
        1,
        figsize=(7.2, 7.6),
        sharex=True,
        gridspec_kw={"height_ratios": [1.0, 1.15], "hspace": 0.05},
    )

    for label, logdir in runs.items():
        prof = find_profile_at_xc(logdir, TARGET_XC)

        # MESA profile "mass" is the enclosed mass coordinate, usually in Msun.
        # Convert it to enclosed mass fraction m/M_star.
        mfrac = prof["mass"].to_numpy() / prof["mass"].max()

        # Abundance diagram
        ax_abun.plot(
            mfrac,
            prof["h1"],
            lw=1.0,
            alpha=0.6,
            label=rf"{label}: $X_\mathrm{{H}}$",
            **styles[label],
        )

        ax_abun.plot(
            mfrac,
            prof["he4"],
            lw=1.0,
            alpha=0.6,
            label=rf"{label}: $Y_\mathrm{{He}}$",
            **styles[label],
        )

        # Propagation diagram
        small = 1e-30

        # brunt_N2 is in rad^2/s^2, so sqrt gives rad/s.
        N = np.sqrt(np.maximum(prof["brunt_N2"].to_numpy(), small))
        N_cpd = N / (2.0 * np.pi) * DAY

        # lamb_Sl1 is usually in microHz, i.e. 1e-6 cycles/s.
        S1_cpd = np.maximum(prof["lamb_Sl1"].to_numpy(), small) * 1e-6 * DAY

        ax_prop.plot(
            mfrac,
            np.log10(N_cpd),
            lw=1.0,
            alpha=0.6,
            label=rf"{label}: $N/2\pi$",
            **styles[label],
        )

        ax_prop.plot(
            mfrac,
            np.log10(S1_cpd),
            lw=1.0,
            alpha=0.6,
            label=rf"{label}: $S_{{\ell=1}}$",
            **styles[label],
        )

    ax_abun.set_ylabel("Mass fraction")
    ax_abun.set_ylim(-0.03, 1.03)
    ax_abun.legend(frameon=False, fontsize=10, ncol=2)

    ax_prop.set_xlabel(r"$m/M_\star$")
    ax_prop.set_ylabel(r"$\log_{10}(\mathrm{frequency}/\mathrm{day}^{-1})$")
    ax_prop.set_ylim(-0.5, 2.2)
    ax_prop.legend(frameon=False, fontsize=10, ncol=2)

    fig.savefig("compare_XcH050_structure_mass_fraction.png", dpi=300, bbox_inches="tight")


if __name__ == "__main__":
    main()

```
{{</details>}}

The program will automatically save `compare_XcH050_structure_mass_fraction.png` in the directory.

<!-- <a href="/tuesday/downloads/lab3/diff_mixing_profiles_in_mass.py" download>python script</a> -->

Run the plotting script from the directory that contains these three folders. 

The workflow in the plotting script is:
- For each LOGS_* directory, find the main sequence history file, such as `step_ov_MS.history`, `exp_ov_MS.history`, or `PC_MS.history`. 
- In that history file, find the `model_number` with `center_h1` is closest to 0.5. 
- Use `profiles.index` to map that model_number to the corresponding profile_number. 
- Read the corresponding `profile*.data` file. 
- Plot the abundance profiles and propagation diagrams for the three mixing prescriptions on the same figure.

In next section we explain shortly the purpose of different sections of the plotting script.

### Code Block 1: Basic Setup

This block imports the required packages, defines the target central hydrogen abundance, and lists the three output directories.

<details>
    <summary>Python: imports, constants, and run labels</summary>
    
```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from io import StringIO

DAY = 86400.0
TARGET_XC = 0.5

runs = {
    name: path
    for name, path in {
        "step ov": Path("LOGS_step_ov"),
        "exp ov": Path("LOGS_exp_ov"),
        "PC": Path("LOGS_PC"),
    }.items()
    if path.exists()
}

styles = {
    "step ov": dict(color="C0", ls="-"),
    "exp ov":  dict(color="C1", ls="--"),
    "PC":      dict(color="C2", ls=":"),
}
```

</details>

### Code Block 2: Read a MESA History or Profile File

MESA history and profile files have a header section, then a blank line, then the main data table. This helper function reads the main table into a pandas DataFrame.

<details>
    <summary>Python: helper function for MESA tables</summary>
    
```python
def read_mesa_table(path):

    path = Path(path)
    lines = path.read_text(errors="replace").splitlines()

    blank = next(i for i, line in enumerate(lines) if not line.strip())

    cols = lines[blank + 2].split()
    data = "\n".join(lines[blank + 3:])

    return pd.read_csv(StringIO(data), sep=r"\s+", names=cols)
```

</details>

### Code Block 3: Read profiles.index

The history file tells us which model_number is closest to `Xc(H)=0.5`. The `profiles.index` file tells us which profile file corresponds to that model.

<details>
    <summary>Python: read profiles.index</summary>
    
```python
def read_profiles_index(logdir):
    """
    Read profiles.index or profile.index in a LOGS directory.

    The columns are:
        model_number, priority, profile_number
    """
    for name in ["profiles.index", "profile.index"]:
        path = logdir / name
        if path.exists():
            return pd.read_csv(
                path,
                sep=r"\s+",
                skiprows=1,
                names=["model_number", "priority", "profile_number"],
                comment="#",
            )

    raise FileNotFoundError(
        f"Cannot find profiles.index or profile.index in {logdir}"
    )
```

</details>

### Code Block 4: Find the History and Profile File

<details>
    <summary>Python: locate history and profile files</summary>
    
```python
def find_history_file(logdir):

    candidates = sorted(logdir.glob("*MS.history"))

    if not candidates:
        candidates = sorted(logdir.glob("*.history"))

    if not candidates:
        raise FileNotFoundError(f"No history file found in {logdir}")

    return candidates[0]

def find_profile_file(logdir, profile_number):

    profile_number = int(profile_number)

    candidates = [
        logdir / f"profile{profile_number}.data",
        logdir / f"profile{profile_number:05d}.data",
    ]

    for path in candidates:
        if path.exists():
            return path

    matches = sorted(logdir.glob(f"profile*{profile_number}*.data"))

    if matches:
        return matches[0]

    raise FileNotFoundError(
        f"Cannot find profile file for profile_number={profile_number} in {logdir}"
    )
```

</details>

### Code Block 5: Find the Profile Closest to Xc(H) = 0.5

<details>
    <summary>Python: select the profile closest to Xc(H)=0.5</summary>
    
```python
def find_profile_at_xc(logdir, target=0.5):

    hist_file = find_history_file(logdir)
    hist = read_mesa_table(hist_file)
    pidx = read_profiles_index(logdir)

    if "center_h1" not in hist.columns:
        raise KeyError(f"{hist_file} does not contain center_h1")

    if "model_number" not in hist.columns:
        raise KeyError(f"{hist_file} does not contain model_number")

    idx = np.argmin(np.abs(hist["center_h1"].to_numpy() - target))
    row_h = hist.iloc[idx]
    target_model_number = int(row_h["model_number"])

    matched = pidx[pidx["model_number"] == target_model_number]

    if len(matched) == 0:
        j = np.argmin(
            np.abs(pidx["model_number"].to_numpy() - target_model_number)
        )
        matched = pidx.iloc[[j]]

    row_p = matched.iloc[0]
    saved_model_number = int(row_p["model_number"])
    profile_number = int(row_p["profile_number"])

    prof_file = find_profile_file(logdir, profile_number)
    prof = read_mesa_table(prof_file)

    print(
        f"{logdir.name:12s} | "
        f"history = {hist_file.name:20s} | "
        f"target model = {target_model_number:6d} | "
        f"saved model = {saved_model_number:6d} | "
        f"profile = {prof_file.name:16s} | "
        f"center_h1 = {row_h['center_h1']:.6f}"
    )

    return prof
```

</details>

### Code Block 6: Make the Comparison Plot

This final block loops over the three mixing prescriptions, reads the selected profile, and plots:

`h1` and `he4` in the abundance diagram;
`N/2pi` and `S_l/2pi` in the propagation diagram.

The unit conversion for the Brunt-Vaisala frequency is:

```text
brunt_N2:        rad^2/s^2
sqrt(brunt_N2):  rad/s
N/(2pi):         cycles/s
N/(2pi)*86400:   cycles/day
```

For `lamb_Sl1`, MESA stores the Lamb frequency in microHz, so:

```text
lamb_Sl1 * 1e-6 * 86400 = cycles/day
```

<details>
    <summary>Python: make the abundance and propagation plots</summary>
    
```python
fig, (ax_abun, ax_prop) = plt.subplots(
    2,
    1,
    figsize=(7.2, 7.6),
    sharex=True,
    gridspec_kw={"height_ratios": [1.0, 1.15], "hspace": 0.05},
)

for label, logdir in runs.items():
    prof = find_profile_at_xc(logdir, TARGET_XC)

    mfrac = prof["mass"].to_numpy() / prof["mass"].max()

    # Abundance diagram
    ax_abun.plot(
        mfrac,
        prof["h1"],
        lw=1.0,
        alpha=0.6,
        label=rf"{label}: $X_\mathrm{{H}}$",
        **styles[label],
    )

    ax_abun.plot(
        mfrac,
        prof["he4"],
        lw=1.0,
        alpha=0.6,
        label=rf"{label}: $Y_\mathrm{{He}}$",
        **styles[label],
    )

    # Propagation diagram
    small = 1e-30

    N = np.sqrt(np.maximum(prof["brunt_N2"].to_numpy(), small))
    N_cpd = N / (2.0 * np.pi) * DAY

    S1_cpd = np.maximum(prof["lamb_Sl1"].to_numpy(), small) * 1e-6 * DAY

    ax_prop.plot(
        mfrac,
        np.log10(N_cpd),
        lw=1.0,
        alpha=0.6,
        label=rf"{label}: $N/2\pi$",
        **styles[label],
    )

    ax_prop.plot(
        mfrac,
        np.log10(S1_cpd),
        lw=1.0,
        alpha=0.6,
        label=rf"{label}: $S_{{\ell=1}}/2\pi$",
        **styles[label],
    )

ax_abun.set_ylabel("Mass fraction")
ax_abun.set_ylim(-0.03, 1.03)
ax_abun.legend(frameon=False, fontsize=10, ncol=2)

ax_prop.set_xlabel(r"$m/M_\star$")
ax_prop.set_ylabel(r"$\log_{10}(\mathrm{frequency}/\mathrm{day}^{-1})$")
ax_prop.set_ylim(-0.5, 2.2)
ax_prop.legend(frameon=False, fontsize=10, ncol=2)
fig.savefig("compare_XcH050_structure.png", dpi=300, bbox_inches="tight")
```

</details>

### Example Output

The figure below shows an example comparison at approximately `Xc(H) = 0.5`. The upper panel compares the hydrogen and helium abundance profiles, while the lower panel shows the corresponding propagation diagram for the three mixing prescriptions.
<!-- The complete solution script for Task 8 is provided as `diff_mixing_profiles_in_mass.py`. -->

<img src="https://github.com/astroscien/2026MESA-school-day2-lab3/blob/main/compare_XcH050_structure_mass_fraction_f0p86.png?raw=true" width="750">

---

## References

- [Johnston et al. (2024)](https://ui.adsabs.harvard.edu/abs/2024ApJ...964..170J/abstract), *Modelling Time-dependent Convective Penetration in 1D Stellar Evolution*, ApJ, 964, 170.
