using CanvasWebIO, WebIO, Observables, Mux

#testing number of objects/latency with "static" objects (no connected observables)

global running = true
width    = 800
height   = 800
t        = 0.2
ballr    = 5
acc      = 10.0
balln    = 1000
movement = 10

color() = string("rgb(", join(Int.(floor.(rand(3)*256)), ","), ")")

canvas = Canvas([width,height], true)

ballpos = ([width,height].*reshape(rand(balln*2), (2,balln)))'
balls = [dom"svg:circle[id=ball-$i,
                        cx=$(ballpos[i, 1]),
                        cy=$(ballpos[i, 2]),
                        r=$ballr]"(style=Dict(:fill=>color())) for i in 1:balln]

addstatic!.(canvas, balls)

function move()
    ballpos .= (ballpos+movement).%[width,height]'
    (i->CanvasWebIO.setindex_(canvas, ballpos[i,:], "ball-$i")).(1:balln)
end

@async while running
    move()
    sleep(t)
end
