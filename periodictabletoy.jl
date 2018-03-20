using PeriodicTable, InteractNext, Blink, CanvasWebIO

const width  = 500
const height = 300
const pad = max(width,height)/15
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
function make_table()
    canvas = Canvas([height,width])
    for j in 1:length(elements)
        addclickable!(canvas, dom"svg:rect[width = $scale, height = $scale,
                      x=$(elements[j].xpos*(scale+dist)), 
                      y=$(elements[j].ypos*(scale+dist)),
                      fill=$(color(elements[j].category)),
                      id=$(elements[j].name)]"())
    end
    canvas
end
table = make_table()
ui = @manipulate for elementno in 1:119
    elements[elementno]
end
on(table.selection) do val
    observe(elementno)[] = elements[val].number
end
w = Window()
body!(w, Node(:div, table(), ui))
