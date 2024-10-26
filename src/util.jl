"""
    prepplot(data::Dict)

Utility function to create ranges for `x` and `y` from `data` dictionary.
Sets a value for `colormap` and `nan_color`. Returns a tuple `(; x, y, colormap, nan_color)`.
"""
function prepplot(data)
    k = findfirst(x->isa(x, Matrix), data)
    x = range(0, stop = size(data[k], 1))
    y = range(0, stop = size(data[k], 2))
    x = x * data["Pixel_size"] * 1000 # µm
    y = y * data["Pixel_size"] * data["Aspect"] * 1000 # µm
    #colormap = [:NavyBlue, :LightGreen, :Red]
    colormap = :plasma
    nan_color = :black
    return (; x, y, colormap, nan_color)
end
