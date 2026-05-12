! ***********************************************************************
!
!   Copyright (C) 2018-2019  The MESA Team
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

!!! Solutions for the bonus task of Lab 2 for Friday's lab at the 2026 MESA Summer school
!!! This file runs RSP-LNA using the parameters specified in the inlist. 
!!! It then saves the following in an output specified by x_character_ctrl(10): 
!!! M, L, Teff, Wesenheit index, RSP F Period, RSP F Growth Rate, GYRE F Period, GYRE F Growth Rate
!!! This run_star_extras is designed to be called within a bash script that loops over a number of models 
!!! and so it appends to the file. 

module run_star_extras

      use star_lib
      use star_def
      use const_def
      use math_lib
      use auto_diff
      use gyre_mesa_m ! Load in the GYRE library 

      implicit none

      logical :: need_to_write_LINA_data

      contains


      subroutine extras_controls(id, ierr)
         integer, intent(in) :: id
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         s% extras_startup => extras_startup
         s% extras_check_model => extras_check_model
         s% extras_start_step => extras_start_step
         s% extras_finish_step => extras_finish_step
         s% extras_after_evolve => extras_after_evolve
         s% how_many_extra_history_columns => how_many_extra_history_columns
         s% data_for_extra_history_columns => data_for_extra_history_columns
         s% how_many_extra_profile_columns => how_many_extra_profile_columns
         s% data_for_extra_profile_columns => data_for_extra_profile_columns
      end subroutine extras_controls


      subroutine extras_startup(id, restart, ierr)
         integer, intent(in) :: id
         logical, intent(in) :: restart
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
!         call test_suite_startup(s, restart, ierr)
         if (.not. restart) then
            need_to_write_LINA_data = len_trim(s% x_character_ctrl(10)) > 0
         else  ! it is a restart
            need_to_write_LINA_data = .false.
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
         use colors_def, only: Colors_General_Info, get_colors_ptr
         use colors_lib, only: how_many_colors_history_columns, data_for_colors_history_columns
         integer, intent(in) :: id
         integer :: ierr, io, i, ipar(3)
         character(len= 10) :: mod_num
         type (star_info), pointer :: s
         real(dp) :: GYRE_F_period, GYRE_F_growth, rpar(1)
         real(dp), allocatable     :: global_data(:)
         real(dp), allocatable     :: point_data(:,:)
         real(dp) :: m_div_h, min_m_div_h, max_m_div_h, V_mag, I_mag, R_VI, W_VI
         type(colors_general_info), pointer :: colors_settings => null()
         integer :: num_colors_cols
         character (len = maxlen_history_column_name), pointer, dimension(:) :: colors_col_names
         real(dp), pointer, dimension(:) :: colors_col_vals
      
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_start_step = keep_going

         ! Get Colors information 
         R_VI = 1.55 ! Hard coded to agree with the value used in Smolec et al. 2026   
         W_VI = 0d0 ! Maybe pick more obvious null value? 
         call get_colors_ptr(s% colors_handle, colors_settings, ierr)
         if(ierr/=0) return

         num_colors_cols = how_many_colors_history_columns(s% colors_handle)
         nullify(colors_col_names)
         nullify(colors_col_vals)

         if (num_colors_cols > 0) then
            allocate(&
               colors_col_names(num_colors_cols), colors_col_vals(num_colors_cols), stat = ierr)

            colors_col_names(1:num_colors_cols) = 'unknown'
            colors_col_vals(1:num_colors_cols) = -1d99

            ! Here we compute [Fe/H], and then call colors to compute history columns.

            min_m_div_h = minval(colors_settings% lu_meta)
            max_m_div_h = maxval(colors_settings% lu_meta)

            ! Map the current photospheric Z/X onto the atmosphere table metallicity axis.
            if (s% X(s% photosphere_cell_k) > 0d0 .and. s% Z(s% photosphere_cell_k) > 0d0) then
               m_div_h = log10((s% Z(s% photosphere_cell_k)/s% X(s% photosphere_cell_k)) / &
                  colors_settings% z_over_x_ref)
               m_div_h = max(min_m_div_h, min(max_m_div_h, m_div_h))
            else
               m_div_h = min_m_div_h
            end if

            call data_for_colors_history_columns(s%T(1), log10(s%grav(1)), s%R(1), m_div_h, &
               s% model_number, s% colors_handle, num_colors_cols, colors_col_names, colors_col_vals, ierr)

            do i = 1, num_colors_cols
               if(trim(colors_col_names(i))=='V') then
                  V_mag = colors_col_vals(i) 
               else if (trim(colors_col_names(i)) == 'I') then 
                  I_mag = colors_col_vals(i) 
               end if
            end do
            W_VI = I_mag - R_VI*(V_mag-I_mag)  
            write(*,*) "Wesenheit Index:     ", W_VI
 
         end if 

         if (need_to_write_LINA_data) then
            ! Get GYRE Information 
            call star_get_pulse_data(s%id, 'GYRE', .FALSE., .FALSE., .FALSE., global_data, point_data, ierr)
            if (ierr /= 0) then
               print *,'Failed when calling star_get_pulse_data'
               return
            end if
          
            ! This subroutine constructs the data structure that GYRE uses to calculate modes
            call set_model(global_data, point_data, s%gyre_data_schema)

            ipar(1) = s% id
            ipar(2) = 1
            ipar(3) = 0 ! num_written

            call get_modes(0, process_mode_cepheid, ipar, rpar)
            
            GYRE_F_period = s% xtra1_array(1)
            GYRE_F_growth = s% xtra2_array(1)

            io = 61
            open(io,file=trim(s% x_character_ctrl(10)),status='unknown', position='append')
            write(io, '(99e16.4)') s% RSP_mass, s% RSP_L, s% RSP_Teff, W_VI, &
               s% rsp_LINA_periods(1)/86400.d0, s% rsp_LINA_growth_rates(1), GYRE_F_period, GYRE_F_growth
            close(io)
            write(*,*) 'write ' // trim(s% x_character_ctrl(10))
            need_to_write_LINA_data = .false.
         end if

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
            period = 0 ! days
            if (growth > 0d0) then ! unstable
               period = 1d0/freq ! in seconds
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
            if (growth > 0d0) then
               s% xtra2_array(num_written) =  (2d0*pi*growth)/freq ! Save fractional growth rate 
               ! s% xtra2_array(num_written) =  growth ! Save non-fractional growth rate to match with RSP
            else
               s% xtra2_array(num_written) = -1d0 ! If stable, then save growth rate as -1 
            end if

            retcode = 0

         end subroutine process_mode_cepheid

      end function extras_start_step


      ! returns either keep_going or terminate.
      integer function extras_finish_step(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s

         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_finish_step = keep_going   

      end function extras_finish_step


      subroutine extras_after_evolve(id, ierr)
         integer, intent(in) :: id
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         real(dp) :: dt
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         !call test_suite_after_evolve(s, ierr)
      end subroutine extras_after_evolve


      ! returns either keep_going, retry, or terminate.
      integer function extras_check_model(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_check_model = keep_going
      end function extras_check_model


      integer function how_many_extra_history_columns(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         how_many_extra_history_columns = 0
      end function how_many_extra_history_columns


      subroutine data_for_extra_history_columns(id, n, names, vals, ierr)
         integer, intent(in) :: id, n
         character (len=maxlen_history_column_name) :: names(n)
         real(dp) :: vals(n)
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         integer :: i
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
      end subroutine data_for_extra_history_columns


      integer function how_many_extra_profile_columns(id)
         use star_def, only: star_info
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         how_many_extra_profile_columns = 0
      end function how_many_extra_profile_columns


      subroutine data_for_extra_profile_columns(id, n, nz, names, vals, ierr)
         use star_def, only: star_info, maxlen_profile_column_name
         use const_def, only: dp
         integer, intent(in) :: id, n, nz
         character (len=maxlen_profile_column_name) :: names(n)
         real(dp) :: vals(nz,n)
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         integer :: k
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
       end subroutine data_for_extra_profile_columns

      end module run_star_extras
