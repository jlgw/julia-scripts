using CanvasWebIO, WebIO, Observables, Mux

global running = true

iv         = [50.0, 0.0]
t          = 0.02
ballr      = 10
width      = 800
height     = 800
acc        = 10.0
batwidth   = 150
batheight  = 20
timeout    = 0.2
bounciness = 0.90

field = Canvas([width, height],true)

ball = dom"svg:circle[id=ball,
                  cx=400.0,
                  cy=100.0,
                  r=$ballr]"(style=Dict(:fill=>"blue"))

bat = dom"svg:rect[id=bat,
               x=50,
               y=50,
               width=$batwidth,
               height=$batheight]"(style=Dict(:fill=>"black"))

ballv = Observable(field.w, "ballv", iv)
batv = Observable(field.w, "batv", [0.0, 0.0])
batlast = [0.0,0.0]
bounce = Observable(time())
@async while running
    sleep(t)
    if (ballv[][1]<0 && field["ball"][][1]<ballr) || (ballv[][1]>0 && field["ball"][][1]>width-ballr)
        ballv[] = [-bounciness*ballv[][1], ballv[][2]]
    end
    if (ballv[][2]<0 && field["ball"][][2]<ballr) || (ballv[][2]>0 && field["ball"][][2]>height-ballr)
        ballv[] = [ballv[][1], -bounciness*ballv[][2]]
    end
    batv[] = (field["bat"][]-batlast)/t
    batlast .= field["bat"][]
    disty = field["ball"][][2]-field["bat"][][2]-batheight/2
    distx = field["ball"][][1]-field["bat"][][1]-batwidth/2
    if abs(distx)<batwidth/2 && abs(disty)<batheight/2+abs(1*t*ballv[][2]-1*t*batv[][2])
        if sign(ballv[][2])!=sign(disty) && (time()-bounce[])>timeout
            bounce[] = time()
            ballv[] = [ballv[][1], -0.6*ballv[][2]]+0.5*batv[]
        else
            ballv[] = ballv[]+0.2*batv[]
        end
    end
    field["ball"] = field["ball"][] + ballv[]*t
    ballv[] = ballv[] + [0.0, acc]
end

addmovable!(field, ball)
addmovable!(field, bat)

webio_serve(page("/", req->field()))
