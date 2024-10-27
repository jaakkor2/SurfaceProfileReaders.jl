"""
    readopd(fn)

Read Wyko OPD data set from file `fn`.

# Example

```julia
using WykoOPDReader
fn = joinpath(pathof(WykoOPDReader), "..", "..", "test", "demo.opd")
data = readopd(fn)
```

## Plotting example

Here `heatmap` is used for 2d-plotting, and `surface` is used for 3d-plotting.

```julia
# data to plot
(; x, y, z, colormap, nan_color) = prepplot(data)

using GLMakie
fig = Figure()
ax1 = Axis(fig[1,1], aspect = DataAspect())
hidedecorations!(ax1)
hm = heatmap!(ax1, x, y, z; colormap, nan_color)
hm.inspector_label = (plot, index, position) -> "\$(x[index[1]]) \$(y[index[2]]) \$(position[3])"
ax2 = LScene(fig[1,2], show_axis = false)
sf = surface!(ax2, x, y, z; colormap)
scale!(ax2.scene, 1, 1, 100) # scale z-axis
cb = Colorbar(fig[1,3], hm, height = Relative(3/4), tellheight = true, minorticksvisible = true)
DataInspector()
```
"""
function readopd(fn)
    io = open(fn, "r")
    magic = read(io, 2)
    magic == [0x01, 0x00] || error("not .opd file?")

    entries = []
    data = Dict{String, Any}()
    push!(entries, readentry(io))
    n_entries = entries[1].len ÷ 24
    for i = 2:n_entries
        push!(entries, readentry(io))
    end
    for i = 2:n_entries
        (; name, type, len, dunno) = entries[i]
        if name == ""
            continue
        elseif type == 3
            push!(data, name => readimage(io))
        elseif type == 5
            push!(data, name => readstring(io, len))
        elseif type == 6
            push!(data, name => readint(io, len))
        elseif type in [7,8] # 7=Float32, 8=Float64
            push!(data, name => readfloat(io, len))
        elseif type == 15
            push!(data, name => readtype15(io))
        else
            @show "This is unknown: ", name, type, len, dunno
        end
    end
    close(io)
    data = replaceshortkeys(data)
    return data
end

function readentry(io)
    name = rstrip(String(read(io, 16)), '\0')
    type = reinterpret(UInt16, read(io, 2))[1]
    len = reinterpret(UInt32, read(io, 4))[1]
    dunno = reinterpret(UInt16, read(io, 2))[1]
    (; name, type, len, dunno)
end

function readimage(io)
    width, height, bytewidth = Int.(reinterpret(Int16, read(io, 6)))
    data = read(io, width * height * bytewidth)
    T = bytewidth == 4 ? Float32 : bytewidth == 2 ? Int16 : UInt8
    data = reinterpret(T, data)
    data = reshape(data, (height, width))
    if !(T <: Integer)
        data[data .>= floatmax(T) / 2] .= NaN
    end
    data = rotr90(data, 1)
    data = reverse(data, dims = 2)
end

readstring(io, n) = rstrip(String(read(io, n)), '\0')
readfloat(io, n) = reinterpret(n == 4 ? Float32 : Float64, read(io, n))[1]
readint(io, n) = reinterpret(n == 4 ? Int32 : n == 2 ? Int16 : Int8, read(io, n))[1]

function readtype15(io)
    type = read(io, 1)[1]
    if type == 1 # bool?
        reinterpret(Bool, read(io, 1)[1])
    elseif type == 6
        reinterpret(Int32, read(io, 4))[1]
    elseif type == 10
        reinterpret(Int64, read(io, 8))[1]
    elseif type == 12
        reinterpret(Float32, read(io, 4))[1]
    elseif type == 13
        reinterpret(Float64, read(io, 8))[1]
    elseif type == 14
        len = reinterpret(Int32, read(io, 4))[1]
        s1 = String(read(io, len))
        read(io, 1)
        n = read(io, 1)[1]
        v1 = read(io, n)
        s1, v1
    elseif type == 21 # TimeStamp
        read(io, 1)
        reinterpret(Int64, read(io, 8)) # ANSI Date (64-bit value representing the number of 100-nanosecond intervals since January 1, 1601.)
    elseif type == 66
        len = reinterpret(Int32, read(io, 4))[1]
        s1 = String(read(io, len))
        lenbytes = read(io, 1)[1]
        len_ = reinterpret(lenbytes == 1 ? UInt8 : UInt16, read(io, lenbytes))[1]
        len = reinterpret(Int32, read(io, 4))[1]
        len_ == len + 4 || @warn "Fix something for type 66?"
        s2 = String(read(io, len))
        s1, s2
    else
        lenbytes = read(io, 1)[1]
        len = reinterpret(lenbytes == 1 ? UInt8 : UInt16, read(io, lenbytes))[1]
        if type == 18
            String(read(io, len))
        elseif type == 19
            v = reinterpret(Float64, read(io, 8))[1]
            len1 = reinterpret(Int32, read(io, 4))[1]
            s1 = String(read(io, len1))
            len2 = reinterpret(Int32, read(io, 4))[1]
            s2 = String(read(io, len2))
            sc = reinterpret(Float64, read(io, 8))[1]
            read(io, len - 8 - 4 - len1 - 4 - len2 - 8) # TODO some bytes unprocessed
            v, s1, s2, sc
        elseif type == 125
            res = Dict{String,Any}()
            while true
                len1 = reinterpret(Int32, read(io, 4))[1]
                if len1 == 0
                    read(io, 3)
                    break
                end
                s1 = String(read(io, len1))
                v1 = readtype15(io)
                push!(res, s1 => v1)
            end
            res
        else
            @show "$type unhandled, please add code"
            read(io, len)
        end
    end
end

function replaceshortkeys(data)
    key_short2long = "\xcaxtendedKe\xfds"
    haskey(data, key_short2long) || return data
    map = data[key_short2long]
    Dict((haskey(map, k) ? map[k] : k) => v for (k,v) in data if k != key_short2long)
end