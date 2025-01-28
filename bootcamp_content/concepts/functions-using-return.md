# Functions that return

As well as doing things, functions often return things back to Jiki.

This isn't like printing to a screen, or outputting something.
This is very specifically the function returning something to **Jiki** to use later.

Image we have a `current_time` function that gives us the current time back out as a string. When Jiki uses it, he gets a string with the time on that he can then use:

<img src="https://assets.exercism.org/bootcamp/diagrams/function-return-current-time.png" class="diagram"/>

He could do various things with this, such as store it in a variable:

<img src="https://assets.exercism.org/bootcamp/diagrams/function-return-store-current-time.png" class="diagram"/>

This works exactly the same with functions that have inputs.
Imagine a `join` function that takes two strings and joins them with a space in between:

<img src="https://assets.exercism.org/bootcamp/diagrams/function-return-join.png" class="diagram"/>

Just like before, we could ask Jiki to store the result in a variable:

<img src="https://assets.exercism.org/bootcamp/diagrams/function-return-store-join.png" class="diagram"/>
