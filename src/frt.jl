"""
    readfrt(fn)

Read Microprof FRT file
"""
function readfrt(fn)
    io = open(fn, "r")
    magic = String(read(io, 16)) # 
    magic == "FRTM_GLIDERV1.00" || error("Not a Microprof FRT file.")
    blkid1 = read(io, 2)
    data = Dict()

    push!(data, "images" => Dict())
    while true
        twobytes = read(io, 2)
        isempty(twobytes) && break
        blkid = reinterpret(Int16, twobytes)[1] # blkid
        n = reinterpret(Int32, read(io, 4))[1] # number of bytes
        if blkid == 102 # image header
            w, h, nbits = reinterpret(Int32, read(io, n))
            push!(data, blkid => (; w, h, nbits))
        elseif blkid == 11 # preview image
            (; w, h, nbits) = data[102]
            T = integertype(nbits)
            img = reinterpret(T, read(io, n))
            img = reshape(img, (w, h))
            push!(data["images"], "preview" => img)
        elseif blkid == 125
            n_img, dunno = reinterpret(Int32, read(io, 8))
            for i in 1:n_img
                type, w, h, nbits = reinterpret(Int32, read(io, 16))
                T = integertype(nbits)
                len = (nbits ÷ 8)*w*h
                img = reinterpret(T, read(io, len))
                img = reshape(img, (w, h))
                type = type in keys(frt_image_types) ? frt_image_types[type] : type
                push!(data["images"], type => img)
            end
        elseif blkid == 103
            d = read(io, n)
            width, height = reinterpret(Float64, d[1:16])
            unknown = d[17:end]
            push!(data, "xy_dimensions" => (; width, height, unknown))
        elseif blkid == 108
            d = read(io, n)
            scale = reinterpret(Float64, d[5:12])[1]
            unknown = d[1:4]
            push!(data, "z_dimensions" => (; scale, unknown))
        elseif blkid == 114 # time
            t_start, t_stop, dt = reinterpret(Int32, read(io, n))
            t_start = unix2datetime(t_start)
            t_stop = unix2datetime(t_stop)
            push!(data, "timing" => (; dt, t_start, t_stop))
        elseif blkid == 172 # user
            d = read(io, n)
            len = reinterpret(Int32, d[1:4])[1]
            user = String(d[(1:len) .+ 4])
            user = rstrip(user, '\0')
            push!(data, "user" => user)
        else
            haskey(data, blkid) && @error "Id $blkid already read.."
            push!(data, blkid => read(io, n))
        end
    end

    close(io)
    return data
end

const frt_image_types = Dict(0x4 => "height", 0x2 => "intensity", 0x10000002 => "intensity_bottom", 0x10000004 => "height_bottom", 0x20800 => "thickness")

integertype(w::Integer) = w == 8 ? Int8 : w == 16 ? Int16 : w == 32 ? Int32 : w == 64 ? Int64 : throw(ArgumentError("Unsupported byte width"))
