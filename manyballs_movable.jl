using CanvasWebIO, WebIO, Observables, Mux

#testing number of objects/latency with movable objects (connected observables)

global running = true
width    = 800
height   = 800
t        = 0.2
ballr    = 5
acc      = 10.0
balln    = 1000
movement = 10

canvas = Canvas([width,height], true)
color() = string("rgb(", join(Int.(floor.(rand(3)*256)), ","), ")")

balls = [dom"svg:circle[id=ball-$i,
                        cx=$(rand()*width),
                        cy=$(rand()*height),
                        r=$ballr]"(style=Dict(:fill=>color())) for i in 1:balln]

addmovable!.(canvas, balls)

function move(i)
    canvas["ball-$i"] = (canvas["ball-$i"][]+10).%([width,height])
end

@async while running
    [move(i) for i in 1:balln]
    sleep(t)
end
