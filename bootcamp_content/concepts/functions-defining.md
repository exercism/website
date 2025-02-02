# Defining functions

We know [what functions are](./functions-introduction) and we know [how to use them](./functions-using).
Now lets look at how to create our own functions.

Let's firstly just be clear on what it means to create our own function.
When we have some code that we want to **reuse multiple times**, but in different places in our code, or with different inputs each time, we create a function.

To do that we use the `function` keyword, give the function a name, and then have a `do`/`end` block, which contains all the code that Jiki runs when we use the function.

For example, if we want to create a machine for our Space Invaders exercise called `shoot_if_alien_above`, which combines the `is_alien_above()` and `shoot()` functions, we could define a function like this:

<img src="https://assets.exercism.org/bootcamp/diagrams/define-shoot-if-alien-above-1.png" class="diagram"/>

From this, Jiki builds a new function.
He puts the label on the function so he can find it later.
He takes the code that's between the do/end blocks and puts it on its own whiteboard ready to be used when the function is used.
Then he shrinks the function down and puts it on the function shelves.

<img src="https://assets.exercism.org/bootcamp/diagrams/define-shoot-if-alien-above-2.png" class="diagram"/>

```exercism/note
Another way of saying "creating" a function is "defining" a function.
That's a more commonly used term, but for now the key thing is to remember that when you use the `function` keyword, Jiki builds a new function and puts it on the shelf.
```

---

### Next Concept: [Inside a Function](./functions-defining-inside)
