const nctrlpts = 7
const maxdeg   = 60

include("curves.jl")

const curvestyle = Dict(:stroke=>"blue", :fill=>"none", :strokeWidth=>"2")

lagrange(pts, j) = foldl(*, (i->Poly([pts[i],-1])/(pts[j] - pts[i])).([1:j-1;j+1:length(pts)]))
lagrange(pts::Array{T, 1} where T<:Number) = sum((i->pts[i]*lagrange(linspace(0,1,length(pts)), i)).(1:length(pts)))
lagrange(pts::Array{T, 2} where T<:Number) = foldl(+,(i->pts[i,:].*lagrange(linspace(0,1,size(pts)[1]), i)).(1:size(pts)[1]))

poly = lagrange(ctrlpts)

lcurve = curve(poly)

line = dom"svg:polyline"(attributes=Dict("id"=>"line", "points"=>coordsvgformat(lcurve)), style=curvestyle)
addstatic!(canvas, line)
addmovable!.(canvas, pts)

function update(c)
    rawpts = getpts(c)
    coordsvgformat(curve(lagrange(rawpts)))
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
