using Plots

function Isingsimulation(T, N, M; iterations=10000, eqPoint=5000)
    k::Float64 = 1.381e-23
    J::Float64 = 1.60218e-21
    β::Float64 = J/k
    μ::Float64 = -β/T
   
    println(β)

    Lattice = Spinscrambler(N,M)

    CurrentH::Float64 = 0
    NewH::Float64 = 0

    SValue::Float64 = 0
    Sdivisor = 1/(iterations-eqPoint)

    for iterator in 1:iterations
        Latticesite = LatticePoint(N,M)

        CurrentH = H(Lattice,N,M,Latticesite[1],Latticesite[2])

        Lattice = Spinflipper(Lattice, Latticesite[1], Latticesite[2])

#        NewH = HTotal(Lattice,N,M)
        NewH = H(Lattice,N,M,Latticesite[1],Latticesite[2])

        if NewH < CurrentH
            #Flip is accepted, energy is updated
            CurrentH = NewH
        elseif  rand() < exp(μ*(NewH - CurrentH))
            #Flip is accepted, energy is updated
            CurrentH = NewH
        else
            #Flipping back
            Lattice = Spinflipper(Lattice, Latticesite[1], Latticesite[2])            
        end
        if iterator > eqPoint
            SValue += S(Lattice,N,M)*Sdivisor
        end
    end
    return Lattice, SValue
end

function Spinflipper(Lattice,i,j)
   Lattice[i,j] = -Lattice[i,j]
   return Lattice
end
function LatticePoint(N,M)
   i = rand(1:N)
   j = rand(1:M)
   Indexes = [i,j]
   return Indexes
end

function Spinscrambler(N,M)
   Lattice::Matrix{Float64} = zeros(N,M)
   for i in 1:N
       for j in 1:M        
           Lattice[i,j] = rand([-1,1])
       end
   end
   return Lattice
end

function H(Lattice,N,M,i,j)
    sum::Float64 = 0
    if i == 1
        sum += Lattice[i,j]*Lattice[N,j]
#               LatticeTest[N,j] += 1
    else
        sum += Lattice[i,j]*Lattice[i-1,j]
#               LatticeTest[i-1,j] += 1
    end

    if i == N
        sum += Lattice[i,j]*Lattice[1,j]
#               LatticeTest[1,j] += 1
    else
        sum += Lattice[i,j]*Lattice[i+1,j]
#               LatticeTest[i+1,j] += 1
    end

    if j == 1
        sum += Lattice[i,j]*Lattice[i,M]
#               LatticeTest[i,M] += 1
    else
        sum += Lattice[i,j]*Lattice[i,j-1]
#               LatticeTest[i,j-1] += 1
    end

    if j == M
        sum += Lattice[i,j]*Lattice[i,1]
#                LatticeTest[i,1] += 1
    else
        sum += Lattice[i,j]*Lattice[i,j+1]
#               LatticeTest[i,j+1] += 1
    end
    return -sum #, LatticeTest
 end

function HTotal(Lattice,N,M)
   sum::Float64 = 0
   for i in 1:N
       for j in 1:M

           if i == 1
               sum += Lattice[i,j]*Lattice[N,j]
#               LatticeTest[N,j] += 1
           else
               sum += Lattice[i,j]*Lattice[i-1,j]
#               LatticeTest[i-1,j] += 1
           end

           if i == N
               sum += Lattice[i,j]*Lattice[1,j]
#               LatticeTest[1,j] += 1
           else
               sum += Lattice[i,j]*Lattice[i+1,j]
#               LatticeTest[i+1,j] += 1
           end

           if j == 1
               sum += Lattice[i,j]*Lattice[i,M]
#               LatticeTest[i,M] += 1
           else
               sum += Lattice[i,j]*Lattice[i,j-1]
#               LatticeTest[i,j-1] += 1
           end

           if j == M
               sum += Lattice[i,j]*Lattice[i,1]
#                LatticeTest[i,1] += 1
           else
               sum += Lattice[i,j]*Lattice[i,j+1]
#               LatticeTest[i,j+1] += 1
           end

       end 
   end
   return -sum/2 #, LatticeTest
end

function S(Lattice, N, M)
   OP::Float64 = 0
   for i in 1:N
       for j in 1:M
           OP += Lattice[i,j]
       end
   end
   return abs(OP/(N*M))
end


#LatticeTest::Matrix{Float64} = zeros(10,10)
#a,b = 1,3
#Lattice::Matrix{Float64} = ones(10,10)

#Lattice[a,b] = -1


#Lattice[2,3] = -1
#sumResult, TestLattice = H(Lattice,LatticeTest,100,100)
#println(sumResult)

rand([-1,1],10,10)

L = 200

Results = zeros(L)
TempList = LinRange(0.0001,120,L)
#reslat,sval = Isingsimulation(Results[1],1,20,20,iterations = 1000000,eqPoint = 700000)

N,M = 70,70

"""
Threads.@threads for i in 1:L
    reslat,sval = Isingsimulation(TempList[i],N,M,iterations = 500000,eqPoint = 450000)
    Results[i] = sval
end
"""

reslat,sval = Isingsimulation(TempList[1],N,M,iterations = 5000,eqPoint = 4500)

#plot(Results)

heatmap(reslat)



#Test med store matriser
#Test LatticePoint at den ikke er biased
a,b = 100,100
RandomLattice = zeros(a,b)

for i in 1:1000000
   Randomidx = LatticePoint(a,b)
   RandomLattice[Randomidx[1],Randomidx[2]] += 1
end
heatmap(RandomLattice)