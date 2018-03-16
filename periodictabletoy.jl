using PeriodicTable, InteractNext, Blink

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
function draw_table(i)
    dom"svg:svg[height=$height, width=$width]"(
                      dom"svg:rect[width = $(scale+2), height = $(scale+2), 
                      x=$(elements[i].xpos*(scale+dist)-1), 
                      y=$(elements[i].ypos*(scale+dist)-1),
                      strokeWidth=3,
                      stroke=black]"(),
                 (dom"svg:rect[width = $scale, height = $scale, 
                  x=$(elements[j].xpos*(scale+dist)), 
                  y=$(elements[j].ypos*(scale+dist)),
                  fill=$(color(elements[j].category))]"()
                  for j in 1:length(elements))...
                     )
end
  
ui = @manipulate for elementno in 1:119
    Node(:div, 
         draw_table(elementno),
         elements[elementno]
        )
end

w = Window()
body!(w, ui)
