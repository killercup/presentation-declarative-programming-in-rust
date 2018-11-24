---
title: "Declarative programming in Rust"
author: Pascal Hertleif
date: 2018-09-05
categories:
- rust
- presentation
progress: true
slideNumber: true
history: true
navigation: false
controls: 0
---
# Hi, I'm Pascal Hertleif

- Dev tools team, CLI WG
- Co-organizer of [Rust Cologne]
- {[twitter],[github]}.com/killercup
- Rust-centric blog: [deterministic.space]

[Rust Cologne]: http://rust.cologne/
[twitter]: https://twitter.com/killercup
[github]: https://github.com/killercup
[deterministic.space]: https://deterministic.space/

::: notes

I've been working with Rust since early 2014,
and I've been loving every minute of it.

Right now, I'm leading the CLI working group.
Our goal is to make writing command line applications in Rust _amazing_!
If that sounds interesting, in the very next talk after lunch,
Katharina will tell you what we've been up to.

Okay.
Let's start at the beginning.

:::

# What is a computer program?

::: notes

Oh yes, the very beginning.

:::

- - -

## To make a program work,

- you tell a computer what to do,
- in tiny steps, specific instructions.

. . .

- This is imperative.
- Hard to reason about the general behavior of a program

. . .

“This is RustFest, Pascal, not AssemblyCamp”

::: notes

Let’s just say you need abstractions to not get lost completely

same as in real life

When I ask you for directions,
“take bus line 5 to foobar station” is something I can probably work with;
being told which streets to take for how many steps
will surely result in me getting lost somewhere in Rome.
At least here I can get some great coffee wherever I go.

Okay, fine, but what does that have to do with declarative programming?

Let's approach this from a different perspective, then.

:::

- - -

## Maintainable code

::: notes

Having maintainable code is high in demand,
but it's hard to get there.

:::

- - -

## Is my code maintainable?

::: incremental

1. How much do I need to **read** to understand what’s going on?
2. How much do I need to **write** to make a change?
3. How easy is it to **identify the core concepts**?

:::

::: notes

Here are a number of somewhat arbitrary questions that you can ask about a code base.

The main idea is this:
Make your code easier to reason about.

Since this is a very broad topic, these questions are very generic.
Add ones that are specific to your problem domain as needed.

:::

# What is 'Declarative Programming'

. . .

> Declarative programming is often defined as any style of programming that is not imperative.
>
> – [Wikipedia](https://en.wikipedia.org/w/index.php?title=Declarative_programming&oldid=846955022)

::: notes

Let's see what Wikipedia has to say about that.

Ah, hm. Not that helpful.

Actually:
We could start a discussion around "what _true_ declarative programming" is,
how it differs from "functional programming", and all that.

Rust is, to me, quite pragmatic:
It has functional elements,
and indeed  allows you to write code that I'd call declarative,
but also embraces mutability
and let's you write in a quite procedural style as well.

:::

- - -

## What instead of How

. . .

- Don't write down all the steps how to get somewhere
- Express what you want to accomplish

. . .

How?

. . .

- Identify concepts and extract their behavior
- Abstract over control flow
- Compose your application from smaller pieces

- - -

## Get to the point

::: notes

This is very abstract, I know.

But that's also kind of the point:

The idea is to introduce abstractions, at the right levels.

If done right, we'll end up with code that is easier to reason about.

:::

- - -

## Declarative code in Rust

::: notes

What does that mean for Rust?
Being able to _abstract_ is one of the main features of Rust.

One of its selling points is "zero-cost abstractions".
The "zero-cost-ness" is about runtime performance, however.
Being able to introduce abstractions
without having to worry about ending up with slow code
is immensely powerful.
There's no need to rewrite your high level code when need to get high performance.

:::

- - -

## By example

::: notes

This is a short talk, and I have spoken for a few minutes already.
I can't give you a recipe for instantly writing amazingly declarative code,
but I can show you some example.

I hope they inspire you.

:::

# Loops

::: notes

Working with collections like arrays and maps is I do
in practically every code base ever,
so it'll be the first example.

:::

- - -

## Find the first element that ends with "m"

```rust
let xs = vec!["lorem", "ipsum", "dolor"];

for i in 0..xs.len() {
  if xs[i].ends_with('m') {
    return Some(xs[i]);
  }
}
return None;
```

::: notes

Since we're in Italy I thought I'd go with latin instead of "foobar".

This is simple enough, imperative code.

:::

- - -

## New requirements! Find up to 5 elements that end with "m"

```rust
let xs = vec!["lorem", "ipsum", "dolor"];

let mut result = Vec::new();
for i in 0..xs.len() {
  if result.len() <= 5 && xs[i].ends_with('m') {
    result.push(xs[i]);
  }
}
return result;
```

::: notes

It's okay if you're used to reading this code of code?

Nuances in the details: find that `5`, parse `<=` correctly

And the font I use even uses ligatures make that "less than or equal" look pretty!

DONT SAY: We totally forgot about short circuiting after we've found 5 elements!

:::

- - -

## Iterators

```rust
let xs = vec!["lorem", "ipsum", "dolor"];
xs.iter()
  .filter(|item| item.ends_with('m'))
  .take(5)
  .collect()
```

::: notes

Look at this.
It does the exact same thing as the code before,
but gives names to the concepts we've just talked about.
This might be harder to read if you're not used to it,
but it gets better once you've seen this style a few times.

The method names are the concepts used!

And this is faster than the loop we've just written:
Iterators are lazy. This will stop after the 5th matched element,
but in our loop we forgot to write the early return!

So we have not only abstracted over the manual iteration
but by declaring our intent to only want 5 elements
our abstraction was able to do the early return for us, too.

Also note:
This is not specific to the collection type we are iterating over,
not the type we're collecting into!

:::

- - -

## Another iterator example

Is there an item that starts with "l"?

```rust
let answer = xs.iter()
    .any(|item| item.starts_with('l'));
```

- - -

# Parse JSON

`{"a": 4}`

::: notes

The next example is about parsing data.
Here, from a string of JSON, into something we can use in our code.

:::

- - -

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

:::

- - -

## New requirements!

This structure now has three fields

```rust
let v: serde_json::Value = serde_json::from_str(
    "{\"a\": 4, \"b\": 8, \"c\": 15}"
)?;

struct Response { a: u64, b: u64, c: u64 }

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
You don't have to read all that.

_scroll through code_

And it will get worse when we add more fields!

But is it really necessary?
This looks very repetitive and not specific to our _actual_ problem.

:::

- - -

## Derive it.

```rust
#[derive(Deserialize)]
struct Response { a: u64, b: u64, c: u64 }

let v: Response = serde_json::from_str(
    "{\"a\": 4, \"b\": 8, \"c\": 15}"
)?;
```

::: notes

Wow, that's super neat!

We just said _what_ we wanted to happen:
Deserialize something into this struct.

And: This generates better code, too:
It doesn't allocate a `Value` and it has better errors, too!

:::

- - -

# Command Line Arguments

::: notes

Did I mention I spent a lot of time thinking about CLI apps this year?
So I obviously had to include an example from that area, too.

:::

- - -

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
So we read the first two entries in the global `args`.

Hm. Can we make it use flags instead of positional arguments?

:::

- - -

## New requirements: Flags

`tool -o Output.file Input.file`

```rust
use getopts::Options;

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
3. How easy is it to **identify the core concepts**?
    argument types have names, but parsing their content is up to you

:::

- - -

## Clap

```rust
use clap::{Arg, App, SubCommand};

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
3. How easy is it to **identify the core concepts**?
    easy! but parsing their content is up to you

:::

- - -

## Isn't this a data structure, too?

. . .

```rust
use structopt::StructOpt;

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
3. How easy is it to **identify the core concepts**?
    super easy: the type conversions – incl. Option and Vec – are front and center

Subcommands = enums.

:::

- - -

# Generic, type-driven behavior

::: notes

Okay, after these few example,
I think it's time to look at something a bit different.
To make this a crescendo of increasingly complex examples,
I gave it a complicated looking headline, too.

:::

- - -

## Huh?

We write generic functions.

The concrete types will declare what the user wants

- - -

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
3. How easy is it to **identify the core concepts**?
    Okay-ish. There is a data structure in there, and we expect a `name` to be present.

:::

- - -

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
3. How easy is it to **identify the core concepts**?
    easy: signature specifies you want to extract JSON data

:::

- - -

# Be aware of your magic budget

- - -

!["Any sufficiently high abstraction is indistinguishable from magic."](images/sudden-clarity.jpg){.stretch}

::: notes

Beware of a project's "Magic budget"

cf. [weirdness budget](https://www.movellas.com/de/blog/show/201207181556092857/building-worlds-and-the-weirdness-budget)
and Steve's post [Language Strangeness Budget](https://words.steveklabnik.com/the-language-strangeness-budget)

Trying to hit the right level of abstraction is hard.

:::

- - -

## Monads

. . .

“This is RustFest, Pascal, not Haskell Symposium”

::: notes

I'm kidding, I'm kidding!

:::

- - -

## What is magic?

Code whose behavior is hard to predict (or remember)

> - Unfamiliar macros
> - Very generic code
> - But also: Very concise and 'clever' code

::: notes

In general, things that are 'unusual' to us can appear as though they are magic

Have empathy towards your coworkers who might be used to different things than you are

:::

- - -

## You can turn that magic into science, using the right tools

e.g. using `cargo expand`

. . .

That often only moves the complexity but doesn't resolve it

::: notes

people need to learn the tools and remember to use them

:::

- - -

## How to teach this?

> - Interactive learning: Clippy lints
> - Write libraries that provide easy to use abstractions
> - Give an introductory talk on it (👋)


::: notes

This is a topic that I've been thinking about a lot over the last few years.
Especially after seeing approaches from functional programming
becoming more mainstream.

So I asked myself:
If a lot of the advantages of declarative programming only come into tuition
when you can recognize the patterns,
how can I show them to more people?

Clippy is a set of additional lints for your Rust code.
If you like Rust's error messages, you'll love Clippy.
Some time ago I opened an issue there to suggest
replacing simple `for` loops with iterators;
e.g. for the cases we've seen earlier.
Telling people about this after they've just written their code
sounds like a good opportunity to teach them an alternative style.

There are a lot of opportunities to provide these kinds of abstractions
in your own libraries.
Offering iterators or builders around data transformation, for example.
In general, just making sure the concepts you have in mind
or that your users need to have in mind
are expressed in the code.

Last but not least:
Give a talk about declarative programming.
Which you just listened to!
I hope you liked it
and I hope you can apply some of this tou your own code bases.

:::

- - -

# Thank you!

- - -

## Have a great lunch!

I'm Pascal and I want you to talk to me!

{[twitter],[github]}.com/killercup

Slides: [git.io/declarative-programming-in-rust](https://git.io/declarative-programming-in-rust)
