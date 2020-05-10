This post contains a gentle introduction to procedural
macros in Rust and a guide to writing a procedural macro to
curry Rust functions. The source code for the entire library
can be found [here](https://github.com/nerdypepper/cutlass).
It is also available on [crates.io](https://crates.io/crates/cutlass).

The following links might prove to be useful before getting
started:

 - [Procedural Macros](https://doc.rust-lang.org/reference/procedural-macros.html)
 - [Currying](https://en.wikipedia.org/wiki/Currying)

Or you can pretend you read them, because I have included
a primer here :)


### Contents

 1. [Currying](#currying)  
 2. [Procedural Macros](#procedural-macros)  
 3. [Definitions](#definitions)  
 4. [Refinement](#refinement)  
 5. [The In-betweens](#the-in-betweens)  
 &nbsp;&nbsp;&nbsp;&nbsp; 5.1 [Dependencies](#dependencies)  
 &nbsp;&nbsp;&nbsp;&nbsp; 5.2 [The attribute macro](#the-attribute-macro)  
 &nbsp;&nbsp;&nbsp;&nbsp; 5.3 [Function Body](#function-body)  
 &nbsp;&nbsp;&nbsp;&nbsp; 5.4 [Function Signature](#function-signature)  
 &nbsp;&nbsp;&nbsp;&nbsp; 5.5 [Getting it together](#getting-it-together)  
 6. [Debugging and Testing](#debugging-and-testing)  
 7. [Notes](#notes)  
 8. [Conclusion](#conclusion)  

### Currying

Currying is the process of transformation of a function call
like `f(a, b, c)` to `f(a)(b)(c)`. A curried function
returns a concrete value only when it receives all its
arguments! If it does recieve an insufficient amount of
arguments, say 1 of 3, it returns a *curried function*, that
returns after receiving 2 arguments.

```
curry(f(a, b, c)) = h(a)(b)(c)

h(x) = g   <- curried function that takes upto 2 args (g)
g(y) = k   <- curried function that takes upto 1 arg (k)
k(z) = v   <- a value (v)

Keen readers will conclude the following,
h(x)(y)(z) = g(y)(z) = k(z) = v
```

Mathematically, if `f` is a function that takes two
arguments `x` and `y`, such that `x ϵ X`, and `y ϵ Y` , we
write it as:

```
f: (X × Y) -> Z
```

where `×` denotes the Cartesian product of set `X` and `Y`,
and curried `f` (denoted by `h` here) is written as:

```
h: X -> (Y -> Z)
```

### Procedural Macros

These are functions that take code as input and spit out
modified code as output. Powerful stuff. Rust has three
kinds of proc-macros:

 - Function like macros  
 - Derive macros: `#[derive(...)]`, used to automatically
   implement traits for structs/enums  
 - and Attribute macros: `#[test]`, usually slapped onto
   functions  

We will be using Attribute macros to convert a Rust function
into a curried Rust function, which we should be able to
call via: `function(arg1)(arg2)`.

### Definitions

Being respectable programmers, we define the input to and
the output from our proc-macro. Here's a good non-trivial
function to start out with:

```rust
fn add(x: u32, y: u32, z: u32) -> u32 {
  return x + y + z;
}
```

Hmm, what would our output look like? What should our
proc-macro generate ideally? Well, if we understood currying
correctly, we should accept an argument and return a
function that accepts an argument and returns ... you get
the point. Something like this should do:

```rust
fn add_curried1(x: u32) -> ? {
  return fn add_curried2 (y: u32) -> ? {
    return fn add_curried3 (z: u32) -> u32 {
      return x + y + z;
    }
  }
}
```

A couple of things to note:

**Return types**  
 We have placed `?`s in place of return
types. Let's try to fix that. `add_curried3` returns the
'value', so `u32` is accurate. `add_curried2` returns
`add_curried3`. What is the type of `add_curried3`? It is a
function that takes in a `u32` and returns a `u32`.  So a
`fn(u32) -> u32` will do right? No, I'll explain why in the
next point, but for now, we will make use of the `Fn` trait,
our return type is `impl Fn(u32) -> u32`. This basically
tells the compiler that we will be returning something
function-like, a.k.a, behaves like a `Fn`. Cool! 

If you have been following along, you should be able to tell
that the return type of `add_curried1` is:
```
impl Fn(u32) -> (impl Fn(u32) -> u32)
```

We can drop the parentheses because `->` is right associative:
```
impl Fn(u32) -> impl Fn(u32) -> u32

```

**Accessing environment**  
 A function cannot access it's environment. Our solution
will not work. `add_curried3` attempts to access `x`, which
is not allowed! A closure[^closure] however, can. If we are
returning a closure, our return type must be `impl Fn`, and
not `fn`.  The difference between the `Fn` trait and
function pointers is beyond the scope of this post.

[^closure]: [https://doc.rust-lang.org/book/ch13-01-closures.html](https://doc.rust-lang.org/book/ch13-01-closures.html)

### Refinement

Armed with knowledge, we refine our expected output, this
time, employing closures:

```rust
fn add(x: u32) -> impl Fn(u32) -> impl Fn(u32) -> u32 {
  return move |y| move |z| x + y + z;
}
```

Alas, that does not compile either! It errors out with the
following message:

```
error[E0562]: `impl Trait` not allowed outside of function
and inherent method return types
  --> src/main.rs:17:37
   |
   | fn add(x: u32) -> impl Fn(u32) -> impl Fn(u32) -> u32
   |                                   ^^^^^^^^^^^^^^^^^^^

```

You are allowed to return an `impl Fn` only inside a
function. We are currently returning it from another return!
Or at least, that was the most I could make out of the error
message.

We are going to have to cheat a bit to fix this issue; with
type aliases and a convenient nightly feature [^features]:

[^features]: [caniuse.rs](https://caniuse.rs) contains an
  indexed list of features and their status.

```rust
#![feature(type_alias_impl_trait)]  // allows us to use `impl Fn` in type aliases!

type T0 = u32;                 // the return value when zero args are to be applied
type T1 = impl Fn(u32) -> T0;  // the return value when one arg is to be applied
type T2 = impl Fn(u32) -> T1;  // the return value when two args are to be applied

fn add(x: u32) -> T2 {
  return move |y| move |z| x + y + z;
}
```

Drop that into a cargo project, call `add(4)(5)(6)`, cross
your fingers, and run `cargo +nightly run`. You should see a
15 unless you forgot to print it!

### The In-Betweens

Let us write the magical bits that take us from function to
curried function. 

Initialize your workspace with `cargo new --lib currying`.
Proc-macro crates are libraries with exactly one export, the
macro itself. Add a `tests` directory to your crate root.
Your directory should look something like this:

```
.
├── Cargo.toml
├── src
│   └── lib.rs
└── tests
    └── smoke.rs
```

#### Dependencies

We will be using a total of 3 external crates:

 - [proc_macro2](https://docs.rs/proc-macro2/1.0.12/proc_macro2/)
 - [syn](https://docs.rs/syn/1.0.18/syn/index.html)
 - [quote](https://docs.rs/quote/1.0.4/quote/index.html)

Here's a sample `Cargo.toml`:

```
# Cargo.toml

[dependencies]
proc-macro2 = "1.0.9"
quote = "1.0"

[dependencies.syn]
version = "1.0"
features = ["full"]

[lib]
proc-macro = true  # this is important!
```

We will be using an external `proc-macro2` crate as well as
an internal `proc-macro` crate. Not confusing at all!

#### The attribute macro

Drop this into `src/lib.rs`, to get the ball rolling.

```rust
// src/lib.rs

use proc_macro::TokenStream;  // 1
use quote::quote;
use syn::{parse_macro_input, ItemFn};

#[proc_macro_attribute]   // 2
pub fn curry(_attr: TokenStream, item: TokenStream) -> TokenStream {
  let parsed = parse_macro_input!(item as ItemFn);  // 3
  generate_curry(parsed).into()  // 4
}

fn generate_curry(parsed: ItemFn) -> proc_macro2::TokenStream {}
```

**1. Imports**

A `Tokenstream` holds (hopefully valid) Rust code, this
is the type of our input and output. Note that we are
importing this type from `proc_macro` and not `proc_macro2`.

`quote!` from the `quote` crate is a macro that allows us to
quickly produce `TokenStream`s. Much like the LISP `quote`
procedure, you can use the `quote!` macro for symbolic
transformations.

`ItemFn` from the `syn` crate holds the parsed `TokenStream`
of a Rust function. `parse_macro_input!` is a helper macro
provided by `syn`.

**2. The lone export**

Annotate the only `pub` of our crate with
`#[proc_macro_attribute]`. This tells rustc that `curry` is
a procedural macro, and allows us to use it as
`#[crate_name::curry]` in other crates. Note the signature
of the `curry` function. `_attr` is the `TokenStream`
representing the attribute itself, `item` refers to the
thing we slapped our macro into, in this case a function
(like `add`). The return value is a modified `TokenStream`,
this will contain our curried version of `add`.

**3. The helper macro**

A `TokenStream` is a little hard to work with, which is why
we have the `syn` crate, which provides types to represent
Rust tokens. An `RArrow` struct to represent the return
arrow on a function and so on. One of those types is
`ItemFn`, that represents an entire Rust function. The
`parse_macro_input!` automatically puts the input to our
macro into an `ItemFn`.  What a gentleman!

**4. Returning `TokenStream`s **

We haven't filled in `generate_curry` yet, but we can see
that it returns a `proc_macro2::TokenStream` and not a
`proc_macro::TokenStream`, so drop a `.into()` to convert
it.

Lets move on, and fill in `generate_curry`, I would suggest
keeping the documentation for
[`syn::ItemFn`](https://docs.rs/syn/1.0.19/syn/struct.ItemFn.html)
and
[`syn::Signature`](https://docs.rs/syn/1.0.19/syn/struct.Signature.html)
open.

```rust
// src/lib.rs

fn generate_curry(parsed: ItemFn) -> proc_macro2::TokenStream {
  let fn_body = parsed.block;      // function body
  let sig = parsed.sig;            // function signature
  let vis = parsed.vis;            // visibility, pub or not
  let fn_name = sig.ident;         // function name/identifier
  let fn_args = sig.inputs;        // comma separated args
  let fn_return_type = sig.output; // return type
}
```

We are simply extracting the bits of the function, we will
be reusing the original function's visibility and name. Take
a look at what `syn::Signature` can tell us about a
function:

```
                       .-- syn::Ident (ident)
                      /
                 fn add(x: u32, y: u32) -> u32
  (fn_token)      /     ~~~~~~~,~~~~~~  ~~~~~~
syn::token::Fn --'            /               \       (output)
                             '                 `- syn::ReturnType
             Punctuated<FnArg, Comma> (inputs)
```

Enough analysis, lets produce our first bit of Rust code.

#### Function Body

Recall that the body of a curried `add` should look like
this:

```rust
return move |y| move |z| x + y + z;
```

And in general:

```rust
return move |arg2| move |arg3| ... |argN| <function body here>
```

We already have the function's body, provided by `fn_body`,
in our `generate_curry` function. All that's left to add is
the `move |arg2| move |arg3| ...` stuff, for which we need
to extract the argument identifiers 
(doc: 
[Punctuated](https://docs.rs/syn/1.0.18/syn/punctuated/struct.Punctuated.html),
[FnArg](https://docs.rs/syn/1.0.18/syn/enum.FnArg.html),
[PatType](https://docs.rs/syn/1.0.18/syn/struct.PatType.html)):

```rust
// src/lib.rs
use syn::punctuated::Punctuated;
use syn::{parse_macro_input, FnArg, Pat, ItemFn, Block};

fn extract_arg_idents(fn_args: Punctuated<FnArg, syn::token::Comma>) -> Vec<Box<Pat>> { 
  return fn_args.into_iter().map(extract_arg_pat).collect::<Vec<_>>();
}
```

Alright, so we are iterating over function args
(`Punctuated` is a collection that you can iterate over) and
mapping an `extract_arg_pat` to every item. What's
`extract_arg_pat`?

```rust
// src/lib.rs

fn extract_arg_pat(a: FnArg) -> Box<Pat> {
  match a {
    FnArg::Typed(p) => p.pat,
    _ => panic!("Not supported on types with `self`!"),
  }
}
```

`FnArg` is an enum type as you might have guessed. The
`Typed` variant encompasses args that are written as `name:
type` and the other variant, `Reciever` refers to `self`
types. Ignore those for now, keep it simple.

Every `FnArg::Typed` value contains a `pat`, which is in
essence, the name of the argument. The type of the arg is
accessible via `p.ty` (we will be using this later).

With that done, we should be able to write the codegen for
the function body:

```rust
// src/lib.rs

fn generate_body(fn_args: &[Box<Pat>], body: Box<Block>) -> proc_macro2::TokenStream {
  quote! {
    return #( move |#fn_args|  )* #body
  }
}
```

That is some scary looking syntax! Allow me to explain. The
`quote!{ ... }` returns a `proc_macro2::TokenStream`, if we
wrote `quote!{ let x = 1 + 2; }`, it wouldn't create a new
variable `x` with value 3, it would literally produce a
stream of tokens with that expression. 

The `#` enables variable interpolation. `#body` will look
for `body` in the current scope, take its value, and insert
it in the returned `TokenStream`. Kinda like quasi quoting
in LISPs, you have written one.

What about `#( move |#fn_args| )*`? That is repetition.
`quote` iterates through `fn_args`, and drops a `move` behind
each one, it then places pipes (`|`), around it.

Let us test our first bit of codegen! Modify `generate_curry` like so:

```rust
// src/lib.rs

 fn generate_curry(parsed: ItemFn) -> TokenStream {
   let fn_body = parsed.block;
   let sig = parsed.sig;
   let vis = parsed.vis;
   let fn_name = sig.ident;
   let fn_args = sig.inputs;
   let fn_return_type = sig.output;

+  let arg_idents = extract_arg_idents(fn_args.clone());
+  let first_ident = &arg_idents.first().unwrap();

+  // remember, our curried body starts with the second argument!
+  let curried_body = generate_body(&arg_idents[1..], fn_body.clone());
+  println!("{}", curried_body);

   return TokenStream::new();
 }
```
Add a little test to `tests/`:

```rust
// tests/smoke.rs

#[currying::curry]
fn add(x: u32, y: u32, z: u32) -> u32 {
  x + y + z
}

#[test]
fn works() {
  assert!(true);
}
```

You should find something like this in the output of `cargo
test`:

```
return move | y | move | z | { x + y + z }
```

Glorious `println!` debugging!

#### Function signature

This section gets into the more complicated bits of the
macro, generating type aliases and the function signature.
By the end of this section, we should have a full working
auto-currying macro!

Recall what our generated type aliases should look like, for
our `add` function:

```rust
type T0 = u32;
type T1 = impl Fn(u32) -> T0;
type T2 = impl Fn(u32) -> T1;
```
In general:

```rust
type T0 = <return type>;
type T1 = impl Fn(<type of arg N>) -> T0;
type T2 = impl Fn(<type of arg N - 1>) -> T1;
.
.
.
type T(N-1) = impl Fn(<type of arg 2>) -> T(N-2);
```

To codegen that, we need the types of:

 - all our inputs (arguments)
 - the output (the return type)

To fetch the types of all our inputs, we can simply reuse
the bits we wrote to fetch the names of all our inputs!
(doc: [Type](https://docs.rs/syn/1.0.18/syn/enum.Type.html))

```rust
// src/lib.rs

use syn::{parse_macro_input, Block, FnArg, ItemFn, Pat, ReturnType, Type};

fn extract_type(a: FnArg) -> Box<Type> {
  match a {
    FnArg::Typed(p) => p.ty,  // notice `ty` instead of `pat`
      _ => panic!("Not supported on types with `self`!"),
  }
}

fn extract_arg_types(fn_args: Punctuated<FnArg, syn::token::Comma>) -> Vec<Box<Type>> {
  return fn_args.into_iter().map(extract_type).collect::<Vec<_>>();

}
```

A good reader would have looked at the docs for output
member of the `syn::Signature` struct. It has the type
`syn::ReturnType`. So there is no extraction to do here
right? There are actually a couple of things we have to
ensure here:

1. We need to ensure that the function returns! A function
   that does not return is pointless in this case, and I
will tell you why, in the [Notes](#notes) section.

2. A `ReturnType` encloses the arrow of the return as well,
   we need to get rid of that. Recall:
   ```rust
type T0 = u32
// and not
type T0 = -> u32
   ```

Here is the snippet that handles extraction of the
return type (doc: [syn::ReturnType](https://docs.rs/syn/1.0.19/syn/enum.ReturnType.html)):

```rust
// src/lib.rs

fn extract_return_type(a: ReturnType) -> Box<Type> {
  match a {
    ReturnType::Type(_, p) => p,
    _ => panic!("Not supported on functions without return types!"),
  }
}
```

You might notice that we are making extensive use of the
`panic!` macro. Well, that is because it is a good idea to
quit on receiving an unsatisfactory `TokenStream`.

With all our types ready, we can get on with generating type
aliases:

```rust
// src/lib.rs

use quote::{quote, format_ident};

fn generate_type_aliases(
  fn_arg_types: &[Box<Type>],
  fn_return_type: Box<Type>,
  fn_name: &syn::Ident,
) -> Vec<proc_macro2::TokenStream> {    // 1

  let type_t0 = format_ident!("_{}_T0", fn_name);    // 2
  let mut type_aliases = vec![quote! { type #type_t0 = #fn_return_type  }];

  // 3
  for (i, t) in (1..).zip(fn_arg_types.into_iter().rev()) {
    let p = format_ident!("_{}_{}", fn_name, format!("T{}", i - 1));
    let n = format_ident!("_{}_{}", fn_name, format!("T{}", i));

    type_aliases.push(quote! {
        type #n = impl Fn(#t) -> #p
    });
  }

  return type_aliases;
}

```

**1. The return value**  
We are returning a `Vec<proc_macro2::TokenStream>`, i. e., a
list of `TokenStream`s, where each item is a type alias.

**2. Format identifier?**  
I've got some explanation to do on this line. Clearly, we
are trying to write the first type alias, and initialize our
`TokenStream` vector with `T0`, because it is different from
the others:

```rust
type T0 = something
// the others are of the form
type Tr = impl Fn(something) -> something
```

`format_ident!` is similar to `format!`. Instead of
returning a formatted string, it returns a `syn::Ident`.
Therefore, `type_t0` is actually an identifier for, in the
case of our `add` function, `_add_T0`. Why is this
formatting important? Namespacing. 

Picture this, we have two functions, `add` and `subtract`,
that we wish to curry with our macro:

```rust
#[curry]
fn add(...) -> u32 { ... }

#[curry]
fn sub(...) -> u32 { ... }
```

Here is the same but with macros expanded:

```rust
type T0 = u32;
type T1 = impl Fn(u32) -> T0;
fn add( ... ) -> T1 { ... }

type T0 = u32;
type T1 = impl Fn(u32) -> T0;
fn sub( ... ) -> T1 { ... }
```

We end up with two definitions of `T0`! Now, if we do the
little `format_ident!` dance we did up there:

```rust
type _add_T0 = u32;
type _add_T1 = impl Fn(u32) -> _add_T0;
fn add( ... ) -> _add_T1 { ... }

type _sub_T0 = u32;
type _sub_T1 = impl Fn(u32) -> _sub_T0;
fn sub( ... ) -> _sub_T1 { ... }
```

Voilà! The type aliases don't tread on each other. Remember
to import `format_ident` from the `quote` crate.

**3. The TokenStream Vector**

 We iterate over our types in reverse order (`T0` is the
last return, `T1` is the second last, so on), assign a
number to each iteration with `zip`, generate type names
with `format_ident`, push a `TokenStream` with the help of
`quote` and variable interpolation.

If you are wondering why we used `(1..).zip()` instead of
`.enumerate()`, it's because we wanted to start counting
from 1 instead of 0 (we are already done with `T0`!).


#### Getting it together

I promised we'd have a fully working macro by the end of
last section. I lied, we have to tie everything together in
our `generate_curry` function:

```rust
// src/lib.rs

 fn generate_curry(parsed: ItemFn) -> proc_macro2::TokenStream {
   let fn_body = parsed.block;
   let sig = parsed.sig;
   let vis = parsed.vis;
   let fn_name = sig.ident;
   let fn_args = sig.inputs;
   let fn_return_type = sig.output;

   let arg_idents = extract_arg_idents(fn_args.clone());
   let first_ident = &arg_idents.first().unwrap();
   let curried_body = generate_body(&arg_idents[1..], fn_body.clone());

+  let arg_types = extract_arg_types(fn_args.clone());
+  let first_type = &arg_types.first().unwrap();
+  let type_aliases = generate_type_aliases(
+      &arg_types[1..],
+      extract_return_type(fn_return_type),
+      &fn_name,
+  );

+  let return_type = format_ident!("_{}_{}", &fn_name, format!("T{}", type_aliases.len() - 1));

+  return quote! {
+      #(#type_aliases);* ;
+      #vis fn #fn_name (#first_ident: #first_type) -> #return_type {
+          #curried_body ;
+      }
+  };
 }
```

 Most of the additions are self explanatory, I'll go through
the return statement with you. We are returning a `quote!{
... }`, so a `proc_macro2::TokenStream`. We are iterating
through the `type_aliases` variable, which you might recall,
is a `Vec<TokenStream>`. You might notice the sneaky
semicolon before the `*`. This basically tells `quote`, to
insert an item, then a semicolon, and then the next one,
another semicolon, and so on. The semicolon is a separator.
We need to manually insert another semicolon at the end of
it all, `quote` doesn't insert a separator at the end of the
iteration.

We retain the visibility and name of our original function.
Our curried function takes as args, just the first argument
of our original function. The return type of our curried
function is actually, the last type alias we create. If you
think back to our manually curried `add` function, we
returned `T2`, which was in fact, the last type alias we
created. 

I am sure, at this point, you are itching to test this out,
but before that, let me introduce you to some good methods
of debugging proc-macro code.

### Debugging and Testing

Install `cargo-expand` via:

```
cargo install cargo-expand
```

`cargo-expand` is a neat little tool that expands your macro
in places where it is used, and lets you view the generated
code! For example:

```shell
# create a bin package hello
$ cargo new hello

# view the expansion of the println! macro
$ cargo expand

#![feature(prelude_import)]
#[prelude_import]
use std::prelude::v1::*;
#[macro_use]
extern crate std;
fn main() {
  {
    ::std::io::_print(::core::fmt::Arguments::new_v1(
        &["Hello, world!\n"],
        &match () {
            () => [],
        },
      ));
  };
}
```

Writing proc-macros without `cargo-expand` is tantamount to
driving a vehicle without rear view mirrors! Keep an eye on
what is going on behind your back.

Now, your macro won't always compile, you might just recieve
the bee movie script as an error. `cargo-expand` will not
work in such cases. I would suggest printing out your
variables to inspect them. `TokenStream` implements
`Display` as well as `Debug`. We don't always have to be
respectable programmers. Just print it.

Enough of that, lets get testing:

```rust
// tests/smoke.rs

#![feature(type_alias_impl_trait)]

#[crate_name::curry]
fn add(x: u32, y: u32, z: u32) -> u32 {
   x + y + z
}

#[test]
fn works() {
  assert_eq!(15, add(4)(5)(6));
}
```

Run `cargo +nightly test`. You should see a pleasing
message:

```
running 1 test
test tests::works ... ok
```

Take a look at the expansion for our curry macro, via
`cargo +nightly expand --tests smoke`:

```rust
type _add_T0 = u32;
type _add_T1 = impl Fn(u32) -> _add_T0;
type _add_T2 = impl Fn(u32) -> _add_T1;
fn add(x: u32) -> _add_T2 {
  return (move |y| {
    move |z| {
      return x + y + z;
    }
  });
}

// a bunch of other stuff generated by #[test] and assert_eq!
```

A sight for sore eyes.

Here is a more complex example that generates ten multiples
of the first ten natural numbers:

```rust
#[curry]
fn product(x: u32, y: u32) -> u32 {
  x * y
}

fn multiples() -> Vec<Vec<u32>>{
  let v = (1..=10).map(product);
  return (1..=10)
      .map(|x| v.clone().map(|f| f(x)).collect())
      .collect();
}
```

### Notes

I didn't quite explain why we use `move |arg|` in our
closure. This is because we want to take ownership of the
variable supplied to us. Take a look at this example:

```rust
let v = add(5);
let g;
{
  let x = 5;
  g = v(x);
}
println!("{}", g(2));
```

Variable `x` goes out of scope before `g` can return a
concrete value. If we take ownership of `x` by `move`ing it
into our closure, we can expect this to work reliably. In
fact, rustc understands this, and forces you to use `move`.

This usage of `move` is exactly why **a curried function
without a return is useless**. Every variable we pass to our
curried function gets moved into its local scope. Playing
with these variables cannot cause a change outside this
scope. Returning is our only method of interaction with
anything beyond this function.

### Conclusion

Currying may not seem to be all that useful. Curried
functions are unwieldy in Rust because the standard library
is not built around currying. If you enjoy the possibilities
posed by currying, consider taking a look at Haskell or
Scheme.

My original intention with [peppe.rs](https://peppe.rs) was
to post condensed articles, a micro blog, but this one
turned out extra long. 

Perhaps I should call it a 'macro' blog :)
