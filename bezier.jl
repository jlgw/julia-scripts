const nctrlpts = 7
const maxdeg   = 60

include("curves.jl")

const curvestyle = Dict(:stroke=>"red", :fill=>"none", :strokeWidth=>"2")

bernstein_(v, n) = binomial(n,v)*Poly([0.,1.])^v*Poly([1.,-1.])^(n-v)

const bernrec = (n->bernstein_.(0:n, n)).(0:maxdeg)
bernstein(v,n) = bernrec[n+1][v+1]

bezier(ctrl) = sum([ctrl[i+1,:] .* bernstein(i,size(ctrl)[1]-1) for i in 0:size(ctrl)[1]-1])

poly = bezier(ctrlpts)

bcurve = curve(poly)

line = dom"svg:polyline"(attributes=Dict("id"=>"line", "points"=>coordsvgformat(bcurve)), style=curvestyle)
addstatic!(canvas, line)
addmovable!.(canvas, pts)

function update(c)
    rawpts = getpts(c)
    coordsvgformat(curve(bezier(rawpts)))
end

for i in 1:nctrlpts
    push!(canvas["pt-$i"].listeners,
          (x) -> evaljs(canvas.w, js""" (function() {
                        document.getElementById("line").setAttribute("points", 
                        $(update(canvas)))})()"""
                       )
         )
end

webio_serve(page("/", req->canvas()))
