# 📚 OriLang Beginner Learning Path

> A structured, step-by-step guide to learning OriLang — from your first `say` to building
> real programs with functions, arrays, and HTTP requests. **16 ordered lessons** with
> learning goals, runnable code samples, explanations, exercises, and troubleshooting tips.

---

## Table of Contents

- [Before You Start](#before-you-start)
- [How to Use This Guide](#how-to-use-this-guide)
- [Step 1 — Hello, World! (Printing Output)](#step-1--hello-world-printing-output)
- [Step 2 — Comments](#step-2--comments)
- [Step 3 — Variables and Types](#step-3--variables-and-types)
- [Step 4 — Strings and Concatenation](#step-4--strings-and-concatenation)
- [Step 5 — Arithmetic and Operators](#step-5--arithmetic-and-operators)
- [Step 6 — Boolean Logic](#step-6--boolean-logic)
- [Step 7 — Conditionals with `when`](#step-7--conditionals-with-when)
- [Step 8 — Chained Conditionals (`else when` / `else`)](#step-8--chained-conditionals-else-when--else)
- [Step 9 — Loops with `loop`](#step-9--loops-with-loop)
- [Step 10 — Nested Loops](#step-10--nested-loops)
- [Step 11 — Arrays: Creation and Access](#step-11--arrays-creation-and-access)
- [Step 12 — Array Iteration and Built-ins](#step-12--array-iteration-and-built-ins)
- [Step 13 — Functions: `fold` and `give`](#step-13--functions-fold-and-give)
- [Step 14 — Recursion](#step-14--recursion)
- [Step 15 — HTTP Requests with `http_get`](#step-15--http-requests-with-http_get)
- [Step 16 — Putting It All Together](#step-16--putting-it-all-together)
- [Practice Exercises](#practice-exercises)
- [Troubleshooting Common Issues](#troubleshooting-common-issues)
- [Where to Go Next](#where-to-go-next)
- [Quick Reference Card](#quick-reference-card)

---

## Before You Start

### Prerequisites

- **Git** installed on your machine
- **C compiler** — Windows: Visual Studio C++ tools (MSVC), Linux: GCC, macOS: Xcode CLT
- **curl** in your PATH (for `http_get` to work)
- **Basic programming familiarity** — you should know what variables, loops, and functions are

### Setup (one time only)

```sh
# Clone the repo
git clone https://github.com/ThanhTrucSolutions/OriLang.git
cd OriLang

# Build the toolchain
# Windows:
build.cmd

# Linux / macOS:
sh build.sh

# Verify everything works:
ori doctor
```

This builds:
1. `core/orivm` — the C-based bytecode VM
2. `tools/ori.orb` — the compiled CLI (written in Ori!)
3. `ori` — the command-line tool you'll use to run programs

### Create your first project

```sh
ori create myapp
# This scaffolds: myapp/ori/main.ori + myapp/myapp.meta

ori run myapp
# Compiles and runs your Ori program on the C VM

ori dev myapp
# Hot-reload: edit ori/main.ori and it re-runs automatically
```

---

## How to Use This Guide

- Each step has one primary **learning goal**, a **code snippet**, an **explanation**, and a
  reference to a **runnable sample file** in the [`samples/`](../samples) directory.
- Every snippet follows the [`docs/CHEATSHEET.md`](CHEATSHEET.md) syntax.
- Samples marked *runs on C VM* have been tested against `core/orivm`.
- **Do the exercises** after each section — they reinforce the concepts.
- If you get stuck, jump to [Troubleshooting](#troubleshooting-common-issues).

**Pro tip:** Open two terminals — one running `ori dev myapp` (hot-reload) and another where you
edit `ori/main.ori`. Every save triggers an instant re-run. This is the fastest way to learn.

---

## Step 1 — Hello, World! (Printing Output)

**Learning goal:** Print a value to the console using `say` and `print()`.

```ori
// Your first OriLang program
say "Hello, World!"

// With a variable
hold name = "OriLang"
say ("Welcome to " + name)
```

**Explanation**

| Keyword | Purpose |
|---------|---------|
| `say expr` | Write a value to stdout. No parentheses needed. |
| `print(expr)` | Alias for `say`. Use whichever you prefer. |
| `( ... )` | Groups a compound expression so it's passed as one argument to `say`. |

- Parentheses around `"Welcome to " + name` ensure the string concatenation happens first,
  then the whole result is passed to `say`.
- Without parentheses: `say "Welcome to " + name` would try to add the result of `say` to
  `name` — a different (and likely wrong) operation.

**Runnable:** [`samples/beginner_01_hello.ori`](../samples/beginner_01_hello.ori)

---

## Step 2 — Comments

**Learning goal:** Document your code with comments.

```ori
# This is a line comment (shebang-style)

// This is also a line comment (C-style)

/*
   This is a block comment.
   It can span multiple lines.
   Useful for documentation blocks.
*/
say "Comments are ignored by the compiler"
```

**Explanation**

OriLang supports three comment styles:
- `#` — line comment (like Python/Ruby/Shell)
- `//` — line comment (like C/JS/Go)
- `/* ... */` — block comment (like C/JS)

Use comments to explain **why** your code does something, not what it does. The code itself
should be clear enough for the "what."

---

## Step 3 — Variables and Types

**Learning goal:** Declare variables with `hold` and understand OriLang's type system.

```ori
// Declare variables of different types
hold name = "OriLang"        // string
hold version = 1.0           // number (IEEE-754 double)
hold is_fun = true           // bool (also: false, yes, no)
hold nothing = none          // nil / null value
hold scores = [95, 87, 92]   // array

// Variables are mutable — reassign with =
hold counter = 0
counter = counter + 1

// Convert between types
say ("Version " + str version)    // str converts number → string
hold num_str = "42"
hold value = num num_str          // num converts string → number
```

**Explanation**

| Type | Example | Notes |
|------|---------|-------|
| Number | `42`, `3.14`, `-7` | IEEE-754 double precision |
| String | `"hello"` | Double quotes only |
| Boolean | `true`, `false` | Also `yes` / `no` — NOT numbers |
| None | `none` | Represents absence of value |
| Array | `[1, 2, 3]` | 0-indexed, mutable elements |
| Function | (from `fold`) | First-class but no closures |

- `hold` declares a mutable variable. OriLang has no `const` or immutable bindings.
- Booleans are **not** numbers — `true + 1` is an error, not `2`.
- Use `str expr` or `string(expr)` to convert to string, `num expr` or `number(expr)` to
  convert to number.

**Runnable:** [`samples/beginner_02_variables.ori`](../samples/beginner_02_variables.ori)

---

## Step 4 — Strings and Concatenation

**Learning goal:** Join strings with `+` and use string built-in functions.

```ori
// String concatenation
hold first = "Hello"
hold second = "World"
hold greeting = first + ", " + second + "!"
say greeting                         // "Hello, World!"

// String length
hold msg = "OriLang"
say ("Length: " + len msg)           // "Length: 7"

// Additional string built-ins (available in the VM)
say (substr msg 0 3)                 // "Ori"  (start, length)
say (char_at msg 0)                  // "O"    (single character at index)
```

**Explanation**

- `+` on strings concatenates. The same `+` adds numbers — the operand types determine behavior.
- `len str` returns the string length (same built-in works on arrays too).
- String built-ins: `len`, `substr`, `char_at`, `ord` (char → code), `chr` (code → char).
- String indexing via `char_at` is 0-based.

**Runnable:** [`samples/beginner_06_strings.ori`](../samples/beginner_06_strings.ori),
[`samples/hello_concat.ori`](../samples/hello_concat.ori)

---

## Step 5 — Arithmetic and Operators

**Learning goal:** Perform calculations and comparisons.

```ori
// Basic arithmetic
hold a = 10
hold b = 3

say (a + b)       // 13    addition
say (a - b)       // 7     subtraction
say (a * b)       // 30    multiplication
say (a / b)       // 3.333 division
say (a % b)       // 1     remainder (modulo)

// Comparisons — return true/false
say (a > b)       // true
say (a == b)      // false
say (a != b)      // true
say (a >= 10)     // true
say (b <= 2)      // false

// Chained math with variables
hold x = 4
hold y = 5
hold sum = x + y
hold product = x * y
say ("4 + 5 = " + sum)
say ("4 * 5 = " + product)
```

**Explanation**

| Category | Operators |
|----------|-----------|
| Arithmetic | `+` `-` `*` `/` `%` |
| Comparison | `==` `!=` `<` `>` `<=` `>=` |
| Logical | `&&` `||` `!` (also `and` `or` `not`) |
| Assignment | `=` |

- Numbers are IEEE-754 doubles — `1 / 2` is `0.5`, not `0`.
- Built-in math functions: `abs`, `floor`, `sqrt`.
- **Operator precedence:** `* / %` bind tighter than `+ -`. Use parentheses to group.

**Runnable:** [`samples/beginner_09_math_chain.ori`](../samples/beginner_09_math_chain.ori),
[`samples/math_ops.ori`](../samples/math_ops.ori)

---

## Step 6 — Boolean Logic

**Learning goal:** Combine conditions with logical operators.

```ori
hold age = 25
hold has_id = true

// AND: both must be true
when age >= 18 && has_id {
    say "You can enter"
}

// OR: at least one must be true
hold is_weekend = true
hold is_holiday = false
when is_weekend || is_holiday {
    say "No work today!"
}

// NOT: invert a boolean
hold is_raining = false
when !is_raining {
    say "Let's go outside"
}

// Word operators also work
when age >= 18 and has_id {
    say "Same check, word-style"
}
```

**Explanation**

| Operator | Symbol form | Word form |
|----------|-------------|-----------|
| AND | `&&` | `and` |
| OR | `\|\|` | `or` |
| NOT | `!` | `not` |

- Booleans are `true` / `false` or `yes` / `no` — they are interchangeable.
- `yes` and `no` are legacy aliases kept for compatibility.
- Comparison operators (`==`, `!=`, `<`, `>`, `<=`, `>=`) produce booleans.

**Runnable:** [`samples/beginner_10_bool_logic.ori`](../samples/beginner_10_bool_logic.ori)

---

## Step 7 — Conditionals with `when`

**Learning goal:** Run a block of code only when a condition is true.

```ori
hold score = 85

// Basic when — runs once if condition is true
when score >= 50 {
    say "You passed!"
}

// Multiple independent when blocks (each checked separately)
hold n = 7
when n > 10 {
    say "big"
}
when n < 10 {
    say "small"       // this fires
}
when n == 7 {
    say "lucky seven" // this ALSO fires
}
```

**Explanation**

- `when condition { ... }` is a **conditional**, not a loop. It runs its block exactly once
  if the condition is true.
- Multiple independent `when` blocks in a row each evaluate their condition separately.
  In the example above, both "small" and "lucky seven" print because both conditions are true.
- To pick **exactly one** branch, use `else when` chaining (see Step 8).

⚠️ **Pitfall:** `when` is not `if`. Each standalone `when` is independent — multiple can fire.

**Runnable:** [`samples/beginner_04_conditionals.ori`](../samples/beginner_04_conditionals.ori),
[`samples/beginner_08_when_chain.ori`](../samples/beginner_08_when_chain.ori)

---

## Step 8 — Chained Conditionals (`else when` / `else`)

**Learning goal:** Select exactly one branch from several alternatives.

```ori
hold score = 85

when score >= 90 {
    say "Grade: A"
} else when score >= 80 {
    say "Grade: B"         // only this prints
} else when score >= 70 {
    say "Grade: C"
} else when score >= 60 {
    say "Grade: D"
} else {
    say "Grade: F"
}

// Another example
hold temperature = 15
when temperature > 30 {
    say "It's hot!"
} else when temperature > 20 {
    say "It's warm"
} else when temperature > 10 {
    say "It's cool"        // only this prints
} else {
    say "It's cold!"
}
```

**Explanation**

- `else when` chains conditions together. The **first** true branch runs and **all later
  branches are skipped**. This is the `if/else if/else` pattern from other languages.
- `else` is the catch-all fallback — it runs only when every `when` and `else when` was false.
- Compare with Step 7: standalone `when` blocks can all fire; `else when` chains pick exactly one.

**Runnable:** [`samples/when_else.ori`](../samples/when_else.ori)

---

## Step 9 — Loops with `loop`

**Learning goal:** Repeat a block of code while a condition holds true.

```ori
// Countdown from 5 to 1
hold n = 5
loop n > 0 {
    say n
    n = n - 1
}
say "blast off!"

// Sum numbers from 1 to 10
hold i = 1
hold total = 0
loop i <= 10 {
    total = total + i
    i = i + 1
}
say ("Sum 1..10 = " + total)    // 55
```

**Explanation**

- `loop condition { ... }` is a **while loop**. It checks the condition before each iteration.
- **You must update the loop variable** inside the body, otherwise the loop runs forever
  (infinite loop).
- `loop { ... }` with **no condition** runs indefinitely — it needs a `break` to stop. See
  [`samples/sum_loop.ori`](../samples/sum_loop.ori) for an example of that pattern.

**The standard counter pattern:**

```ori
hold i = 0           // initialize
loop i < limit {     // test
    // ... do work ...
    i = i + 1        // update
}
```

**Runnable:** [`samples/countdown.ori`](../samples/countdown.ori),
[`samples/sum_loop.ori`](../samples/sum_loop.ori),
[`samples/beginner_03_loops.ori`](../samples/beginner_03_loops.ori)

---

## Step 10 — Nested Loops

**Learning goal:** Put one loop inside another to handle 2D iteration.

```ori
// Multiplication table (1–3 × 1–3)
hold i = 1
loop i <= 3 {
    hold j = 1
    loop j <= 3 {
        say (str i + " × " + str j + " = " + str (i * j))
        j = j + 1
    }
    i = i + 1
}

// Count total iterations in a nested loop
hold outer = 1
hold ticks = 0
loop outer <= 3 {
    hold inner = 1
    loop inner <= 2 {
        ticks = ticks + 1
        inner = inner + 1
    }
    outer = outer + 1
}
say ("Total iterations: " + ticks)    // 6 (3 × 2)
```

**Explanation**

- The inner loop runs **completely** for each iteration of the outer loop. With outer=3 and
  inner=2, the total iterations are 3 × 2 = 6.
- **Critical:** Reset the inner counter (`j`, `inner`) at the **top of the outer body**.
  If you declare `hold j = 1` outside both loops, the inner loop only runs on the first
  pass because `j` never resets.
- Nested loops are useful for grids, tables, and multi-dimensional data.

**Runnable:** [`samples/nested_loop.ori`](../samples/nested_loop.ori),
[`samples/beginner_13_double_loop.ori`](../samples/beginner_13_double_loop.ori)

---

## Step 11 — Arrays: Creation and Access

**Learning goal:** Create arrays, access elements by index, and modify them.

```ori
// Create an array
hold fruits = ["apple", "banana", "cherry"]

// Access by index (0-based)
say fruits[0]         // "apple"
say fruits[1]         // "banana"
say fruits[2]         // "cherry"

// Modify an element
fruits[1] = "blueberry"
say fruits[1]         // "blueberry"

// Get array length
say ("Length: " + len fruits)    // 3

// Add an element to the end
push(fruits, "date")
say ("New length: " + len fruits)  // 4
say fruits[3]                      // "date"

// Remove the last element (pop is available in the VM)
// pop(fruits)
```

**Explanation**

- Arrays use square brackets: `[elem1, elem2, ...]`.
- Indexing is **0-based** — the first element is at index `0`, the last at `len - 1`.
- `xs[i]` reads an element; `xs[i] = value` overwrites it.
- `len xs` returns the number of elements. Same built-in works on strings.
- `push(xs, value)` appends to the end of the array.

⚠️ **Pitfall:** Reading past the end of an array (`xs[5]` on a 3-element array) causes a
runtime error. Always guard with `i < len xs`.

**Runnable:** [`samples/beginner_07_arrays.ori`](../samples/beginner_07_arrays.ori),
[`samples/array_push.ori`](../samples/array_push.ori)

---

## Step 12 — Array Iteration and Built-ins

**Learning goal:** Walk through an array with a loop and compute with its elements.

```ori
// Sum all elements in an array
hold numbers = [10, 20, 30, 40, 50]
hold i = 0
hold total = 0
loop i < len numbers {
    total = total + numbers[i]
    i = i + 1
}
say ("Sum: " + total)    // 150

// Find the maximum value
hold values = [7, 3, 9, 2, 11, 5]
hold idx = 1
hold max_val = values[0]
loop idx < len values {
    when values[idx] > max_val {
        max_val = values[idx]
    }
    idx = idx + 1
}
say ("Max: " + max_val)    // 11

// Count how many elements match a condition
hold scores = [85, 92, 78, 95, 88]
hold i2 = 0
hold passed = 0
loop i2 < len scores {
    when scores[i2] >= 90 {
        passed = passed + 1
    }
    i2 = i2 + 1
}
say ("A grades: " + passed)    // 2
```

**Explanation**

- The idiomatic array walk is `loop i < len arr { ... i = i + 1 }`.
- Always check `i < len arr` before accessing `arr[i]` to avoid out-of-bounds errors.
- Array built-ins: `len`, `push`, `pop`. The `pop(arr)` function removes and returns
  the last element.
- Arrays are mutable — you can update `arr[i]` in place.

**Runnable:** [`samples/intermediate_03_average.ori`](../samples/intermediate_03_average.ori)

---

## Step 13 — Functions: `fold` and `give`

**Learning goal:** Define reusable functions with `fold`, take parameters, and return
values with `give`.

```ori
// Simple function — two parameters, one return value
fold add a b {
    give a + b
}

// Function with no return value (just side effects)
fold greet name {
    say ("Hello, " + name + "!")
}

// Call functions with juxtaposition (space-separated arguments)
say (add 5 3)          // 8
greet "OriLang"        // "Hello, OriLang!"

// Function that uses conditionals
fold max_of_two x y {
    when x > y {
        give x
    }
    give y
}

say (max_of_two 10 7)  // 10
say (max_of_two 3 9)   // 9

// Legacy parenthesized call syntax also works
say (add(10, 20))      // 30
```

**Explanation**

| Keyword | Purpose |
|---------|---------|
| `fold name p1 p2 ... { ... }` | Define a function. Parameters are space-separated names — no commas, no parens. |
| `give expr` | Return a value from the function. |
| `give` (alone) | Return with no value (void). |

- **Juxtaposition:** `add 5 3` calls `add` with arguments `5` and `3`.
- **Application binds tightest:** `add 5 + 3` means `(add 5) + 3` — probably not what you
  want. Use parentheses to pass compound expressions: `add (5 + 3)`.
- Functions are **not closures** — no nested function definitions.
- The legacy form `add(5, 3)` also works and may feel more familiar coming from C/JS/Python.

**Runnable:** [`samples/beginner_05_functions.ori`](../samples/beginner_05_functions.ori)

---

## Step 14 — Recursion

**Learning goal:** Write functions that call themselves to solve problems recursively.

```ori
// Classic: Fibonacci sequence
fold fib n {
    when n < 2 {
        give n
    }
    give fib (n - 1) + fib (n - 2)
}

say (fib 10)     // 55
say (fib 20)     // 6765

// Factorial: n! = n × (n-1)!
fold factorial n {
    when n <= 1 {
        give 1
    }
    give n * factorial (n - 1)
}

say (factorial 5)   // 120
say (factorial 7)   // 5040

// Sum of first n natural numbers
fold sum_to n {
    when n <= 0 {
        give 0
    }
    give n + sum_to (n - 1)
}

say (sum_to 10)     // 55
```

**Explanation**

- A recursive function calls itself with a smaller argument until it hits a **base case**.
- The base case (`n < 2` in fib, `n <= 1` in factorial) stops the recursion and prevents
  infinite descent.
- **Critical parentheses:** `fib (n - 1)` groups the expression so `n - 1` is computed first
  and passed to `fib`. Without parens: `fib n - 1` = `(fib n) - 1` — a common mistake!
- Recursion depth is limited by the C VM's stack — very deep recursion may exhaust it.

**Runnable:** [`samples/beginner_24_factorial.ori`](../samples/beginner_24_factorial.ori)

---

## Step 15 — HTTP Requests with `http_get`

**Learning goal:** Fetch data from the internet and use it in your program.

```ori
// Fetch a public API (no key required)
hold data = http_get "https://api.coingecko.com/api/v3/ping"
say ("CoinGecko status: " + data)

// Fetch a random joke
hold joke = http_get "https://v2.jokeapi.dev/joke/Programming?type=single"
say ("Joke: " + joke)

// Fetch and store in a variable for processing
hold json = http_get "https://api.open-meteo.com/v1/forecast?latitude=21.02&longitude=105.84&current_weather=true"
say ("Weather data: " + json)
```

**Explanation**

- `http_get url` makes an HTTP GET request and returns the response body as a string.
- **Requires `curl`** to be in your PATH — the VM shells out to `curl` under the hood.
- The response is the raw body — OriLang does not have built-in JSON parsing, so you work
  with the string directly.
- All the sample APIs listed above are **free and require no API key**.

**Practical tip:** Use `http_get` with public, keyless APIs for learning. The samples in
this repo use [JokeAPI](https://v2.jokeapi.dev/), [CoinGecko](https://api.coingecko.com/),
and [Open-Meteo](https://open-meteo.com/) — all free.

---

## Step 16 — Putting It All Together

**Learning goal:** Combine functions, loops, conditionals, arrays, and recursion into
complete programs.

### FizzBuzz (function + loop + chained conditionals + modulo)

```ori
fold fizzbuzz n {
    hold i = 1
    loop i <= n {
        when i % 15 == 0 {
            say "FizzBuzz"
        } else when i % 3 == 0 {
            say "Fizz"
        } else when i % 5 == 0 {
            say "Buzz"
        } else {
            say i
        }
        i = i + 1
    }
}

fizzbuzz 20
```

### Temperature Converter (functions + conditionals)

```ori
fold celsius_to_fahrenheit c {
    give c * 9 / 5 + 32
}

fold describe_temp c {
    when c > 35 {
        give "Very hot"
    } else when c > 25 {
        give "Warm"
    } else when c > 15 {
        give "Mild"
    } else when c > 5 {
        give "Cool"
    } else {
        give "Cold"
    }
}

hold temp_c = 28
hold temp_f = celsius_to_fahrenheit temp_c
say (str temp_c + "°C = " + str temp_f + "°F — " + describe_temp temp_c)
```

### Array Statistics (arrays + loops + functions)

```ori
fold array_sum arr {
    hold i = 0
    hold total = 0
    loop i < len arr {
        total = total + arr[i]
        i = i + 1
    }
    give total
}

fold array_max arr {
    hold i = 1
    hold best = arr[0]
    loop i < len arr {
        when arr[i] > best {
            best = arr[i]
        }
        i = i + 1
    }
    give best
}

hold data = [23, 45, 12, 67, 34, 89, 7]
say ("Data: " + str data)
say ("Count: " + len data)
say ("Sum: " + array_sum data)
say ("Max: " + array_max data)
say ("Average: " + (array_sum data / len data))
```

**Runnable:**
[`samples/fizzbuzz.ori`](../samples/fizzbuzz.ori),
[`samples/intermediate_01_prime.ori`](../samples/intermediate_01_prime.ori),
[`samples/intermediate_02_gcd.ori`](../samples/intermediate_02_gcd.ori)

---

## Practice Exercises

### Beginner (Steps 1–5)

1. **Custom Greeting:** Write a program that declares a variable `name` with your name and
   prints `"Hello, <name>! Welcome to OriLang."`
2. **Simple Calculator:** Declare two numbers `a` and `b`, then print their sum, difference,
   product, and quotient.
3. **Temperature Display:** Store a temperature in Celsius, convert it to Fahrenheit using
   the formula `F = C * 9/5 + 32`, and print both values.

### Intermediate (Steps 6–12)

4. **Grade Classifier:** Given a score (0–100), use `else when` to print a letter grade:
   A (≥90), B (≥80), C (≥70), D (≥60), F (<60).
5. **Sum of Evens:** Loop from 1 to 20 and print the sum of all even numbers. Expected: 110.
6. **Array Search:** Create an array of names. Loop through it and print `"Found <name>!"`
   when you find a specific target name.
7. **Countdown with Array:** Create an array `[10, 9, 8, 7, 6, 5, 4, 3, 2, 1]`. Loop
   through it backwards and print each number followed by `"Liftoff!"` at the end.

### Advanced (Steps 13–16)

8. **GCD Function:** Write a `fold gcd a b` function using the Euclidean algorithm
   (hint: `loop b > 0 { hold t = b; b = a % b; a = t } give a`).
9. **Reverse Array:** Write a function that takes an array and returns a new array with the
   elements in reverse order.
10. **Prime Counter:** Write a function `count_primes n` that returns how many prime numbers
    exist between 2 and `n`. Use a helper function `is_prime`.
11. **API Weather Reporter:** Use `http_get` with Open-Meteo to fetch weather for your city,
    then print a formatted message like `"Current temperature in <city>: <temp>°C"`.

---

## Troubleshooting Common Issues

### ❌ "nothing printed" or "no output"

- Make sure you're using `say` or `print()` — a bare expression does not produce output.
- Check that your `.ori` file is the entry point referenced in your `.meta` file.
- Run `ori doctor` to verify your toolchain is healthy.

### ❌ `hold` vs `=` confusion

- **First assignment:** `hold x = 42` — declares the variable.
- **Reassignment:** `x = 42` — updates an existing variable.
- Using `hold` again on the same variable in the same scope is allowed but unusual.

### ❌ Application binds too tight

```ori
// WRONG — this computes (fib n) - 1
fold fib n { when n < 2 { give n } give fib n - 1 + fib n - 2 }

// RIGHT — parens group the argument expressions
fold fib n { when n < 2 { give n } give fib (n - 1) + fib (n - 2) }
```

**Rule:** when passing a compound expression as an argument, always wrap it in parentheses.

### ❌ Multiple `when` blocks all firing

```ori
// Each when is independent — BOTH may fire
when x > 0 { say "positive" }
when x > 10 { say "big" }
```

Use `else when` if you want exactly one branch to execute (Step 8).

### ❌ Infinite loop

```ori
hold i = 0
loop i < 10 {
    say i
    // MISSING: i = i + 1  ← this causes an infinite loop!
}
```

Always update the loop variable inside the body. Press `Ctrl+C` to stop a runaway program.

### ❌ Array index out of bounds

```ori
hold xs = [1, 2, 3]
say xs[5]   // CRASH: index 5 doesn't exist (valid: 0, 1, 2)
```

Always check `i < len xs` before accessing `xs[i]` — especially in loops.

### ❌ `http_get` fails silently or returns empty

- Verify `curl` is installed and in your PATH: `curl --version`
- Check your internet connection.
- The URL must be a string literal or string variable.
- Some APIs require HTTPS — make sure the URL starts with `https://`.

### ❌ Build fails on Windows

- Install Visual Studio Build Tools with the "Desktop development with C++" workload.
- Make sure you're running `build.cmd` from a **Developer Command Prompt** (or use
  `vcvarsall.bat` to set up the environment).

---

## Where to Go Next

| Resource | What You'll Learn |
|----------|-------------------|
| [`docs/CHEATSHEET.md`](CHEATSHEET.md) | Complete syntax reference — every keyword, operator, and built-in |
| [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) | How the C VM, self-hosting compiler, and CLI fit together |
| [`docs/TOOLCHAIN.md`](TOOLCHAIN.md) | Build system deep-dive — bootstrap, release builds, encryption |
| [`docs/BEGINNER_PITFALLS.md`](BEGINNER_PITFALLS.md) | More common mistakes and how to avoid them |
| [`samples/`](../samples) | All runnable samples — beginner through intermediate |
| [`CONTRIBUTING.md`](../CONTRIBUTING.md) | Build prerequisites, project structure, bounty workflow |

### Next Skill Targets

After completing this learning path, you're ready to:
- Build a **console app** with HTTP integration (see `samples/console/`)
- Create a **web app** running on WASM (see `samples/todo-app/`)
- Write your own **intermediate samples** and contribute them back to the repo
- Understand the **self-hosting compiler** (`tools/oric.ori`) — it's written in Ori!
- Explore **per-build encryption** with `ori build release` for hardened deployments

---

## Quick Reference Card

```ori
// ── Variables ──────────────────────────────
hold x = 42
x = x + 1                     // reassign

// ── Output ─────────────────────────────────
say "Hello"                   // print to stdout
print("Hello")                // alias for say

// ── Functions ──────────────────────────────
fold add a b { give a + b }   // define
add 3 5                       // call (juxtaposition)
add(3, 5)                     // call (legacy parens)

// ── Conditionals ───────────────────────────
when x > 0 { ... }
when x > 0 { ... } else { ... }
when x > 10 { ... } else when x > 5 { ... } else { ... }

// ── Loops ──────────────────────────────────
loop i < 10 { i = i + 1 }     // while-style
loop { ... }                  // infinite (needs break)

// ── Arrays ─────────────────────────────────
hold arr = [1, 2, 3]           // creation
arr[0]                         // index (0-based)
arr[1] = 99                    // mutate
len arr                        // length
push(arr, 4)                   // append

// ── Types ──────────────────────────────────
// number, string, bool (true/false/yes/no),
// none, array, function

// ── Built-ins ──────────────────────────────
say   str   num   len   push   pop
abs   floor   sqrt
http_get   ord   chr   substr   char_at
type   env   exists   run   sleep_ms
```

---

*Happy coding with OriLang! 🚀*
