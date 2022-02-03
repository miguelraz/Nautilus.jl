# Script to test text layout observable updating on a toggle vector.
# Problem:
# I have a vector of 2 passes, 2 toggles and 2 labels, and upon toggling,
# I want for a function that depends on the internal values of 
# `passes` to recompute a function and paint that text.
# Solution:
# Make each pass an observable, so that the toggles/labels work,
# but also make the vector of observable passes an observable,
# so that painting the text is only done once.
mutable struct Pass
    checked :: Bool
    pass :: String
end
using GLMakie
    #passes = [
    #          (;checked = true, pass = "pass 1"),
    #          (;checked = true, pass = "pass 2")
    #         ]
    passes = [Pass(true, "pass 1"), Pass(true, "pass 2")]
    obs_passes = Observable.(passes)
    vector_obs_passes = Observable(obs_passes)
    f = Figure(backgroundcolor = :gray70);
    passbox = f[1,2] = Axis(f[1,2], title = "Passes")
    toggles = [Toggle(f), Toggle(f)]
    labels = [Label(f, lift(x -> x ? "ON $(obs_passes[i][].pass)" : "OFF $(obs_passes[i][].pass)", toggles[i].active), textsize = 48f0) for i in 1:2]
    f[1,2] = grid!(hcat(toggles, labels), tellheight = false)
    textbox = f[1,1] = Axis(f[1,1], title = "Compiled code")
    text!(textbox, lift(x ->  string(obs_passes[1][].checked + obs_passes[2][].checked), vector_obs_passes))
    f

