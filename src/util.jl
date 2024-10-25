
function prepplot(data)
    k = findfirst(x->isa(x, Matrix), data)
    x = range(0, stop = size(data[k], 1))
    y = range(0, stop = size(data[k], 2))
    x = x * data["Pixel_size"] * 1000 # µm
    y = y * data["Pixel_size"] * data["Aspect"] * 1000 # µm
    colormap = [:NavyBlue, :royalblue3, :LightGreen, :Red]
    nan_color = :black
    return (; x, y, colormap, nan_color)
end
