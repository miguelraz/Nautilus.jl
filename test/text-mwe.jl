# Script to test text layout observable updating on toggle.
using GLMakie
let 
    f = Figure(backgroundcolor = :gray70);
    passbox = f[1,2] = Axis(f[1,2], title = "Passes")
    toggle = Toggle(f)
    label = Label(f, lift(x -> x ? "ON TOGGLE" : "OFF TOGGLE", toggle.active), textsize = 48f0)
    f[1,2] = grid!(hcat([toggle], label), tellheight = false)
    textbox = f[1,1] = Axis(f[1,1], title = "Compiled code")
    text!(textbox, lift(x -> x ? "ON TOGGLE" : "OFF TOGGLE", toggle.active))
    f
end

