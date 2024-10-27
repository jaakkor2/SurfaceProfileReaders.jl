"""
    prepplot(data::Dict)

Utility function to create ranges for `x` and `y` from `data` dictionary. Scaled measured data `z`.  All in µm units.
Sets a value for `colormap` and `nan_color`. Returns a tuple `(; x, y, z, colormap, nan_color)`.
"""
function prepplot(data)
    k = findfirst(x->isa(x, Matrix), data)
    x = range(0, stop = size(data[k], 1))
    y = range(0, stop = size(data[k], 2))
    x = x * data["Pixel_size"] * 1000 # µm
    y = y * data["Pixel_size"] * data["Aspect"] * 1000 # µm

    if haskey(data, "PrimaryData2D")
        z = data[data["PrimaryData2D"]]
    else
        rawkeys = intersect(keys(data), ["RAW_DATA", "Raw", "SAMPLE_DATA", "OPD"])
        isempty(rawkeys) && error("No raw data found.")
        z = data[first(rawkeys)]
    end
    # scaling
    z *= haskey(data, "Wavelength") ? data["Wavelength"] / 1000 : 1.0
    z /= haskey(data, "Mult") ? data["Mult"] : 1.0

    #colormap = [:NavyBlue, :LightGreen, :Red]
    colormap = :plasma
    nan_color = :black
    return (; x, y, z, colormap, nan_color)
end
