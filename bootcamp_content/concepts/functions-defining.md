# Defining functions

We know [what functions are](./functions-introduction) and we know [how to use them](./functions-using).
Now lets look at how to create our own functions.

Let's firstly just be clear on what it means to create our own function.
When we have some code that we want to **reuse multiple times**, but in different places in our code, or with different inputs each time, we create a function.

To do that we use the `function` keyword, give the function a name, and then have a `do`/`end` block, which contains all the code that Jiki runs when we use the function.

For example, if we want to create a machine for our Space Invaders exercise called `shoot_if_alien_above`, which combines the `is_alien_above()` and `shoot()` functions, we could define a function like this:

```
DIAGRAM:
function shoot_if_alien_above do
  if is_alien_above() do
    shoot()
  end
end
```

From this, Jiki builds a new function.
He puts the label on the function so he can find it later.
He takes the code that's between the do/end blocks and puts it on its own whiteboard ready to be used when the function is used.
Then he shrinks the function down and puts it on the function shelves.

```
DIAGRAM: Jiki making new machine + putting it on shelves.
```

We also tell Jiki whether the function has any inputs.
If it does we specify those with the `with` keyword.

Let's imagine we want a machine that tells us whether a time is midmight, morning, noon or afternoon. It could take two inputs (hour and minutes) and returns one of "afternoon", "morning", "midnight" or "noon".

We can tell Jiki to create a new machine with the label `time_of_day`, an input with the labels `hour` and `minutes`, and a output shoot where the machine can return the resulting string.

```
DIAGRAM: `function time_of_day with hour, minutes`
Show jiki adding a new function onto the function shelves. This one has two inputs and an output.
```

```exercism/note
Another way of saying "creating" a function is "defining" a function.
That's a more commonly used term, but for now the key thing is to remember that when you use the `function` keyword, Jiki builds a new function and puts it on the shelf.
```

---

### Next Concept: [Inside a Function](./variables/functions-defining-inside-pure.md)
