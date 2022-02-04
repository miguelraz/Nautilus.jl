### Notes:

I'm keeping these as a whiteboard/note taking places. Nothing too important goes on here besides my ramblings.

### What is the scope?
- Keep in mind: Cthulhu.jl and not reinvent the wheel
- Toggle and reorder passes
- Time LLVM passes
- Visualize IR before and after 
- Who wants to use your tool?
  - Being able to look at a full app and instrument it / how can we filter for interesting things?
  - hooks can attach code that runs before a compiler job TODO read `driver.jl`
  - help *them* analyzer *their* code

### Very, very far Stretch goals
- Integration with MCAnalyzer.jl
- SIMDVisualizer ?
- Rust/C++/Fortran support
- `compute_santizer`, `racecheck`, `synccheck` ?

###  Someone should also work on these, we want them, but not me!
- [Graph homomorphism](https://twitter.com/ChrisGSeaton/status/1486433894354272263?t=i6i8je_X5ZowRzrZWfhX5g&s=19) algorithm
- [Intel Processor Trace](https://blog.janestreet.com/magic-trace/)


### Todos
1. [X] Recompile on toggle
2. [X] Show text
3. Get colors
- [ ] Lexer for GCN with `Highlights.Lexer` [link here](https://juliadocs.github.io/Highlights.jl/stable/man/lexer/#Lexer-Guide-1)
- [ ] asm lexer
- [ ] llvmir lexer
- [ ] ptx lexer
4. [ ] Reorder toggles triggers recompilation (Drag and Drop
5. [ ] Hooks mechanics from outside
6. [ ] Use cases:
   1. DiffEq solver going faster
   2. Gridap.jl PDE 
   3. GPU Kernels going faster
   4. Clima.jl?
   5. TaylorIntegration.jl?
   6. ImmutableArrays stuff
   7. SIMD Rust
7. Passes definitions on `DataInspector` hoverings / extra examples somewhere?
8. Add/remove passes as wanted
9. Modify passes' configuration with ctrl click?
10. Find First Failed Pass

### Before release:
- Documentation landing page
- cute logo?
- GPU people, Tim HOly, DiffEq/Compiler people
- MWE per optimization pass
- JOSS publication 
- Zenodo/DOI/Bibtex in Repo
- Setup sponsorship?
- Bril Julia course?
