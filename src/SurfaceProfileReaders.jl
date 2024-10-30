"""
    SurfaceProfileReaders

Readers for surface profiler data sets implemented in Julia.

* Wyko OPD `readopd`
* MicroProf FRT `readfrt`
"""
module SurfaceProfileReaders

using Dates: unix2datetime

export readopd, opdprepplot
export readfrt

include("opd.jl")
include("frt.jl")

end
