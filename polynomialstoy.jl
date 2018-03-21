using CanvasWebIO, Polynomials

nroots = 5

function rootsofunity(n::Integer)
    [cos(i*2pi/n)+im*sin(i*2pi/n) for i=0:n-1]
end

function grid(xpts, ypts, xrange, yrange, xres=0.25, yres=0.25)
    thickness = 1
    color     = "grey"
    offsetx   = -10
    offsety   = 10
    origo = true
    scalex(p) = (p-xrange[1])/(xrange[2]-xrange[1])*xpts
    scaley(p) = ypts - (p-yrange[1])/(yrange[2]-yrange[1])*ypts
    svx = ceil(xrange[1]/xres)*xres
    evx = floor(xrange[2]/xres)*xres
    svy = ceil(yrange[1]/yres)*yres
    evy = floor(yrange[2]/yres)*yres
    style = Dict(:stroke=>color, :strokeWidth=>"$thickness")
    styleorigo = Dict(:stroke=>color, :strokeWidth=>"$(2*thickness)")

    linesx = [dom"svg:line[x1=$(scalex(i)),
                           y1=0,
                           x2=$(scalex(i)),
                           y2=$ypts]"(style=style)
                           for i in svx:xres:evx]
    textx_ypos = ypts/2+offsetx
    textx = [dom"svg:text[x=$(scalex(i)),
                          y=$textx_ypos]"("$i")
                          for i in svx:xres:evx]

    linesy = [dom"svg:line[y1=$(scaley(i)),
                           x1=0,
                           y2=$(scaley(i)),
                           x2=$xpts]"(style=style)
                           for i in svy:yres:evy]
    texty_xpos = xpts/2+offsety
    texty = [dom"svg:text[y=$(scaley(i)),
                           x=$texty_xpos]"("$i")
                           for i in svy:yres:evy]

    origos = []
    if origo
        origos = [dom"svg:line[x1=$(scalex(0)),
                               y1=0,
                               x2=$(scalex(0)),
                               y2=$ypts]"(style=styleorigo),
                  dom"svg:line[y1=$(scaley(0)),
                               x1=0,
                               y2=$(scaley(0)),
                               x2=$xpts]"(style=styleorigo)]
    end
    [linesx;textx;linesy;texty;origos]
end

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

function setroots(canvas::Canvas, pol::Polynomials.Poly)
    newv = scale.(roots(pol))
    for i in 1:nroots
        canvas["root-$i"].val = newv[i]
        CanvasWebIO.setindex_(canvas, newv[i], "root-$i")
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

function setcoeffs(canvas::Canvas, pol::Polynomials.Poly)
    newv = scale.(coeffs(pol))
    for i in 1:nroots+1
        canvas["coeff-$i"].val = newv[i]
        CanvasWebIO.setindex_(canvas, newv[i], "coeff-$i")
    end
end
for i in 1:nroots
    on(roots_canvas["root-$i"]) do val
        pol = poly(rscale.([roots_canvas["root-$k"][] for k in 1:nroots]))
        setcoeffs(coeffs_canvas, pol)
    end
end
  
for i in 1:nroots+1
    on(coeffs_canvas["coeff-$i"]) do val
        pol = Poly(rscale.([coeffs_canvas["coeff-$k"][] for k in 1:(nroots+1)]))
        setroots(roots_canvas, pol)
    end
end

style = Dict(:display=>"inline-table", :verticalAlign=>"top", width=>"40%", :marginRight=>"20px")
ux = Node(:div, Node(:div, "Roots:", Node(:br), roots_canvas(), style=style), Node(:div, "Coefficients:", Node(:br), coeffs_canvas(), style=style))

webio_serve(page("/", req->ux))
