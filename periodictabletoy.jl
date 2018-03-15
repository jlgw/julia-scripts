using PeriodicTable, InteractNext, Blink

pt = PeriodicTable.PT()
ui = @manipulate for elementno in 1:119
    el = pt.data[elementno].data

    file = replace(el["spectral_img"], "https://en.wikipedia.org/wiki/File:", "")
    #Wikipedia hotlinking api
    imgdomain = "https://en.wikipedia.org/wiki/Special:Redirect/file/$file"

    attr = Dict("src" => imgdomain)
    spectrum_node = Node(:div, Node(:br), "Spectrum:", Node(:br), Node(:img, attributes=attr))

    if el["spectral_img"] == ""
        spectrum_node = Node(:div)
    end

    Node(:div, 
         Node(:br),
         Node(:div, "$(el["name"]), $(el["symbol"])"),
         Node(:div, "$(el["category"])"),
         Node(:br),
         Node(:div, "Summary: $(el["summary"])"),
         Node(:br),
         Node(:div, "Atomic mass: $(el["atomic_mass"])"),
         Node(:div, "Density: $(el["density"]) g/cm³"),
         Node(:div, "Melting point: $(el["melt"])°C"),
         Node(:div, "Boiling point: $(el["boil"])°C"),
         spectrum_node
    
        )
end


w = Window()
body!(w, ui)
