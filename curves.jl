using Polynomials, CanvasWebIO, Mux
include("grid.jl")

const xrange = (0,1)
const yrange = (0,1)
const width  = 700
const height = 700

canvas = Canvas([height, width], true)

const ls = linspace(0,1,200)

curve(bp) = hcat((x->polyval.(bp, x)).(ls)...)'

scalex(x)  = (x - xrange[1])/(xrange[2] - xrange[1])*width
scaley(y)  = height - (y - yrange[1])/(yrange[2] - yrange[1])*height
rscalex(p) = p/width*(xrange[2] - xrange[1]) + xrange[1]
rscaley(p) = (height - p)/height*(yrange[2] - yrange[1]) + yrange[1]
scale(c)   = [scalex(c[1]), scaley(c[2])]
rscale(c)  = [rscalex(c[1]), rscaley(c[2])]
function coordsvgformat(pts)
    scaledpts = mapslices(scale, pts, 2)
    join((i->join(round.(scaledpts[i,:]), ",")).(1:size(bcurve)[1]), " ")
end

function getpts(canvas)
    hcat((i->rscale(canvas["pt-$i"][])).(1:nctrlpts)...)'
end

ctrlpts = rand(nctrlpts,2)

pts = (i -> dom"svg:circle[id=pt-$i,
                           cx=$(scalex(ctrlpts[i,1])),
                           cy=$(scaley(ctrlpts[i,2])),
                           r=5]"()).(1:size(ctrlpts)[1])

gr = grid(width,height,xrange,yrange)
addstatic!.(canvas, gr)
