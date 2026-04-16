! ***********************************************************************
!
!   Copyright (C) 2010-2025  The MESA Team
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

module run_star_extras

   use star_lib
   use star_def
   use const_def
   use math_lib
   use auto_diff
   use chem_def
   use utils_lib
   use gyre_mesa_m

   implicit none

contains

include 'gyre_in_mesa_extras_finish_step.inc'

   subroutine extras_controls(id, ierr)
      integer, intent(in) :: id
      integer, intent(out) :: ierr
      type(star_info), pointer :: s
      ierr = 0
      call star_ptr(id, s, ierr)
      if (ierr /= 0) return

      s%extras_startup => extras_startup
      s%extras_start_step => extras_start_step
      s%extras_check_model => extras_check_model
      s%extras_finish_step => extras_finish_step
      s%extras_after_evolve => extras_after_evolve
      s%how_many_extra_history_columns => how_many_extra_history_columns
      s%data_for_extra_history_columns => data_for_extra_history_columns
      s%how_many_extra_profile_columns => how_many_extra_profile_columns
      s%data_for_extra_profile_columns => data_for_extra_profile_columns
   end subroutine extras_controls


   subroutine extras_startup(id, restart, ierr)
      integer, intent(in) :: id
      logical, intent(in) :: restart
      integer, intent(out) :: ierr
      type(star_info), pointer :: s
      include 'formats'
      ierr = 0
      call star_ptr(id, s, ierr)
      if (ierr /= 0) return

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

   subroutine extras_after_evolve(id, ierr)
      integer, intent(in) :: id
      integer, intent(out) :: ierr
      type(star_info), pointer :: s
      real(dp) :: dt
      character(len=strlen) :: test
      ierr = 0
      call star_ptr(id, s, ierr)
      if (ierr /= 0) return

      if (.not. s%x_logical_ctrl(37)) return
      call final()
   end subroutine extras_after_evolve

   ! returns either keep_going, retry, or terminate.
   integer function extras_check_model(id)
      integer, intent(in) :: id
      integer :: ierr, k
      real(dp) :: max_v
      type(star_info), pointer :: s
      include 'formats'
      ierr = 0
      call star_ptr(id, s, ierr)
      if (ierr /= 0) return
      extras_check_model = keep_going

   end function extras_check_model

   integer function how_many_extra_history_columns(id)
      integer, intent(in) :: id
      integer :: ierr
      type(star_info), pointer :: s
      ierr = 0
      call star_ptr(id, s, ierr)
      if (ierr /= 0) return
      how_many_extra_history_columns = 0
   end function how_many_extra_history_columns

   subroutine data_for_extra_history_columns(id, n, names, vals, ierr)
      integer, intent(in) :: id, n
      character(len=maxlen_history_column_name) :: names(n)
      real(dp) :: vals(n), v_esc
      integer, intent(out) :: ierr
      type(star_info), pointer :: s
      integer :: k, k0
      ierr = 0
      call star_ptr(id, s, ierr)
      if (ierr /= 0) return
   end subroutine data_for_extra_history_columns

   integer function how_many_extra_profile_columns(id)
      use star_def, only: star_info
      integer, intent(in) :: id
      integer :: ierr
      type(star_info), pointer :: s
      ierr = 0
      call star_ptr(id, s, ierr)
      if (ierr /= 0) return
      how_many_extra_profile_columns = 0
   end function how_many_extra_profile_columns

   subroutine data_for_extra_profile_columns(id, n, nz, names, vals, ierr)
      use star_def, only: star_info, maxlen_profile_column_name
      use const_def, only: dp
      integer, intent(in) :: id, n, nz
      character(len=maxlen_profile_column_name) :: names(n)
      real(dp) :: vals(nz, n)
      integer, intent(out) :: ierr
      type(star_info), pointer :: s
      integer :: k
      ierr = 0
      call star_ptr(id, s, ierr)
      if (ierr /= 0) return
   end subroutine data_for_extra_profile_columns

   integer function extras_start_step(id)
      integer, intent(in) :: id
      integer :: ierr
      type(star_info), pointer :: s
      include 'formats'
      extras_start_step = terminate
      ierr = 0
      call star_ptr(id, s, ierr)
      if (ierr /= 0) return

      extras_start_step = keep_going
   end function extras_start_step

   ! returns either keep_going or terminate.
   integer function extras_finish_step(id)
      use run_star_support
      integer, intent(in) :: id
      integer :: ierr, k
      type(star_info), pointer :: s
      character(len=150) :: name
      integer :: Teff
      real(dp) :: mass
      integer :: lumi
      include 'formats'
      ierr = 0
      call star_ptr(id, s, ierr)
      if (ierr /= 0) return

      extras_finish_step = keep_going

     ! do not spit out gyre information except during core-He burning.
     if (s% center_h1 <= 1d-12 .and. safe_log10(s% power_he_burn) >1d0) then
         s% x_integer_ctrl(1) = 10
     else
         s% x_integer_ctrl(1) = 9999999
     end if

     Teff = int(s% Teff)
     mass = s% m(1) / Msun
     lumi = int(s% L(1) / Lsun)

     ! Skeleton for spitting out .mod files
      if ((s% center_h1 < 1d-12 .and. safe_log10(s% power_he_burn) >1d0) .and. mod(s% model_number,1)==0) then
         write(name, '(a,i0,a,f6.4,a,i0,a,i0,a)') 'mod_dir/', s%model_number, '_', mass, '_', Teff, '_', lumi, '.mod'
         call star_write_model(id, name, ierr)
         !s% need_to_save_profiles_now = .true.
      end if

      if (.not. s% x_logical_ctrl(37)) return
      extras_finish_step = gyre_in_mesa_extras_finish_step(id)

      if (extras_finish_step == terminate) s%termination_code = t_extras_finish_step

   end function extras_finish_step

end module run_star_extras

