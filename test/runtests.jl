using Nautilus
using Test
using GLMakie
using GPUCompiler


@testset "Nautilus.jl" begin
    # Write your tests here.
end
####

fig = Figure()
menu = Menu(fig, options = ["viridis", "heat", "blues"])
funcs = [sqrt, x->x^2, sin, cos]
menu2 = Menu(fig, options = zip(["Square Root", "Square", "Sine", "Cosine"], funcs))
fig[1, 1] = vgrid!(
    Label(fig, "Colormap", width = nothing),
    menu,
    Label(fig, "Function", width = nothing),
    menu2;
    tellheight = false, width = 200)
ax = Axis(fig[1, 2])
func = Observable{Any}(funcs[1])
ys = lift(func) do f
    f.(0:0.3:10)
end
scat = scatter!(ax, ys, markersize = 30px, color = ys)
cb = Colorbar(fig[1, 3], scat)
on(menu.selection) do s
    scat.colormap = s
end
on(menu2.selection) do s
    func[] = s
    autolimits!(ax)
end
menu2.is_open = true
fig
##### Toggles
using GLMakie
fig = Figure()
ax = Axis(fig[1, 1])
toggles = [Toggle(fig, active = active) for active in [true, false]]
labels = [Label(fig, lift(x -> x ? "$l visible" : "$l invisible", t.active))
    for (t, l) in zip(toggles, ["sine", "cosine"])]
fig[1, 2] = grid!(hcat(toggles, labels), tellheight = false)
line1 = lines!(0..10, sin, color = :blue, visible = false)
line2 = lines!(0..10, cos, color = :red)
connect!(line1.visible, toggles[1].active)
connect!(line2.visible, toggles[2].active)
fig
####
fig = Figure()
toggles = [Toggle(fig, active = active.checked) for active in mypasses]
labels = [Label(fig, lift( x -> x ? "TRUE $(string(l.pass))" : "FALSE $(string(l.pass))", t.active); halign = :left)
    for (t, l) in zip(toggles, mypasses)]
fig[1, 2] = grid!(hcat(toggles, labels), tellheight = false)



r = Ref{Int}(42)
r[] = 43
nothing
####

global mypasses = [
  (;checked = true, pass = alloca_opt!),
  (;checked = true, pass = GPUCompiler.speculative_execution_if_has_branch_divergence!),
  (;checked = true, pass = loop_unroll!),
  (;checked = true, pass = instruction_combining!),
  (;checked = true, pass = licm!),
  (;checked = true, pass = early_csemem_ssa!),
  (;checked = true, pass = dead_store_elimination!),
  (;checked = true, pass = cfgsimplification!),
  (;checked = true, pass = global_dce!)
]




# TODO Don't type pirate  
function GPUCompiler.optimize_module!(@nospecialize(job::CompilerJob{PTXCompilerTarget}),
                           mod::LLVM.Module)
     tm = llvm_machine(job.target)
     ModulePassManager() do pm
         add_library_info!(pm, triple(mod))
         add_transform_info!(pm, tm)

         for p in passes
            if p.checked
                p.pass(pm)
            end
        end
        run!(pm, mod)
    end
end

##### GPUCompiler.optimize_module!
# function GPUCompiler.optimize_module!(@nospecialize(job::CompilerJob{PTXCompilerTarget}),
#                           mod::LLVM.Module, nothing)
#     tm = llvm_machine(job.target)
#     ModulePassManager() do pm
#         add_library_info!(pm, triple(mod))
#         add_transform_info!(pm, tm)

#         # needed by GemmKernels.jl-like code
#         speculative_execution_if_has_branch_divergence!(pm)

#         # NVPTX's target machine info enables runtime unrolling,
#         # but Julia's pass sequence only invokes the simple unroller.
#         loop_unroll!(pm)
#         instruction_combining!(pm)  # clean-up redundancy
#         licm!(pm)                   # the inner runtime check might be outer loop invariant

#         # the above loop unroll pass might have unrolled regular, non-runtime nested loops.
#         # that code still needs to be optimized (arguably, multiple unroll passes should be
#         # scheduled by the Julia optimizer). do so here, instead of re-optimizing entirely.
#         early_csemem_ssa!(pm) # TODO: gvn instead? see NVPTXTargetMachine.cpp::addEarlyCSEOrGVNPass
#         dead_store_elimination!(pm)

#         cfgsimplification!(pm)

#         # get rid of the internalized functions; now possible unused
#         global_dce!(pm)

#         run!(pm, mod)
#     end
# end

#### Code highlighting

using Colors
using Highlights

using Highlights.Format
using Highlights.Tokens
using Highlights.Themes

import Highlights.Themes: has_fg
css2color(str) = parse(RGBA{Float32}, string("#", str))
css2color(c::Themes.RGB) = RGBA{Float32}(c.r/255, c.g/255, c.b/255, 1.0)

function style2color(style, default)
    #if has_fg(style)
        css2color(style.fg)
    #else
    #    default
    #end
end

function render_str(
        ctx::Format.Context, theme::Format.Theme
    )
    #defaultcolor = if has_fg(theme.base)
    defaultcolor =     css2color(theme.base.fg)
    #else
    #    RGBA(0f0, 0f0, 0f0, 1f0)
    #end
    colormap = map(s-> style2color(s, defaultcolor), theme.styles)
    tocolor = Dict(zip(Tokens.__TOKENS__, colormap))
    colors = RGBA{Float32}[]
    io = IOBuffer()
    for token in ctx.tokens
        t = Tokens.__TOKENS__[token.value.value]
        str = SubString(ctx.source, token.first, token.last)
        print(io, str)
        append!(colors, fill(tocolor[t], length(str)))
        # push!(colors, tocolor[t])
    end
    String(take!(io)), colors
end


function highlight_text(src::AbstractString, theme = Themes.DefaultTheme)
    io = IOBuffer()
    render_str(
        Highlights.Compiler.lex(src, Lexers.JuliaLexer),
        Themes.theme(theme)
    )
end


src = """
function test(a, b)
    const a = sin(a) + 2.0
    return a 
end
"""

str, colors = highlight_text(src)

text(str, color=colors)
###### Modify optimize_module!





######
#### TestRuntime


module TestRuntime
    # dummy methods
    signal_exception() = return
    malloc(sz) = C_NULL
    report_oom(sz) = return
    report_exception(ex) = return
    report_exception_name(ex) = return
    report_exception_frame(idx, func, file, line) = return
end

struct TestCompilerParams <: AbstractCompilerParams end
GPUCompiler.runtime_module(::CompilerJob{<:Any,TestCompilerParams}) = TestRuntime

kernel() = begin
    r = Ref{Int}(42)
    r[] = 43
    nothing
end

function main()
    source = FunctionSpec(kernel)
    target = NativeCompilerTarget()
    params = TestCompilerParams()
    job = CompilerJob(target, source, params)

    #println(GPUCompiler.compile(:asm, job)[1])
    
    GPUCompiler.compile(:asm, job) |> first
end

isinteractive() || main()
main()