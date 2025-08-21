# Next and Break

Sometimes we don't want to go through every iteration of a list in the same way.
We might come across a condition that means we want to finish the loop early or that we want to skip the rest of a certain iteration.

## The `break` keyword

When we want to immediately stop looping, we can use the `break` keyword.

Using `break` tells Jiki to immediately stop the loop and move onto whatever code comes after it.
It's a little like the `return` keyword, but it works on loops not functions, and it doesn't return a value.

<img src="https://assets.exercism.org/bootcamp/diagrams/break.png" class="diagram"/>

## The `next` (or `continue`) keyword

The `next` keyword (and its synonym `continue`) tell Jiki that you don't want to do anything else in this iteration.

This is useful to avoid wrapping code in `if` statements.
Rather than saying

```jikiscript
if something do
  // Lots of code
end
```

we can finish the **iteration** early using the `next` keyword and avoid having to indent all our other code.

```jikiscript
if not something do
  next
end

// Lots of code
```

<img src="https://assets.exercism.org/bootcamp/diagrams/next.png" class="diagram"/>
