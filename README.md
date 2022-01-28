# Nautilus.jl

> No depths are beyond fathom with the right tools...

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

###  Someone should also work on these, we want them, but not me!
- [Graph homomorphism](https://twitter.com/ChrisGSeaton/status/1486433894354272263?t=i6i8je_X5ZowRzrZWfhX5g&s=19) algorithm
- [Intel Processor Trace](https://blog.janestreet.com/magic-trace/)


### Todos
1. Recompile on toggle
2. Show text
3. Get colors
4. Reorder toggles triggers recompilation
- [ ] Lexer for GCN with `Highlights.Lexer`
5. Hooks mechanics from outside

### 