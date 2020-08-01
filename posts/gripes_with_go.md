You've read a lot of posts about the shortcomings of the Go
programming language, so what's one more.

 1. [Lack of sum types](#lack-of-sum-types)
 2. [Type assertions](#type-assertions)
 3. [Date and Time](#date-and-time)
 4. [Statements over Expressions](#statements-over-expressions)
 5. [Erroring out on unused variables](#erroring-out-on-unused-variables)
 6. [Error handling](#error-handling)

### Lack of Sum types

A "Sum" type is a data type that can hold one of many states
at a given time, similar to how a boolean can hold a true or
a false, not too different from an `enum` type in C. Go
lacks `enum` types unfortunately, and you are forced to
resort to crafting your own substitute.

A type to represent gender for example:

```go
type Gender int

const (
    Male Gender = iota  // assigns Male to 0
    Female              // assigns Female to 1
    Other               // assigns Other to 2
)

fmt.Println("My gender is ", Male)
// My gender is 0
// Oops! We have to implement String() for Gender ...

func (g Gender) String() string {
    switch (g) {
    case 0: return "Male"
    case 1: return "Female"
    default: return "Other"
    }
}

// You can accidentally do stupid stuff like:
gender := Male + 1
```

The Haskell equivalent of the same:

```haskell
data Gender = Male
            | Female
            | Other
            deriving (Show)

print $ "My gender is " ++ (show Male)
```

### Type Assertions

A downcast with an optional error check? What could go
wrong?

Type assertions in Go allow you to do:

```go
var x interface{} = 7
y, goodToGo := x.(int)
if goodToGo {
    fmt.Println(y)
}
```

The error check however is optional:

```go
var x interface{} = 7
var y := x.(float64)
fmt.Println(y)
// results in a runtime error:
// panic: interface conversion: interface {} is int, not float64
```

### Date and Time

Anyone that has written Go previously, will probably already
know what I am getting at here. For the uninitiated, parsing
and formatting dates in Go requires a "layout". This
"layout" is based on magical reference date:

```
Mon Jan 2 15:04:05 MST 2006
```

Which is the date produced when you write the first seven
natural numbers like so:

```
01/02 03:04:05 '06 -0700
```

Parsing a string in `YYYY-MM-DD` format would look something
like:

```go
const layout = "2006-01-02"
time.Parse(layout, "2020-08-01")
```

This so-called "intuitive" method of formatting dates
doesn't allow you to print `0000 hrs` as `2400 hrs`, it
doesn't allow you to omit the leading zero in 24 hour
formats. It is rife with inconveniences, if only there were
a [tried and
tested](https://man7.org/linux/man-pages/man3/strftime.3.html)
date formatting convention ...

### Statements over Expressions

Statements have side effects, expressions return values.
More often than not, expressions are easier to understand at
a glance: evaluate the LHS and assign the same to the RHS.

Rust allows you to create local namespaces, and treats
blocks (`{}`) as expressions:

```rust
let twenty_seven = {
    let three = 1 + 2;
    let nine = three * three;
    nine * three
};
```

The Go equivalent of the same:

```go
twenty_seven := nil

three := 1 + 2
nine := three * three
twenty_seven = nine * three
```


### Erroring out on unused variables

Want to quickly prototype something? Go says no! In all
seriousness, a warning would suffice, I don't want to have
to go back and comment each unused import out, only to come
back and uncomment them a few seconds later.

### Error handling

```go
if err != nil { ... }
```

Need I say more? I will, for good measure:

1. Error handling is optional
2. Errors are propagated via a clunky `if` + `return` statement

I prefer Haskell's "Monadic" error handling, which is
employed by Rust as well:

```rust
// 1. error handling is compulsory
// 2. errors are propagated with the `?` operator
fn foo() -> Result<String, io::Error> {
    let mut f = File::open("foo.txt")?; // return here if error
    let mut s = String::new();

    f.read_to_string(&mut s)?; // return here if error

    Ok(s) // all good, return the value inside a `Result` context
}
```

