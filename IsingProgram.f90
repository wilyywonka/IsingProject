
program SolveMonteCarlo
  use IsingFunctions
  use IsingParameters
  implicit none


  integer :: iteratorT, iteratorEvals, iteratorEnsembles
  integer :: EvalsPerEnsemble = 100, NumEnsembles = 100, NumT = 2

  integer, dimension(2) :: CurrentSpinsXY

  real :: randomEval, ExponentialChance

  ! Setting parameters
  type(param_t) :: Parameters

  integer :: SpinSizeX = 10, SpinSizeY = 10
  
  real :: MaximumTemp = 50, JSet = -10


  call Initialize(Parameters,NumT,SpinSizeX,SpinSizeY,MaximumTemp,JSet)


  do iteratorT = 1, NumT
    ! Add temperature to the list of temperatures
    call AddTemperature(Parameters)
    ! Start iteration over ensembles
    Parameters%EnsembleCounter = 1
    do iteratorEnsembles = 1, NumEnsembles
      ! Start iterations over evaluations for each ensemble
      do iteratorEvals = 1, EvalsPerEnsemble
        ! Select spins at random
        CurrentSpinsXY = ChooseRandomSpin(Parameters)
        ! Calculate the energy in the configuration where the selected spin is flipped
        call CalculateEnergyShift(Parameters, CurrentSpinsXY(1),CurrentSpinsXY(2))
        ! Calculate the chance of this flip happenning
        ExponentialChance = CalculateChance(Parameters)
       ! print*, ExponentialChance
        ! Draw a random number
        call random_number(randomEval)
        !print*,CurrentSpinsXY
        ! Check if this
       ! print*,ExponentialChance 
        if (randomEval<ExponentialChance) then
          print*, randomEval, ExponentialChance, Parameters%OldEnergy, Parameters%NewEnergy
          call spinFlip(Parameters, CurrentSpinsXY(1), CurrentSpinsXY(2))
      
        end if
      
      end do
      call AddMeasurement(Parameters)
    end do

    ! Increment IntT from 0 to NumT-1
    call incrementT(Parameters)
    ! Scramble the spins so as to start with a random
    print*, Parameters%SpinArray
    !call spinScrambler(Parameters)
  end do

  print*, Parameters%MagnetizationArray

end program SolveMonteCarlo