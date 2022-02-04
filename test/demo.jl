# Nautilus.jl 🐙 Demo
# Miguel Raz-Guzmán Macedo 2022
# TO RUN THIS DEMO:
# 1. Download this repo and then
# $ cd Nautilus
# $ julia --project=.
# $ julia> include("test/demo.jl")
# 2. Click the toggles.
# 3. Go for coffee because JITs hurt. Seriously.
#
# ###########################################
# VERY ALPHA - feedback welcome, see bottom.#
# (Yes, it's a script with tons of globals, #
#   schade Marmelade 🍓)                    #
# ###########################################
# 
# Nautilus' mission:
# "If there exists instrumentation to measure compiler internals,
#       we should have a
#           ♦ visual, interactive ♦
#                   interface for it."
#
# The demo works by having:
# * A vector of LLVM optimization passes.
# * A GPUCompiler workflow around hooks that emit `String`s of compiled `kernel()` closures.
# * A set of Makie `Toggle`s that when on/off change the compilation passes.
# # A Makie plotting window to display the results and offer interactivity.
#
# Here are the basic imports.
using Nautilus
using GLMakie
using GPUCompiler
using LLVM
using LLVM.Interop

# These are the optimization passes in LLVM/src/interop.jl".
# We will turn these on and off with Makie `Toggle`s later on.
global PASSES = [
  alloc_opt!,
  speculative_execution_if_has_branch_divergence!,
  loop_unroll!,
  instruction_combining!,
  licm!,
  early_csemem_ssa!,
  dead_store_elimination!,
  cfgsimplification!,
  global_dce!
]

# We're going to pirate this function now for the purposes of this demo. Be warned 💀!
function GPUCompiler.optimize_module!(@nospecialize(job::CompilerJob{PTXCompilerTarget}),
                           mod::LLVM.Module)
     tm = llvm_machine(job.target)
     ModulePassManager() do pm
         add_library_info!(pm, triple(mod))
         add_transform_info!(pm, tm)

         # This is the new logic:
         # Only activate the passes if the toggles are set to `true`
         # You have to check the `toggle.active.val` field for that.
         for (pass,toggle) in zip(PASSES, TOGGLES)
            if toggle.active.val
                pass(pm)
            end
        end
        run!(pm, mod)
    end
end

# The next few lines of code are GPUCompiler boilerplate.
# They help setup the compilation job with the proper hooks, more on them at another demo.
module TestRuntime
    signal_exception() = return
    malloc(sz) = C_NULL
    report_oom(sz) = return
    report_exception(ex) = return
    report_exception_name(ex) = return
    report_exception_frame(idx, func, file, line) = return
end

struct TestCompilerParams <: AbstractCompilerParams end
GPUCompiler.runtime_module(::CompilerJob{<:Any,TestCompilerParams}) = TestRuntime

# This is the function that we will actually be compiling and recompiling
# upon toggles being flipped on and off.
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
    
    # This `menu.selection[]` gets updated whenever the `menu` Observable 
    # is updated. 
    jobtype = menu.selection[]
    jobtype == :llvm && return GPUCompiler.compile(:llvm, job)[1] |> string
    jobtype == :asm  && return GPUCompiler.compile(:asm, job)[1] |> string
end

############################################################################################
# The Actual Nautilus.jl GUI demo begins:                                                  #
# 1. Setup a Figure, a vector of `Toggle`s, a vector of `Label`s to know the `Toggle names.#
# 2. Setup a Menu to choose between `llvmir`/`asm`.                                        #
# 3. Setup a TextBox to paint the compiled code text in.                                   #
# 4. Lift all the `Toggle`s and `Menu` to rerun `main()` upon clicks                       #
# 5. Paint the text in the textbox                                                         #
# ##########################################################################################
#
# 1, 2, 3 Setups
fig = Figure(backgroundcolor = :gray70);
passbox = fig[1,2] = Axis(fig[1,2], title = "Passes")
toggles = [Toggle(fig) for _ in PASSES];
labels = [Label(fig, lift(x -> x ? "$(string(pass))" : "$(string(pass))", t.active); halign = :left, textsize = 48.0f0)
    for (t, pass) in zip(toggles, PASSES)];
menu = Menu(fig[1,2], options = [:llvm, :asm], tellheight = false, textsize = 48.0f0, halign = :left)
fig[2, 2] = grid!(hcat(toggles, labels), tellheight = false)
textbox = fig[1:2,1] = Axis(fig[1:2,1], title = "Compiled code")

# 4. Lift
str = @lift begin
    $(toggles[1].active)
    $(toggles[2].active)
    $(toggles[3].active)
    $(toggles[4].active)
    $(toggles[5].active)
    $(toggles[6].active)
    $(toggles[7].active)
    $(toggles[8].active)
    $(toggles[9].active)
    $(menu.selection)
    string(main())
end
# 5. Paint text
text!(textbox, str, font = "JuliaMono", align = (:left, :top), justification = :left, textsize = 48f0)
fig

# KNOWN ISSUES:
# 1. The text should be centered at the top left. I tried passing in `position` and using `campixel(fig.scene)`
#       but the sizes returned were smaller than those of the total window and I didn't know how to change it.
# 2. The `@lift` is surely suboptimal - I'm open to hearing about a better pattern.
# 3. The bounding box for the `menu` looks *very* wonky. I wish it was a smaller floating menu just above the `Toggle`s.
# 4. 👷 Me - I'm sure my coding can be improved/be redesigned for easier use and avoid some pain. Please advise.
#
# WANTED FEATURES:
# 1. Drag and Drop-ing the passes into a different order.
# 2. Add/delete! passes in a certain order and have recompilation be triggered.
#       🚧 If you have any tips about how to make these work, please reach out! 🚧
#
#                                                                       Till next time,
#                                                                         Cap'n Nemo 🐙
