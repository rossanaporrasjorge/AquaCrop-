module ac_interface_inforesults

use, intrinsic :: iso_c_binding, only: c_f_pointer, &
                                       c_loc, &
                                       c_null_char, &
                                       c_ptr

use ac_kinds, only: dp, &
                    intEnum, &
                    int32

use ac_interface_global, only:  pointer2string
use ac_inforesults, only:   StatisticAnalysis, &
                            rep_EventObsSim

implicit none


contains

subroutine StatisticAnalysis_wrap(TypeObsSim, RangeObsMin, RangeObsMax, StrNr_ptr, &
                             strlen, Nobs, ObsAver, SimAver, PearsonCoeff, RMSE, &
                             NRMSE, NScoeff, IndexAg, ArrayObsSim)
    integer(intEnum), intent(in) :: TypeObsSim
    integer(int32), intent(in) :: RangeObsMin
    integer(int32), intent(in) :: RangeObsMax
    type(c_ptr), intent(in) :: StrNr_ptr
    integer(int32), intent(in) :: strlen
    integer(int32), intent(inout) :: Nobs
    real(dp), intent(inout) :: ObsAver
    real(dp), intent(inout) :: SimAver
    real(dp), intent(inout) :: PearsonCoeff
    real(dp), intent(inout) :: RMSE
    real(dp), intent(inout) :: NRMSE
    real(dp), intent(inout) :: NScoeff
    real(dp), intent(inout) :: IndexAg
    type(rep_EventObsSim), dimension(100), intent(inout) :: ArrayObsSim

    character(len=strlen) :: string

    string = pointer2string(StrNr_ptr, strlen)
    call StatisticAnalysis(TypeObsSim, RangeObsMin, RangeObsMax, string, &
                           Nobs, ObsAver, SimAver, PearsonCoeff, RMSE, &
                           NRMSE, NScoeff, IndexAg, ArrayObsSim)
end subroutine StatisticAnalysis_wrap

    

end module ac_interface_inforesults
