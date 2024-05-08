FC=gfortran
FFLAGS=
FFLAGSDEBUG=
FDEBUG=-g -Wall -Wextra -fcheck=all -fbacktrace
FOPTIM=-O3


APP=IsingProgram
SRC=$(APP).f90	

MODULEAPP=IsingFunctions
MODULESRC=$(MODULEAPP).f90

FFLAGSDEBUG+=$(FDEBUG)
FFLAGS+=$(FOPTIM)

#LIB=usr/lib/x86_64-linux-gnu/hdf5/serial
#INC1=usr/include/hdf5/serial

#LIB=
#INC1=

#%.o: %.f90
#	$(FC) $(FFLAGS) -o $@ -I/$(INC) -c $<

# build: $(OBJ)
# 	$(FC) $(FFLAGS) -I/$(INC1) -L/$(LIB) -c $(MODULESRC) -lhdf5 -lhdf5_fortran -fopenmp
# 	$(FC) $(FFLAGS) -I/$(INC1) -L/$(LIB) -o $(APP) $(SRC) $(MODULEAPP).o -lhdf5 -lhdf5_fortran -fopenmp

# debug: $(OBJ)
# 	$(FC) $(FFLAGSDEBUG) -I/$(INC1) -L/$(LIB) -c $(MODULESRC) -lhdf5 -lhdf5_fortran -fopenmp
# 	$(FC) $(FFLAGSDEBUG) -I/$(INC1) -L/$(LIB) -o $(APP) $(SRC) $(MODULEAPP).o -lhdf5 -lhdf5_fortran -fopenmp

build: $(OBJ)
	$(FC) $(FFLAGS) -I/$(INC1) -c $(MODULESRC) -fopenmp
	$(FC) $(FFLAGS) -I/$(INC1) -o $(APP) $(SRC) $(MODULEAPP).o

debug: $(OBJ)
	$(FC) $(FFLAGSDEBUG) -I/$(INC1) -c $(MODULESRC) -fopenmp
	$(FC) $(FFLAGSDEBUG) -I/$(INC1) -o $(APP) $(SRC) $(MODULEAPP).o


run:
	make build; ./$(APP)

debugrun:
	make debug; ./$(APP)

cleanrun:
	make cleanall; make run

clean:
	rm -rf $(OBJ)
	rm -rf *.mod
	rm -rf $(APP).x
	rm -rf *.o
	rm -rf ./$(APP)

cleanall:
	rm -rf $(OBJ)
	rm -rf *.mod
	rm -rf $(APP).x
	rm -rf *.o
	rm -rf ./$(APP)
	rm -rf *.h5
