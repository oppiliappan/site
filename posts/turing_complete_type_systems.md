Rust's type system is Turing complete:

 - [FizzBuzz with Rust Traits](https://github.com/doctorn/trait-eval/)
 - [A Forth implementation with Rust Traits](https://github.com/Ashymad/fortraith)

It is impossible to determine if a program written in a
generally Turing complete system will ever stop. That is, it
is impossible to write a program `f` that determines if a
program `g`, where `g` is written in a Turing complete
programming language, will ever halt. The [Halting
Problem](https://en.wikipedia.org/wiki/Halting_problem) is
in fact, an [undecidable
problem](https://en.wikipedia.org/wiki/Undecidable_problem).

*How is any of this relevant?*

Rust performs compile-time type inference. The type checker,
in turn, compiles and infers types, I would describe it as a
compiler inside a compiler. It is possible that `rustc` may
never finish compiling your Rust program! I lied, `rustc`
stops after a while, after hitting the recursion limit.

I understand that this post lacks content.
