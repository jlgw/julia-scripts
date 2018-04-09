using CanvasWebIO, Polynomials, Mux

include("grid.jl")

xrange = (-2,2)
yrange = (-2,2)
width  = 700
height = 700

scalex(x) = (x-xrange[1])/(xrange[2]-xrange[1])*width
scaley(y) = height - (y-yrange[1])/(yrange[2]-yrange[1])*height

rscalex(p) = p/width*(xrange[2]-xrange[1])+xrange[1]
rscaley(p) = (height-p)/height*(yrange[2]-yrange[1])+yrange[1]

function scale(c)
    [scalex(real(c)), scaley(imag(c))]
end

function rscale(p)
    rscalex(p[1])+im*rscaley(p[2])
end

nroots = 20
rootsl = rootsofunity(nroots)
gr = grid(width,height,xrange,yrange)

roots_canvas = Canvas([height, width], true)

addstatic!.(roots_canvas, gr)

rmarkers = [dom"svg:circle[id=root-$i,
                           cx=$(z[1]),
                           cy=$(z[2]),
                           r=5]"()
                           for (i,z) in enumerate(scale.(rootsl))]
addmovable!.(roots_canvas, rmarkers)

let
    t = time()
    global setroots
    function setroots(canvas::Canvas, pol::Polynomials.Poly, throttle = 0.1)
        tnew = time()
        if tnew-t>throttle
            newv = scale.(roots(pol))
            map(i -> (canvas["root-$i"].val = newv[i]), 1:nroots)
            map(i -> CanvasWebIO.setindex_(canvas, newv[i], "root-$i"), 1:nroots)
            t = tnew
        end
    end
end

coeffs_canvas = Canvas([height, width], true)

addstatic!.(coeffs_canvas, gr)

cmarkers = [dom"svg:circle[id=coeff-$i,
                           cx=$(z[1]),
                           cy=$(z[2]),
                           r=5]"()
                           for (i,z) in enumerate(scale.(coeffs(poly(rootsl))))]

addmovable!.(coeffs_canvas, cmarkers)

let
    t = time()
    global setcoeffs
    function setcoeffs(canvas::Canvas, pol::Polynomials.Poly, throttle = 0.1)
        tnew = time()
        if tnew-t>throttle
            cfs = coeffs(pol)
            newv = scale.(cfs)
            map(i -> (canvas["coeff-$i"].val = newv[i]), 1:nroots+1)
            map(i -> CanvasWebIO.setindex_(canvas, newv[i], "coeff-$i"), 1:nroots+1)
            t = tnew
        end
    end
end
for i in 1:nroots
    push!(roots_canvas["root-$i"].listeners,
          (x) -> (pol = poly(rscale.([roots_canvas["root-$k"][] for k in 1:nroots]));
                  setcoeffs(coeffs_canvas, pol)))
end

for i in 1:nroots+1
    push!(coeffs_canvas["coeff-$i"].listeners,
          (x) -> (pol = Poly(rscale.([coeffs_canvas["coeff-$k"][] for k in 1:(nroots+1)]));
                  setroots(roots_canvas, pol)))
end

style = Dict(:display=>"inline-table", :verticalAlign=>"top", width=>"40%", :marginRight=>"20px")
ux(req) = Node(:div, Node(:div, "Roots:", Node(:br), roots_canvas(), style=style), Node(:div, "Coefficients:", Node(:br), coeffs_canvas(), style=style))

webio_serve(page("/", ux))
