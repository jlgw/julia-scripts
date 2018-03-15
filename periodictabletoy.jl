using PeriodicTable, InteractNext, Blink

pt = PeriodicTable.PT()
coordinates = [(el.data["xpos"],el.data["ypos"]) for el in pt.data]
const width  = 300
const height = 180
const pad = 5
const scale  = Int(floor(2/3*min((height-pad)/10, (width-pad)/18)))
const dist   = Int(floor(scale/2))


const colors = Dict(
              "diatomic nonmetal"     => "khaki",
              "noble gas"             => "aqua",
              "alkali metal"          => "crimson",
              "alkaline earth metal"  => "orange",
              "metalloid"             => "brown",
              "polyatomic nonmetal"   => "lightgreen",
              "post-transition metal" => "gray",
              "transition metal"      => "salmon",
              "lanthanide"            => "pink",
              "actinide"              => "purple")

function color(i)
    if i in keys(colors)
        return colors[i]
    else
        return "lightgray"
    end
end
function draw_table(pt, i)
    getx(el) = el.data["xpos"]
    gety(el) = el.data["ypos"]
    getcat(el) = el.data["category"]
    elm = pt.data[i]
    dom"svg:svg[height=$height, width=$width]"(
                      dom"svg:rect[width = $(scale+2), height = $(scale+2), 
                      x=$(getx(elm)*(scale+dist)-1), 
                      y=$(gety(elm)*(scale+dist)-1),
                      strokeWidth=3,
                      stroke=black]"(),
                 (dom"svg:rect[width = $scale, height = $scale, 
                      x=$(getx(el)*(scale+dist)), 
                      y=$(gety(el)*(scale+dist)),
                      fill=$(color(getcat(el)))]"()
                      for el in pt.data)...
                     )
end
  
ui = @manipulate for elementno in 1:119
    el = pt.data[elementno].data

    file = replace(el["spectral_img"], "https://en.wikipedia.org/wiki/File:", "")
    #Wikipedia hotlinking api
    imgdomain = "https://en.wikipedia.org/wiki/Special:Redirect/file/$file"

    attr = Dict("src" => imgdomain,
               "width" => "500")
    spectrum_node = Node(:div, Node(:br), "Spectrum:", Node(:br), Node(:img, attributes=attr))

    if el["spectral_img"] == ""
        spectrum_node = Node(:div)
    end

    Node(:div, 
         Node(:br),
         draw_table(pt, elementno),
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
