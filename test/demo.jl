using Nautilus
using Test
using GLMakie
using GPUCompiler
using LLVM
using LLVM.Interop

#" These are in LLVM/src/interop"
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

# TODO Don't type pirate  
function GPUCompiler.optimize_module!(@nospecialize(job::CompilerJob{PTXCompilerTarget}),
                           mod::LLVM.Module)
     tm = llvm_machine(job.target)
     ModulePassManager() do pm
         add_library_info!(pm, triple(mod))
         add_transform_info!(pm, tm)

         # TODO
         for (pass,toggle) in zip(PASSES, TOGGLES)
            if toggle.active.val
                pass(pm)
            end
        end
        run!(pm, mod)
    end
end

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
    
    jobtype = menu.selection[]
    jobtype == :llvm && return GPUCompiler.compile(:llvm, job)[1] |> string
    jobtype == :asm  && return GPUCompiler.compile(:asm, job)[1] |> string
end

#let 
    fig = Figure(backgroundcolor = :gray70);
    @show size(campixel(fig.scene))
    passbox = fig[1,2] = Axis(fig[1,2], title = "Passes")
    toggles = [Toggle(fig) for _ in PASSES];
    labels = [Label(fig, lift(x -> x ? "$(string(pass))" : "$(string(pass))", t.active); halign = :left, textsize = 48.0f0)
        for (t, pass) in zip(toggles, PASSES)];
    menu = Menu(fig[1,2], options = [:llvm, :asm], tellheight = false, textsize = 48.0f0, halign = :left)
    fig[2, 2] = grid!(hcat(toggles, labels), tellheight = false)
    textbox = fig[1:2,1] = Axis(fig[1:2,1], title = "Compiled code")
    # TODO LLVM or asm job compiler
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
    w, h = size(campixel(fig.scene))
    w = 50
    @show h
    @show w
    @show size(campixel(fig.scene))
    pos = (w, 2 * h)
    text!(textbox, str, font = "JuliaMono",
          align = (:left, :top),
          justification = :left,
          textsize = 48f0)
    fig
#end
