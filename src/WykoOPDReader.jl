"""
    WykoOPDReader

Reader for WYKO OPD data sets (.opd) implemented in Julia.
Exports `readopd` and `prepplot`.
"""
module WykoOPDReader

export readopd, prepplot

include("reader.jl")
include("util.jl")

end
