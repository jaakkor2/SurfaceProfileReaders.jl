# WykoOPDReader

[![Build Status](https://github.com/jaakkor2/WykoOPDReader.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jaakkor2/WykoOPDReader.jl/actions/workflows/CI.yml?query=branch%3Amain)

Reader for Wyko OPD surface profiler datasets (.opd) written in Julia language.  Format seems to be best described in [ReadOPD.m](https://github.com/kranthibalusu/Crystal-plasticity-/blob/master/ProfileAnalysis/ReadOPD.m) by Veeco.

```julia
using WykoOPDReader
data = readopd("profile.opd")
(; x, y, z) = prepplot(data)
```
See `?readopd` for a plotting example.
