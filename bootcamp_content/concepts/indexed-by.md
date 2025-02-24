# Indexed By

We often want to keep track of which iteration we are in while working through a loop.
One way to do this is to create a counter variable and update it in each iteration like this:

```jikiscript
set counter to 0
repeat 10 times do
  change counter to counter + 1
  // Your code
end
```

That works, but it's a little unwieldy.

Instead we can use `indexed by` in our loop like this:

```jikiscript
repeat 10 times indexed by counter do
  // Your code
end
```

This has exactly the same functionality as the first example.
It can be used for `repeat`, `repeat_...` and `for each` loops.

<img src="https://assets.exercism.org/bootcamp/diagrams/indexed-by.png" class="diagram"/>
