using Polynomials, CanvasWebIO, Mux

include("grid.jl")
const nctrlpts = 10
const maxdeg   = 60

const curvestyle = Dict(:stroke=>"red", :fill=>"none", :strokeWidth=>"2")
const xrange = (0,1)
const yrange = (0,1)
const width  = 700
const height = 700

canvas = Canvas([height, width], true)

const ls = linspace(0,1,100)

bernstein_(v, n) = binomial(n,v)*Poly([0.,1.])^v*Poly([1.,-1.])^(n-v)

const bernrec = (n->bernstein_.(0:n, n)).(0:maxdeg)
bernstein(v,n) = bernrec[n+1][v+1]
bezier(ctrl) = sum([ctrl[i+1,:] .* bernstein(i,size(ctrl)[1]-1) for i in 0:size(ctrl)[1]-1])

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

ctrlpts = rand(nctrlpts,2)
bpoly = bezier(ctrlpts)

bcurve = curve(bpoly)

pts = (i -> dom"svg:circle[id=pt-$i,
                           cx=$(scalex(ctrlpts[i,1])),
                           cy=$(scaley(ctrlpts[i,2])),
                           r=5]"()).(1:size(ctrlpts)[1])

line = dom"svg:polyline"(attributes=Dict("id"=>"line", "points"=>coordsvgformat(bcurve)), style=curvestyle)
gr = grid(width,height,xrange,yrange)
addmovable!.(canvas, pts)
addstatic!.(canvas, line)
addstatic!.(canvas, gr)

function getpts(canvas)
    hcat((i->rscale(canvas["pt-$i"][])).(1:nctrlpts)...)'
end

for i in 1:nctrlpts
    function update(c)
        rawpts = getpts(c)
        coordsvgformat(curve(bezier(rawpts)))
    end
    push!(canvas["pt-$i"].listeners,
          (x) -> evaljs(canvas.w, js""" (function() {
                        document.getElementById("line").setAttribute("points", 
                        $(update(canvas)))})()"""
                       )
         )
end

webio_serve(page("/", req->canvas()))
