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
!!! It then saves the following in RSP.dat:
!!! Lab 1 model number, M, L, Teff, RSP Wesenheit index, RSP F/F1 periods,
!!! and RSP F/F1 growth rates
!!! This run_star_extras is designed to append to the file when called from the bonus bash script.

module run_star_extras

      use star_lib
      use star_def
      use const_def
      use math_lib
      use auto_diff

      implicit none

      logical :: need_to_write_LNA_data
      character(len=*), parameter :: lna_output_file = 'RSP.dat'

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
            need_to_write_LNA_data = .true.
         else  ! it is a restart
            need_to_write_LNA_data = .false.
         end if

      end subroutine extras_startup


      integer function extras_start_step(id)
         use colors_def, only: Colors_General_Info, get_colors_ptr
         use colors_lib, only: how_many_colors_history_columns, data_for_colors_history_columns
         integer, intent(in) :: id
         integer :: ierr, io, i
         type (star_info), pointer :: s
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

            call data_for_colors_history_columns(s% photosphere_T, s% photosphere_logg, s% photosphere_r*Rsun, m_div_h, &
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

         if (need_to_write_LNA_data) then
            io = 61
            open(io,file=lna_output_file,status='unknown', position='append')
            write(io, '(i12,8(1x,e20.10))') s% model_number, s% RSP_mass, s% RSP_L, s% RSP_Teff, W_VI, &
               s% rsp_LINA_periods(1)/86400.d0, s% rsp_LINA_growth_rates(1), &
               s% rsp_LINA_periods(2)/86400.d0, s% rsp_LINA_growth_rates(2)
            close(io)
            write(*,*) 'write ' // lna_output_file
            need_to_write_LNA_data = .false.
         end if

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
