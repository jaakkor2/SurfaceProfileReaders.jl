# WykoOPDReader

[![Build Status](https://github.com/jaakkor2/WykoOPDReader.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jaakkor2/WykoOPDReader.jl/actions/workflows/CI.yml?query=branch%3Amain)

Reader for Wyko profilometer datasets (.opd) written in Julia language.

```julia
using WykoOPDReader
data = readopd("profile.opd")
```
