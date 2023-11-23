
program main
  use IsingFunctions
  use IsingParameters
  implicit none


  integer :: iteratorT, iteratorEvals, iteratorEnsembles
  integer :: EvalsPerEnsemble, NumEnsembles, NumT

  integer, dimension(2) :: CurrentSpinsXY

  real :: randomEval, ExponentialChance

  ! Setting parameters
  type(param_t) :: Parameters

  integer :: SpinSizeX = 10, SpinSizeY = 10
  
  real :: MaximumTemp = 50, JSet = 2*1.38e-23



  call Initialize(Parameters,NumT,SpinSizeX,SpinSizeY,MaximumTemp,JSet)


  do iteratorT = 1, NumT
    ! Add temperature to the list of temperatures
    call AddTemperature(Parameters)
    ! Start iteration over ensembles
    do iteratorEnsembles = 1, NumEnsembles
      ! Start iterations over evaluations for each ensemble
      do iteratorEvals = 1, EvalsPerEnsemble
        ! Select spins at random
        CurrentSpinsXY = ChooseRandomSpin(Parameters)
        ! Calculate the energy in the configuration where the selected spin is flipped
        call CalculateEnergyShift(Parameters, CurrentSpinsXY(1),CurrentSpinsXY(2))
        ! Calculate the chance of this flip happenning
        ExponentialChance = CalculateChance(Parameters)
        ! Draw a random number
        call random_number(randomEval)
        ! Check if this 
        if (randomEval<ExponentialChance) then
      
          call spinFlip(Parameters, CurrentSpinsXY(1), CurrentSpinsXY(2))
      
        end if
      
      end do
      call AddMeasurement(Parameters)
    end do

    ! Increment IntT from 0 to NumT-1
    call incrementT(Parameters)
    ! Scramble the spins so as to start with a random
    call spinScrambler(Parameters)
  end do


end program main