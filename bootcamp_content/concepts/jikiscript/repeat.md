# Repeat

Often, it's useful to be able to run the same few lines of code multiple times in a row. To do this we use the `repeat` keyword with a block of code.

In JikiScript we specify a "block" of code by using the `do` and `end` keywords. We give Jiki an instruction and tell him to apply that instruction to everything between the `do` and the `end`.

In other languages, we might see brackets (`{ }`) or a colon (`:`) for this, but in JikiScript it's always `do` and `end`.

<img src="https://assets.exercism.org/bootcamp/diagrams/do-end.png" class="diagram"/>

For example, if we want to move our blob one step forward and then turn left, and keep doing that until we're back where we started, we could use the `repeat` keyword with a code block (`do`/`end`) containing those two instructions:

<img src="https://assets.exercism.org/bootcamp/diagrams/repeat.png" class="diagram"/>
