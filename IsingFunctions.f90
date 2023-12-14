module IsingParameters
  implicit none
  type :: param_t
    integer     :: IntT, EnsembleCounter, numTemps, numSpinX, numSpinY

    real        :: T, dT, OldEnergy, NewEnergy, J, maxT, TotalMagnetization, kB

    real, allocatable :: MagnetizationArray(:), TemperatureArray(:)
    
    integer, allocatable :: SpinArray(:,:)

  end type param_t

  contains

  subroutine Initialize(Parameters,numTempsSet, numSpinXSet, numSpinYSet, maxTSet, JSet)
    implicit none
    integer, intent(in) :: numTempsSet, numSpinXSet, numSpinYSet
    real, intent(in) :: maxTSet, JSet
    type(param_t), intent(inout) :: Parameters

    integer :: iterator1

    Parameters%numTemps = numTempsSet
    Parameters%numSpinX = numSpinXSet
    Parameters%numSpinY = numSpinYSet

    allocate(Parameters%MagnetizationArray(numTempsSet))
    allocate(Parameters%TemperatureArray(numTempsSet))

    allocate(Parameters%SpinArray(numSpinXSet,numSpinYSet))

    

    ! Starting the magnetizationarray at all 0's
    do iterator1 = 1, numTempsSet
      Parameters%MagnetizationArray(iterator1) = 0
    end do

    call spinScrambler(Parameters)

    ! ---

    Parameters%maxT = maxTSet

    Parameters%IntT = 0

    Parameters%dT = Parameters%maxT / (numTempsSet-1)

    Parameters%T = Parameters%dT * Parameters%IntT

    Parameters%EnsembleCounter = 1

    Parameters%J = -JSet

    Parameters%TotalMagnetization = 0

    Parameters%kB = 1
    
    ! ---


  end subroutine Initialize

  subroutine spinScrambler(Parameters)
    implicit none
    type(param_t), intent(inout) :: Parameters
    ! Start with a completely ordered system
    real, dimension(Parameters%numSpinX, Parameters%numSpinY) :: randomArray
    integer :: iterator1, iterator2

    call random_number(randomArray)

    do iterator1 = 1, Parameters%numSpinX
      do iterator2 = 1, Parameters%numSpinY
        if (randomArray(iterator1,iterator2)<0.5) then
          Parameters%SpinArray(iterator1,iterator2) = -1
        else
          Parameters%SpinArray(iterator1,iterator2) = 1
        end if
      end do 
    end do

  end subroutine spinScrambler
end module IsingParameters




module IsingFunctions
  use IsingParameters
  implicit none

  contains
  
  subroutine spinFlip(Parameters,spinX,spinY)
    implicit none
    type(param_t), intent(inout) :: Parameters
    integer, intent(in) :: spinX, spinY

    Parameters%SpinArray(spinX,spinY) = Parameters%SpinArray(spinX,spinY)*(-1)

  end subroutine spinFlip

  function CalculateEnergySingle(Parameters, spinX, spinY) result(Energy)
    implicit none
    type(param_t), intent(inout) :: Parameters
    integer, intent(in) :: spinX, spinY

    integer :: coordinate

    real :: Energy
    
    ! Negative X    
    if (spinX /= 1) then
      coordinate = spinX-1
    else
      coordinate = Parameters%numSpinX
    end if
    Energy = Energy + Parameters%J*Parameters%SpinArray(spinX,spinY)*Parameters%SpinArray(coordinate,spinY)
    
    ! Positive X
    if (spinX /= Parameters%numSpinX) then
      coordinate = spinX+1
    else
      coordinate = 1
    end if
    Energy = Energy + Parameters%J*Parameters%SpinArray(spinX,spinY)*Parameters%SpinArray(coordinate,spinY)
    
    ! Negative Y
    if (spinY /= 1) then
      coordinate = spinY-1
    else
      coordinate = Parameters%numSpinY
    end if
    Energy = Energy + Parameters%J*Parameters%SpinArray(spinX,spinY)*Parameters%SpinArray(spinX,coordinate)
    
    ! Positive Y
    if (spinY /= Parameters%numSpinY) then
      coordinate = spinY+1
    else
      coordinate = 1
    end if
    Energy = Energy + Parameters%J*Parameters%SpinArray(spinX,spinY)*Parameters%SpinArray(spinX,coordinate)
  
  end function CalculateEnergySingle

  subroutine CalculateEnergyShift(Parameters, spinX, spinY)
    implicit none
    type(param_t), intent(inout) :: Parameters
    integer,intent(in) :: spinX, spinY

    Parameters%OldEnergy = 0
    Parameters%NewEnergy = 0

    ! Calculate the energy as is
    Parameters%OldEnergy = CalculateEnergySingle(Parameters,spinX,spinY)

    ! Flip spin to calculate the flipped energy
    call spinFlip(Parameters, spinX, spinY)

    ! Calculate the flipped energy
    Parameters%NewEnergy = CalculateEnergySingle(Parameters,spinX,spinY)

    ! Flip back spin
    call spinFlip(Parameters, spinX, spinY)
   ! print*, Parameters%OldEnergy, Parameters%NewEnergy
  end subroutine CalculateEnergyShift

  subroutine CalculateTotalMagnetization(Parameters)
    implicit none
    type(param_t), intent(inout) :: Parameters
    integer :: IteratorSpinX, IteratorSpinY

    Parameters%TotalMagnetization = 0

    do IteratorSpinX = 1, Parameters%numSpinX
      do IteratorSpinY = 1, Parameters%numSpinY
        Parameters%TotalMagnetization = Parameters%TotalMagnetization + Parameters%SpinArray(IteratorSpinX,IteratorSpinY)
      end do
    end do
    print*, Parameters%TotalMagnetization, "should be in range", Parameters%numSpinX*Parameters%numSpinY
    Parameters%TotalMagnetization = Parameters%TotalMagnetization/(Parameters%numSpinX*Parameters%numSpinY)
!    print*, Parameters%TotalMagnetization


  end subroutine CalculateTotalMagnetization

  subroutine AddMeasurement(Parameters)
    implicit none
    type(param_t), intent(inout) :: Parameters

    call CalculateTotalMagnetization(Parameters)

    Parameters%MagnetizationArray(Parameters%IntT) = Parameters%MagnetizationArray(Parameters%IntT)&
    *((Parameters%EnsembleCounter-1)/Parameters%EnsembleCounter) + Parameters%TotalMagnetization*(1.0/Parameters%EnsembleCounter)

    !print*, Parameters%TotalMagnetization, Parameters%MagnetizationArray(Parameters%IntT), &
    ! Parameters%TotalMagnetization*(1/Parameters%EnsembleCounter), (1.0/Parameters%EnsembleCounter), Parameters%EnsembleCounter

    Parameters%EnsembleCounter = Parameters%EnsembleCounter + 1
    

  end subroutine AddMeasurement

  subroutine incrementT(Parameters)
    implicit none
    type(param_t), intent(inout) :: Parameters
  
    Parameters%IntT = Parameters%IntT + 1

    Parameters%T = Parameters%IntT*Parameters%dT
      
  end subroutine incrementT

  subroutine AddTemperature(Parameters)
    implicit none
    type(param_t), intent(inout) :: Parameters

    Parameters%TemperatureArray(Parameters%IntT) = Parameters%T

  end subroutine AddTemperature

  function ChooseRandomSpin(Parameters) result(spinXY)
    implicit none
    type(param_t), intent(inout) :: Parameters

    real :: randomX, randomY

    integer, dimension(2) :: spinXY

    call random_number(randomX)
    call random_number(randomY)

    spinXY(1) = 1 + floor((Parameters%numSpinX-1)*randomX)
    spinXY(2) = 1 + floor((Parameters%numSpinY-1)*randomY)

  end function

  function CalculateChance(Parameters) result(chance)
    implicit none
    type(param_t), intent(inout) :: Parameters

    real :: chance

    if (Parameters%NewEnergy<Parameters%OldEnergy) then
      chance = 1
    else if (Parameters%T == 0) then
      chance = 0
    else
      chance = exp(-(Parameters%NewEnergy-Parameters%OldEnergy)/(Parameters%T*Parameters%kB))
    end if

  end function

end module IsingFunctions

