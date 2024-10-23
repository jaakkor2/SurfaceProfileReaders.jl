"""
    readopd(fn)

Read Wyko data set from file `fn`.

# Example

```julia
using WykoOPDReader
fn = joinpath(pathof(WykoOPDReader), "..", "..", "test", "demo.opd")
data = readopd(fn)

using GLMakie
colormap = [:NavyBlue, :royalblue3, :LightGreen, :Red]
nan_color = :black
autolimitaspect = data["Aspect"]
fig = Figure()
ax = Axis(fig[1,1]; autolimitaspect)
hm = heatmap!(ax, data["RAW_DATA"]; colormap, nan_color)
Colorbar(fig[1,2], hm, width = Relative(1/10))
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
        (; name, type, len) = entries[i]
        if name == ""
            continue
        elseif type == 3
            push!(data, name => readimage(io))
        elseif type == 5
            push!(data, name => readstring(io, len))
        elseif entries[i].type == 6
            push!(data, name => readint(io, len))
        elseif entries[i].type == 7
            push!(data, name => readfloat(io, len))
        else
            @show "This is unknown: ", name, type, len
        end
    end
    close(io)
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
