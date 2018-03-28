using CanvasWebIO, WebIO, Observables, Mux

global running = true
gf = 2500000.0
t = 0.02
iv = [80.0, 0.0]
chart = Canvas([800,800],true)
sun = dom"svg:circle[id=sun,
                     cx=400.0,
                     cy=400.0,
                     r=50]"(style=Dict(:fill=>"yellow"))

planet1 = dom"svg:circle[id=planet1,
                        cx=400.0,
                        cy=100.0,
                        r=7]"(style=Dict(:fill=>"blue"))
planet2 = dom"svg:circle[id=planet2,
                        cx=450.0,
                        cy=100.0,
                        r=7]"(style=Dict(:fill=>"green"))

velocity1 = Observable(chart.w, "velocity1", iv)
velocity2 = Observable(chart.w, "velocity2", iv)

addmovable!(chart, sun)
addmovable!(chart, planet1)
addmovable!(chart, planet2)

@async while running
    sleep(t)
    distv1 = chart["planet1"][]-chart["sun"][]
    nrm1 = norm(distv1)
    dir1 = distv1/nrm1
    distv2 = chart["planet2"][]-chart["sun"][]
    nrm2 = norm(distv2)
    dir2 = distv2/nrm2
    velocity1[] = velocity1[] - dir1*gf/(nrm1^2)*t
    velocity2[] = velocity2[] - dir2*gf/(nrm2^2)*t
    chart["planet1"] = chart["planet1"][] + t*velocity1[]
    chart["planet2"] = chart["planet2"][] + t*velocity2[]
end

function responder(req)
    @async (chart["planet1"] = [400.0,100.0])
    @async (chart["planet2"] = [450.0,100.0])
    @async (velocity1[] = iv)
    @async (velocity2[] = iv)
    chart()
end

webio_serve(page("/", responder))
