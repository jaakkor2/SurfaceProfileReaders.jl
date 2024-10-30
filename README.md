# SurfaceProfileReaders

[![Build Status](https://github.com/jaakkor2/SurfaceProfileReaders.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jaakkor2/SurfaceProfileReaders.jl/actions/workflows/CI.yml?query=branch%3Amain)

Reader for surface profiler data sets written in Julia language. Implemented formats
* Wyko OPD
* MicroProf FRT

```julia
using SurfaceProfileReaders
data = readopd("profile.opd")
(; x, y, z) = opdprepplot(data)
```
See `?readopd` for a plotting example.
