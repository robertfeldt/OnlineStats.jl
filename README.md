| Build | Test Coverage | Documentation |
|:-----:|:-------------:|:-------------:|
| [![OnlineStats](http://pkg.julialang.org/badges/OnlineStats_0.6.svg)](http://pkg.julialang.org/?pkg=OnlineStats) [![Build Status](https://travis-ci.org/joshday/OnlineStats.jl.svg)](https://travis-ci.org/joshday/OnlineStats.jl) [![Build status](https://ci.appveyor.com/api/projects/status/x2t1ey2sgbmow1a4/branch/master?svg=true)](https://ci.appveyor.com/project/joshday/onlinestats-jl/branch/master) | [![codecov](https://codecov.io/gh/joshday/OnlineStats.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/joshday/OnlineStats.jl) | [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://joshday.github.io/OnlineStats.jl/stable) [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://joshday.github.io/OnlineStats.jl/latest)



# OnlineStats

**Online algorithms for statistics.**

**OnlineStats** is a Julia package which provides online algorithms for statistical models.  Online algorithms are well suited for streaming data or when data is too large to hold in memory.  Observations are processed one at a time and all **algorithms use O(1) memory**.

```julia
using OnlineStats

y = randn(1000)

s = Series(Mean(), Variance())

for yi in y
    fit!(s, yi)
end
```
