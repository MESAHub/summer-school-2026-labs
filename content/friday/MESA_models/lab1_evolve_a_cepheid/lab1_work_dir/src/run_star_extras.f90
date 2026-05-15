! ***********************************************************************
!
!   Copyright (C) 2010-2025  Bill Paxton & The MESA Team
!
!   This program is free software: you can redistribute it and/or modify
!   it under the terms of the GNU Lesser General Public License
!   as published by the Free Software Foundation,
!   either version 3 of the License, or (at your option) any later version.
!
!   This program is distributed in the hope that it will be useful,
!   but WITHOUT ANY WARRANTY; without even the implied warranty of
!   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
!   See the GNU Lesser General Public License for more details.
!
!   You should have received a copy of the GNU Lesser General Public License
!   along with this program. If not, see <https://www.gnu.org/licenses/>.
!
! ***********************************************************************

! This run_star_extras has been designed for Lab 1 of the Friday lab at the 2026 Summer School.
! It contains the following functionality:
! 1. Calling GYRE during core helium burning to determine period and growth rates of the radial fundamental, first & second overtones
! 2. Saves GYRE output to history file
! 3. Saves models when near the instability strip (defined by effective temperature) with a custom name scheme

! We use the following user specified parameters:

! x_integer_ctrl(1) - output GYRE info at this step interval
! x_integer_ctrl(2) - max number of modes to output per call
! x_integer_ctrl(3) - mode l, should match gyre.in mode l

! x_ctrl(1) - set Teff limit of when to start saving models

module run_star_extras

   use star_lib
   use star_def
   use const_def
   use math_lib
   use gyre_mesa_m ! Load in the GYRE library

   implicit none

   real(dp) :: F_period, F_growth, O1_period, O1_growth, O2_period, O2_growth ! GYRE variables to write to history

contains

      subroutine extras_controls(id, ierr)
         integer, intent(in) :: id
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return

         ! this is the place to set any procedure pointers you want to change
         ! e.g., other_wind, other_mixing, other_energy  (see star_data.inc)


         ! the extras functions in this file will not be called
         ! unless you set their function pointers as done below.
         ! otherwise we use a null_ version which does nothing (except warn).

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

      end subroutine extras_controls


      subroutine extras_startup(id, restart, ierr)
         integer, intent(in) :: id
         logical, intent(in) :: restart
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         logical :: mod_dir_exists
         integer :: mkdir_status
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return

         inquire(file='mod_dir/.', exist=mod_dir_exists)
         if (.not. mod_dir_exists) then
            call execute_command_line('mkdir -p mod_dir', exitstat=mkdir_status)
            if (mkdir_status /= 0) then
               ierr = mkdir_status
               write(*, *) 'Failed to create mod_dir'
               return
            end if
         end if

      ! Initialize GYRE

      call init('gyre.in')

      ! Set constants

      call set_constant('G_GRAVITY', standard_cgrav)
      call set_constant('C_LIGHT', clight)
      call set_constant('A_RADIATION', crad)

      call set_constant('M_SUN', Msun)
      call set_constant('R_SUN', Rsun)
      call set_constant('L_SUN', Lsun)

      call set_constant('GYRE_DIR', TRIM(mesa_dir)//'/build/gyre/src')

      end subroutine extras_startup


      integer function extras_start_step(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_start_step = 0
      end function extras_start_step


      ! returns either keep_going, retry, or terminate.
      integer function extras_check_model(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_check_model = keep_going

         ! if you want to check multiple conditions, it can be useful
         ! to set a different termination code depending on which
         ! condition was triggered.  MESA provides 9 customizable
         ! termination codes, named t_xtra1 .. t_xtra9.  You can
         ! customize the messages that will be printed upon exit by
         ! setting the corresponding termination_code_str value.
         ! termination_code_str(t_xtra1) = 'my termination condition'

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
         how_many_extra_history_columns = 8 ! Period/growth for F, O1, O2 plus photosphere X/Z
      end function how_many_extra_history_columns


      subroutine data_for_extra_history_columns(id, n, names, vals, ierr)
         integer, intent(in) :: id, n
         character (len=maxlen_history_column_name) :: names(n)
         real(dp) :: vals(n)
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return

         ! note: do NOT add the extras names to history_columns.list
         ! the history_columns.list is only for the built-in history column options.
         ! it must not include the new column names you are adding here.

         names(1) = 'F_period'
         vals(1) = F_period

         names(2) = 'F_growth'
         vals(2) = F_growth

         names(3) = 'O1_period'
         vals(3) = O1_period

         names(4) = 'O1_growth'
         vals(4) = O1_growth

         names(5) = 'O2_period'
         vals(5) = O2_period

         names(6) = 'O2_growth'
         vals(6) = O2_growth

         names(7) = 'photosphere_X'
         vals(7) = s% X(s% photosphere_cell_k)

         names(8) = 'photosphere_Z'
         vals(8) = s% Z(s% photosphere_cell_k)

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
         type (star_info), pointer :: s
         integer :: k
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return

         ! note: do NOT add the extra names to profile_columns.list
         ! the profile_columns.list is only for the built-in profile column options.
         ! it must not include the new column names you are adding here.

         ! here is an example for adding a profile column
         !if (n /= 1) stop 'data_for_extra_profile_columns'
         !names(1) = 'beta'
         !do k = 1, nz
         !   vals(k,1) = s% Pgas(k)/s% P(k)
         !end do

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
      ! note: cannot request retry; extras_check_model can do that.
      integer function extras_finish_step(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         real(dp), allocatable     :: global_data(:)
         real(dp), allocatable     :: point_data(:,:)
         character(len=150) :: name
         logical :: call_gyre, need_to_save_model, in_gyre_region
         integer :: gyre_interval, max_mode_num, mode_l, save_mod_interval, ipar(3), Teff, lumi
         real(dp), parameter :: gyre_logTeff_min = 3.66d0
         real(dp) :: save_mod_Teff_limit, rpar(1), mass

         real(dp) :: logTeff     ! log value of the effective temperature

         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_finish_step = keep_going

         call_gyre = .false. ! Assume we don't need to call GYRE
         need_to_save_model = .false.

         ! Save user specified parameters with meaningful names
         gyre_interval = s% x_integer_ctrl(1)! Sets how often to call GYRE in the inlist
         max_mode_num = s% x_integer_ctrl(1) ! Sets how many modes should be saved
         mode_l = s% x_integer_ctrl(1)       ! Sets l value of modes

         save_mod_Teff_limit = s% x_ctrl(1) ! Sets minimum Teff necessary to save a model
         logTeff = safe_log10(s% Teff)

         ! ====== TODO: add stopping condition here! ======

         ! ================================================

         ! Zero out period and growth rate information from previous step, if we don't call GYRE then values stay 0.
         F_period = 0d0
         F_growth = 0d0
         O1_period = 0d0
         O1_growth = 0d0
         O2_period = 0d0
         O2_growth = 0d0

         ! Check if in He burning and we're calling GYRE.
         in_gyre_region = s% center_h1 <= 1d-12 .and. &
            safe_log10(s% power_he_burn) >1d0 .and. logTeff > gyre_logTeff_min
         if (in_gyre_region) then
            save_mod_interval = gyre_interval
            s% history_interval = gyre_interval
            s% terminal_interval = gyre_interval
            if (gyre_interval > 0 .and. MOD(s% model_number, gyre_interval) == 0) then
               call_gyre = .true.
            end if
            if (save_mod_interval > 0 .and. MOD(s% model_number, save_mod_interval) == 0) then
               need_to_save_model = .true.
            end if
         else
            save_mod_interval = -1
            s% history_interval = 10
            s% terminal_interval = 10
         end if

    ! If necessary, call GYRE

         if (call_gyre) then

            ! This call gets the structure variables necessary to calculate the pulsations and stores them in global_data and point_data
            call star_get_pulse_data(s%id, 'GYRE', .FALSE., .FALSE., .FALSE., global_data, point_data, ierr)
            if (ierr /= 0) then
               print *,'Failed when calling star_get_pulse_data'
               return
            end if

            ! This subroutine constructs the data structure that GYRE uses to calculate modes
            call set_model(global_data, point_data, s%gyre_data_schema)

            ! Write header to terminal
            write(*, 100) 'model', 'order', 'freq (Hz)', &
               'P (sec)', 'P (day)', 'growth (day)', 'growth', 'cycles to double'
100            format(2A8,99A20)

            ipar(1) = s% id
            ipar(2) = max_mode_num
            ipar(3) = 0 ! num_written

            ! The subroutine calls GYRE to find the modes.
            ! After each mode is found, it calls the subroutine process_mode_cepheid defined below
            ! Integer parameters are passed with ipar and real parameters are passed with rpar
            ! These two arrays allow us to pass information back and forth with the process mode subroutine
            ! However we choose to use the xtra#_array values that are a part of the star_info structure, so indexing is less confusing
            call get_modes(mode_l, process_mode_cepheid, ipar, rpar)

            s% ixtra3_array(1) = ipar(3)

            ! Store mode information in variables that are called by data_for_extra_history_columns
            ! process_mode_cepheid saves periods in xtra1_array, and growth rates in xtra2_array
            F_period = s% xtra1_array(1)
            F_growth = s% xtra2_array(1)
            O1_period = s% xtra1_array(2)
            O1_growth = s% xtra2_array(2)
            O2_period = s% xtra1_array(3)
            O2_growth = s% xtra2_array(3)

         end if

         ! Decide if we need to save a model based on the interval and Teff limit.
         if (need_to_save_model) then
            Teff = int(s% Teff)
            mass = s% m(1) / Msun
            lumi = int(s% L(1) / Lsun)

            if (Teff > save_mod_Teff_limit) then
               write(name, '(a,i0,a,f6.4,a,i0,a,i0,a)') 'mod_dir/', s%model_number, '_', mass, '_', Teff, '_', lumi, '.mod'
               call star_write_model(id, name, ierr)
            end if
         end if


         !extras_finish_step = keep_going    ! sofia: why is this here in the first place??
         ! to save a profile,
            ! s% need_to_save_profiles_now = .true.
         ! to update the star log,
            ! s% need_to_update_history_now = .true.

         ! see extras_check_model for information about custom termination codes
         ! by default, indicate where (in the code) MESA terminated
         if (extras_finish_step == terminate) s% termination_code = t_extras_finish_step

      contains

             subroutine process_mode_cepheid (md, ipar, rpar, retcode)


               type(mode_t), intent(in) :: md
               integer, intent(inout)   :: ipar(:)
               real(dp), intent(inout)  :: rpar(:)
               integer, intent(out)     :: retcode

               character(LEN=strlen) :: filename
               integer               :: ierr, unit, k, model_number, num_written, max_to_write !, order_target
               complex(dp)           :: cfreq
               real(dp)              :: freq, growth, period
               type(grid_t)          :: gr
               type (star_info), pointer :: s


               ierr = 0
               call star_ptr(ipar(1), s, ierr)
               if (ierr /= 0) return

               ! Since we only want to save three modes with the lowest frequencies,
               ! exit if we have already found three frequencies.
               ! GYRE returns modes from lowest to highest frequency.
               max_to_write = ipar(2)
               num_written = ipar(3)
               if (num_written >= max_to_write) return
               num_written = num_written + 1
               ipar(3) = num_written

               model_number = s% model_number
               cfreq = md% freq('HZ')
               growth = AIMAG(cfreq) ! in seconds
               freq = REAL(cfreq) ! in seconds
               period = 1d0/freq ! in seconds
               if (growth > 0d0) then ! unstable
                  write(*, 100) model_number, md%n_pg, &
                     freq, period, period/(24*3600), 1d0/(2*pi*24*3600*AIMAG(cfreq)), &
                     (2d0*pi*growth)/freq, freq/(2d0*pi*growth)
100                  format(2I8,E20.4,5F20.4)
               else ! stable
                  write(*, 110) model_number, md%n_pg, &
                     freq, period, period/(24*3600), 'stable'
110               format(2I8,E20.4,2F20.4,A20)
               end if

               ! xtra_arrays are used to store data
               s% ixtra1_array(num_written) = md%n_pg
               s% xtra1_array(num_written) = period/(24*3600) ! Save period in days
               s% xtra2_array(num_written) =  (2d0*pi*growth)/freq ! Save fractional growth rate

               retcode = 0

            end subroutine process_mode_cepheid

      end function extras_finish_step


      subroutine extras_after_evolve(id, ierr)
         integer, intent(in) :: id
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
      end subroutine extras_after_evolve
end module run_star_extras
