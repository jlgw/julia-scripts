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
