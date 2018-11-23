---
title: "Declarative programming in Rust"
author: Pascal Hertleif
date: 2018-09-05
categories:
- rust
- presentation
theme: pascal-light
progress: true
slideNumber: true
history: true
---
## Hi, I'm Pascal Hertleif

- Web dev & Rust
- Co-organizer of [Rust Cologne]
- {[twitter],[github]}.com/killercup
- Rust-centric blog: [deterministic.space]

[Rust Cologne]: http://rust.cologne/
[twitter]: https://twitter.com/killercup
[github]: https://github.com/killercup
[deterministic.space]: https://deterministic.space/

::: notes

- I've been working with Rust since early 2014
- I have stickers!

:::

# What is a computer program?

## Simply put,

- you tell a computer what to do,
- in tiny steps, specific instructions.

. . .

- This is imperative.
- Hard to reason about the general behavior of a program

- - -

“This is RustFest, Pascal, not AssemblyCamp”

::: notes

Let’s just say you need abstractions to not completely get lost

same as in real life

When I ask you for directions, “take the bus to foobar station” is something I can work with;
being told which streets to take for how many steps will surely result in me getting lost somewhere in Rome.
At least here I can get some great coffee wherever I go.

:::

# Maintainable code

::: notes

Okay, fine, that wasn't helpful

Let's approach this from a different perspective, then.

Having maintainable code is high in demand,
but it's hard to get there.

:::

## Is my code maintainable?

::: incremental

1. How much do I need to **read** to understand what’s going on?
2. How much do I need to **write** to make a change?
3. How easy is it to **identifying the core concepts**?

:::

::: notes

Here are a number of somewhat arbitrary questions to benchmark your code base

We'll use them later one on some examples

Since this is a very broad topic, the questions are very generic.
Add ones that are specific to your problem domain as needed!

:::

# What is 'Declarative Programming'

## What instead of How

Don't write down all the steps how to get somewhere

Try to express what you want to accomplish

## How?

Name concepts and group behavior

Reduce control flow

::: notes

'Declarative Programming' ≠ 'Functional Programming'

:::

## Get to the point

# Declarative code in Rust

## By example

Rust differentiates data from behavior.

Let's look at the intersection: Data transformation

# Loops

## Find the first element that ends with "m"

```rust
let xs = vec!["lorem", "ipsum", "dolor"];
for x in &xs {
  if x.ends_with('m') {
    return Some(x);
  }
}

None
```

::: notes

Since we're in Italy I thought I'd go with latin instead of "foobar".

1. How much do I need to **read** to understand what’s going on?

    trivial
2. How much do I need to **write** to make a change?

    depdends
3. How easy is it to **identifying the core concepts**?

    `for` `if` `return` <- a lot of control flow!

:::

## New requirements! Find up to 5 elements that end with "m"

```rust
let xs = vec!["lorem", "ipsum", "dolor"];
let mut result = Vec::new();
for x in &xs {
  if result.len() <= 5 && x.ends_with('m') {
    result.push(x);
  }
}
result
```

::: notes

1. How much do I need to **read** to understand what’s going on?

    It's okay if you're used to reading this code of code?
    nuances in the details: find that `5`, parse `<=` correctly
3. How much do I need to **write** to make a change?

    depends on the change: maybe a lot
4. How easy is it to **identifying the core concepts**?

    find elements up to a limit?

DONT SAY: We totally forgot about short circuiting after we've found 5 elements!
:::

## Iterators

```rust
let xs = vec!["lorem", "ipsum", "dolor"];
xs.iter()
  .filter(|item| item.ends_with('m'))
  .take(5)
  .collect()
```

::: notes

1. How much do I need to **read** to understand what’s going on?

    4 lines
2. How much do I need to **write** to make a change?

    add combinators, names very similar to other PLs
3. How easy is it to **identifying the core concepts**?

    The method names are the concepts used!

And this is even faster than the loop we've just written:
Iterators are lazy. This will stop after the 5th matched element,
but in our loop we forgot to write the early return!

So we have not only abstracted over the manual iteration
but by declaring our intent to only want 5 elements
our abstraction was able to do the early return for us, too.

:::

# Parse JSON

## First try

```rust
let v: serde_json::Value =
    serde_json::from_str("{\"a\": 4}")?;

if let Some(value) = v["a"].as_u64() {
    println!("{}", value);
}
```

::: notes

Simple enough; it's a trivial example after all.

1. How much do I need to **read**?
    Four lines: understanding `v["a"].as_u64()`
2. How much do I need to **write** to make a change?
    Now it gets interesting: It depends!
3. How easy is it to **identifying the core concepts**?
    Too little code to tell what the core concept is really.

:::

- - -

## New requirements! This structure now has three fields

```rust
struct Response { a: u64, b: u64, c: u64 }

let v: serde_json::Value =
    serde_json::from_str("{\"a\": 4, \"b\": 8, \"c\": 15}")?;

let a = if let Some(value) = v["a"].as_u64() {
    value
} else {
    return Err("invalid".into())
};

let b = if let Some(value) = v["b"].as_u64() {
    value
} else {
    return Err("invalid".into())
};

let c = if let Some(value) = v["c"].as_u64() {
    value
} else {
    return Err("invalid".into())
};

let res = Response { a, b, c };
```

::: notes

Okay, now it got complicated.

And it will get worse when we add more fields!

But is it really necessary?
This looks very generic and not specific to our _actual_ problem.

1. How much do I need to **read**?
    Lots
2. How much do I need to **write** to make a change?
    Lots
3. How easy is it to **identifying the core concepts**?
    `if let Some()` whatever

:::

## Derive it.

```rust
#[derive(Deserialize)]
struct Response { a: u64 }

let v: Response =
    serde_json::from_str("{\"a\": 42}")?;
```

::: notes

Wow, that's super neat!

And: This generates better code, too:
It doesn't allocate a `Value` and it has better errors, too!

1. How much do I need to **read**?
    just the struct really
2. How much do I need to **write** to make a change?
    add to the struct; maybe attributes
3. How easy is it to **identifying the core concepts**?
    yes: deserialization!

:::

# Command Line Arguments

## Plain old `std`

```rust
let args = std::env::args();
let input = args.next()
    .expect("USAGE: tool <input> <output>");
let output = args.next()
    .expect("USAGE: tool <input> <output>");
```

::: notes

Simple enough: We want our tool to read two CLI args.

Hm. Can we make it use flags instead of positional arguments?

1. How much do I need to **read**?
    lots
2. How much do I need to **write** to make a change?
    depends on what you need: a parser maybe?
3. How easy is it to **identifying the core concepts**?
    easy: argument positions

:::

## getopts

```rust
let mut opts = Options::new();
opts.optopt("o", "", "set output file name", "NAME");
let matches = match opts.parse(&args[1..]) {
    Ok(m) => { m }
    Err(f) => { panic!(f.to_string()) }
};
let output = matches.opt_str("o");
let input = if !matches.free.is_empty() {
    matches.free[0].clone()
} else {
    print_usage(&program, opts);
    return;
};
```

::: notes

This is quite a lot of stuff.
I wonder if there is way to abstract over it?

1. How much do I need to **read**?
    lots
2. How much do I need to **write** to make a change?
    not so much
3. How easy is it to **identifying the core concepts**?
    argument types have names, but parsing their content is up to you

:::

## Clap

```rust
let matches = App::new("My Super Program")
    .arg(Arg::with_name("output")
        .help("Sets a output file")
        .short("o").long("output")
        .takes_value(true))
    .arg(Arg::with_name("INPUT")
        .help("Sets the input file to use")
        .required(true).index(1))
    .get_matches();

if let Some(input) = matches.value_of("INPUT") {
    // ...
}
```

::: notes

This is pretty good already.
Somehow, we are back to writing code that converts data, though.
Weird.

1. How much do I need to **read**?
    glance over it
2. How much do I need to **write** to make a change?
    little
3. How easy is it to **identifying the core concepts**?
    easy! but parsing their content is up to you

:::

## Isn't this a data structure, too?

## Derive it.

```rust
#[derive(StructOpt)]
struct Cli {
    /// Sets the input file to use
    input: String,
    /// Sets a output file
    #[structopt(short = "o", long = "output")]
    output: String,
}
```

::: notes

Woah. This is super concise.

1. How much do I need to **read**?
    glance at the struct
2. How much do I need to **write** to make a change?
    add a field, maybe attributes
3. How easy is it to **identifying the core concepts**?
    super easy: the type conversions – incl. Option and Vec – are front and center

Subcommands = enums.

:::

# Generic, type-driven behavior

## Huh?

We write generic functions

and the concrete types will declare what the user wants

::: notes


:::

## Read JSON data from a HTTP request

```rust
fn handle_login(req: Request) -> Response {
    let data: serde_json::Value =
        serde_json::from_reader(req.body())?;
    let name = data["name"].as_str().unwrap_or("Nobody");
    Ok(format!("hello, {}", name))
}
```

::: notes

1. How much do I need to **read**?
    Here: 3 lines
2. How much do I need to **write** to make a change?
    Depends: Three lines at minimum it seems
3. How easy is it to **identifying the core concepts**?
    Okay-ish. There is a data structure in there, and we expect a `name` to be present.

:::

## Extractors

```rust
fn handle_login(data: Json<LoginData>) -> Response {
    Ok(format!("hello, {}", data.name))
}
```

::: notes

This is from actix-web, but Rocket has something similar, and Aaron's tide uses extractors, too

How does this work?

- `Json` is a type that implements the `FromRequest` trait
- Allows you to express which data you want extracted
- Composition: Tuples of extractors

1. How much do I need to **read**?
    Function signature
2. How much do I need to **write** to make a change?
    data type, function signature
3. How easy is it to **identifying the core concepts**?
    easy: signature specifies you want to extract JSON data

:::

# Magic budget

- - -

![](TODO.jpg "Any sufficiently high abstraction is indistinguishable from magic.")

::: notes

Beware of a project's "Magic budget"

cf. [weirdness budget](https://www.movellas.com/de/blog/show/201207181556092857/building-worlds-and-the-weirdness-budget)
and Steve's post [Language Strangeness Budget](https://words.steveklabnik.com/the-language-strangeness-budget)

:::

## Monads

. . .

“This is RustFest, Pascal, not Haskell Symposium”

::: notes

I'm kidding, I'm kidding!

:::

## What is magic?

Code whose behavior is hard to predict (or remember)

> - Macros you don't understand yet
> - Very generic code
> - But also: Very concise and 'clever' code

::: notes

In general, things that are 'unusual' to us can appear as though they are magic

Have empathy towards your coworkers who might be used to different things than you are

:::

## You can turn that magic into science, using the right tools

e.g. using `cargo expand`

. . .

That often only moves the complexity but doesn't resolve it

::: notes

people need to learn the tools and remember to use them

:::


# Thanks!

- - -

## Have a great lunch!

I'm Pascal and I want you to talk to me!

{[twitter],[github]}.com/killercup

Slides: [git.io/declarative-programming-in-rust](https://git.io/declarative-programming-in-rust)
