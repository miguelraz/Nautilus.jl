# Script to test text layout observable updating on a toggle vector.
# Problem:
# I have a vector of 2 passes, 2 toggles and 2 labels, and upon toggling,
# I want for a function that depends on the internal values of 
# `passes` to recompute a function and paint that text.
# Solution 1 (did not work):
# Make each pass an observable, so that the toggles/labels work,
# but also make the vector of observable passes an observable,
# so that painting the text is only done once.
# Solution 2 (morning of day after):
# Use the `@lift` macro, interpolate the toggle observables (`toggles[1].active`, that is)
using GLMakie
    #passes = [
    #          (;checked = true, pass = "pass 1"),
    #          (;checked = true, pass = "pass 2")
    #         ]
    passes = ["pass 1", "pass 2"]
    f = Figure(backgroundcolor = :gray70);
    passbox = f[1,2] = Axis(f[1,2], title = "Passes")
    toggles = [Toggle(f), Toggle(f)]
    labels = [Label(f, lift(x -> x ? "ON $(toggles[i].active.val)" : "OFF $(toggles[i].active.val)", toggles[i].active), textsize = 48f0) for i in 1:2]
    f[1,2] = grid!(hcat(toggles, labels), tellheight = false)
    textbox = f[1,1] = Axis(f[1,1], title = "Compiled code")
    #str = @lift "Toggle 1 is " * repr($(toggles[1].active)) * " and Toggle 2 is " * repr($(toggles[2].active))
    str = @lift "Sum of toggles is " * repr($(toggles[1].active) + $(toggles[2].active))
    #text!(textbox, lift(x ->  string(obs_passes[1][].checked + obs_passes[2][].checked), vector_obs_passes))
    text!(textbox, str)
    #text!(textbox, @lift($(toggles[1].active) + $(toggles[2].active)), vector_obs_passes)
    f

