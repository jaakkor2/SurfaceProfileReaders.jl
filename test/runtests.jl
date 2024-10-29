using SurfaceProfileReaders
using Test

@testset "Wyko OPD" begin
    data = readopd("demo.opd")
    @test data["Pixel_size"] == 0.01f0
    @test data["Aspect"] == 1.5
    @test data["RAW_DATA"] == Float32[
        -3.0  -3.0  -3.0  -3.0
        -2.0   2.0  14.0   1.0
        -1.0   2.0   3.0   2.0
        0.0   2.0   2.0   2.0
        1.0   2.0   2.0   2.0]

    data = readopd("raw_integer.opd")
    @test data["Title"] == "WykoOPDReader.jl"
    @test data["Note"] == "Julia"
    @test data["Mult"] == 32000
    @test data["RAW_DATA"] == Int16[
        0   128
        192   319
       -448  -703]
end
