module TestAdiff
using Muscade
using Test,StaticArrays

const ∂𝕣11= ∂ℝ{1,1,𝕣}
const ∂𝕣12= ∂ℝ{1,2,𝕣}
const ∂𝕣22= ∂ℝ{2,2,𝕣}

## Constructors and promotion
dx1= ∂ℝ{1,2}(3.,[.1,.2])
dx2= ∂ℝ{1,2}(2.,[.3,.4])
dx3= ∂ℝ{1,2}(4.,[.5,.6])
x  = ∂ℝ{2,2}(dx1,[dx2,dx3])
a  = ∂ℝ{2,2}(dx1,[1,2])
b  = ∂ℝ{2,4}(dx1)
c  = ∂ℝ{2,4}(dx1,3)
t1 = promote_rule(typeof(dx1),typeof(3))
t2 = promote_rule(typeof(dx1),typeof(x))
(d,e)=promote(dx1,7)
(g,h)=promote(dx1,x)

## Extraction
dscaled=δ{1,3,𝕣}([1.,2.,3.])
vscaled=variate{1,3}([4.,4.,4.],[1.,2.,3.])
Δ   = δ{1,2,𝕣}()
C1  = variate{constants(Δ),2}([3.,4.])
C   = variate{constants(C1),2}(C1)
PC  = precedence(C)
PC1 = precedence(C1)
vC  = value{PC}(C)
∂C  = ∂{PC,2}(  C)
vvC = value{PC1}(vC)
v∂C = value{PC1}(∂C)
∂vC = ∂{PC1,2}(    vC)
#∂∂C = ∂{PC1,2}(    ∂C)
dX1 = toggle(false,dx1,3.)

## Operations
oa = variate{1,1}([1.])[1]
ob = variate{constants(oa   ),1}([2.])[1]
oc = variate{constants(oa,ob),1}([3.])[1]
od = oa+oc
oe = od+ob
oj = od^2
og = 2^od
oh = oa^oc
ok = oc*oa/oc
ox = [1.,2.,3.]
oX = variate{1,3}(ox)

## norm
using LinearAlgebra
nrm = norm(oX)

##
@testset "Adiff" begin
    @testset "Adiff construct and promote" begin
        @test dscaled[2] ≗ ∂ℝ{1, 3, Float64}(0.0, [0.0, 2.0, 0.0])
        @test vscaled[2] ≗ ∂ℝ{1, 3, Float64}(4.0, [0.0, 2.0, 0.0])
        @test dx1        ≗ ∂𝕣12(3.0, [0.1, 0.2])
        @test x          ≗ ∂ℝ{2,2,∂𝕣12}(∂𝕣12(3.0, [0.1, 0.2]), [∂𝕣12(2.0, [0.3, 0.4]), ∂𝕣12(4.0, [0.5, 0.6])])
        @test a          ≗ ∂ℝ{2,2,∂𝕣12}(∂𝕣12(3.0, [0.1, 0.2]), [∂𝕣12(1.0, [0.0, 0.0]), ∂𝕣12(2.0, [0.0, 0.0])])
        @test b          ≗ ∂ℝ{2,4,∂𝕣12}(∂𝕣12(3.0, [0.1, 0.2]), [∂𝕣12(0.0, [0.0, 0.0]), ∂𝕣12(0.0, [0.0, 0.0]), ∂𝕣12(0.0, [0.0, 0.0]), ∂𝕣12(0.0, [0.0, 0.0])])
        @test c          ≗ ∂ℝ{2,4,∂𝕣12}(∂𝕣12(3.0, [0.1, 0.2]), [∂𝕣12(0.0, [0.0, 0.0]), ∂𝕣12(0.0, [0.0, 0.0]), ∂𝕣12(1.0, [0.0, 0.0]), ∂𝕣12(0.0, [0.0, 0.0])])
        @test t1         == ∂𝕣12
        @test t2         ==∂ℝ{2,2,∂𝕣12}
        @test d          ≗ dx1
        @test e          ≗ ∂𝕣12(7.0, [0.0, 0.0])
        @test typeof(g) == ∂ℝ{2,2,∂𝕣12}
        @test g         ≗ ∂ℝ{2,2,∂𝕣12}(∂𝕣12(3.0, [0.0, 0.0]), [∂𝕣12(0.1, [0.0, 0.0]), ∂𝕣12(0.2, [0.0, 0.0])])
        @test h          ≗ x
    end

    @testset "Adiff extraction" begin
        @test Δ            ≗ [∂𝕣12(0.0, [1.0, 0.0]),∂𝕣12(0.0, [0.0, 1.0])]
        @test constants(Δ) ≗ 2
        @test typeof(C)    == SVector{2, ∂ℝ{3, 2, ∂ℝ{2, 2, Float64}}}#Array{∂ℝ{3,2,∂𝕣22},1}
        @test C[1]         ≗ ∂ℝ{3,2,∂𝕣22}(∂𝕣22(3.0, SVector(1.0, 0.0)), SVector(∂𝕣22(1.0, [0.0, 0.0]), ∂𝕣22(0.0, [0.0, 0.0])))
        @test vC[1]        ≗ ∂𝕣22(3.0, [1.0, 0.0])
        @test ∂C[1]        ≗ ∂𝕣22(1.0, [0.0, 0.0])
        @test vvC          ≗ [3.0,4.0]
        @test v∂C          ≗ [1.0 0.0;0.0 1.0]
        @test ∂vC          ≗ ∂vC
#        @test ∂∂C          ≗ zeros(2,2,2)   broken=true # extract partial derivatives of an SMatrix or higher order
        @test typeof(dX1)  == ∂𝕣12
    end

    @testset "Adiff operations" begin
        @test oa ≗ ∂𝕣11(1.0, [1.0])
        @test ob ≗ ∂ℝ{2,1,𝕣}(2, [1])
        @test oc ≗ ∂ℝ{3,1,𝕣}(3.0, [1.0])
        @test od ≗ ∂ℝ{3,1,∂𝕣11}(∂𝕣11(4.0, [1.0]), ∂𝕣11[∂𝕣11(1.0, [0.0])])
        @test oe ≗ ∂ℝ{3,1,∂ℝ{2,1,∂𝕣11}}(∂ℝ{2,1,∂𝕣11}(∂𝕣11(6.0, [1.0]), [∂𝕣11(1.0, [0.0])]), ∂ℝ{2,1,∂𝕣11}[∂ℝ{2,1,∂𝕣11}(∂𝕣11(1.0, [0.0]), [∂𝕣11(0.0, [0.0])])])
        @test od ≗ ∂ℝ{3,1,∂𝕣11}(∂𝕣11(4.0, [1.0]), ∂𝕣11[∂𝕣11(1.0, [0.0])])
        @test og ≗ ∂ℝ{3,1,∂𝕣11}(∂𝕣11(16.0, [11.090354888959125]), ∂𝕣11[∂𝕣11(11.090354888959125, [7.687248222691222])])
        @test oj ≗ od*od
        @test og ≗ ∂ℝ{3,1,∂𝕣11}(∂𝕣11(16.0, [11.090354888959125]), ∂𝕣11[∂𝕣11(11.090354888959125, [7.687248222691222])])
        @test ok ≗ ∂ℝ{3,1,∂𝕣11}(∂𝕣11(1.0, [1.0]), [∂𝕣11(0.0, [0.0])])
        @test value{1}(2*oX)==2*ox
    end


    @testset " norm" begin
        @test nrm ≗ sqrt(sum(oX.^2))
    end
end # testset Adiff
end
