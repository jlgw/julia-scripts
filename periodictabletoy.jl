using PeriodicTable, InteractNext, CanvasWebIO

const width  = 700
const height = 400
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
    el = "elmnt"
    for j in 1:length(elements)
        addstatic!(canvas, dom"svg:text[x=$((elements[j].xpos+0.05)*(scale+dist)), 
                      y=$((elements[j].ypos+0.4)*(scale+dist)),
                      id=$(uppercase(elements[j].name)),
                      font-size=$(scale*0.45)]"(elements[j].symbol))
        addclickable!(canvas, dom"svg:rect[width = $scale, height = $scale,
                      x=$(elements[j].xpos*(scale+dist)), 
                      y=$(elements[j].ypos*(scale+dist)),
                      fill=$(color(elements[j].category)),
                      fill-opacity=0.5,
                      id=$(elements[j].name)]"())

    end
    canvas
end
table = make_table()
ui = @manipulate for elementno in 1:length(elements)
    elements[elementno]
end
ui.children[1].dom.props[:style] = Dict()
ui.children[1].dom.props[:style][:display] = "none"

on(table.selection) do val
    observe(elementno)[] = elements[val].number
end
webio_serve(page("/", req->Node(:div, table(), ui)))
