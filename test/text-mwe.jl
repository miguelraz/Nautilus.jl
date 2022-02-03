using GLMakie
let 
    f = Figure(backgroundcolor = :gray70);
    passbox = f[1,2] = Axis(f[1,2], title = "Passes")
    #toggle = Toggle(f[1,2], tellheight = false, align = :left)
    #label = Label(f[1,2], lift(x -> x ? "ON TOGGLE " : "OFF TOGGLE", toggle.active), tellheight = false, textsize = 48.0f0, halighn = :right)
    toggle = Toggle(f)
    label = Label(f, lift(x -> x ? "ON TOGGLE" : "OFF TOGGLE", toggle.active), textsize = 48f0)
    f[1,2] = grid!(hcat([toggle], label), tellheight = false)
    textbox = f[1,1] = Axis(f[1,1], title = "Compiled code")
    text!(textbox, "plz")
    f
end

