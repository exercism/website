# Foreach Statements

"For each" loops allow us to iterate through a list or a string.

We step through each item in the list/string, running a block of code for each one.

The syntax follows the same patterns we've seen with `repeat` blocks and `if statements`.
This time we specify the list, and the variable name we'd like each item to have in its turn in the loop.

<img src="https://assets.exercism.org/bootcamp/diagrams/foreach-syntax.png" class="diagram"/>

## Example

Let's image we want to thank each of the mentors in turn.

Firstly, we create a list of mentors and store the list in a variable.

<img src="https://assets.exercism.org/bootcamp/diagrams/foreach-set-mentors.png" class="diagram"/>

Now we run the loop for the first item in the list - `"DJ"`.
Jiki creates a new box for the item, puts `"DJ"` into it, and stores it on the shelf.

<img src="https://assets.exercism.org/bootcamp/diagrams/foreach-step-1-1.png" class="diagram"/>

When he wants to use `"DJ"` to say thank you, he simply retrieves it from the box as normal

<img src="https://assets.exercism.org/bootcamp/diagrams/foreach-step-1-2.png" class="diagram"/>

When the iteration has finsished, he clears the box off the shelves, so everything is back how it was at the start of the loop.

<img src="https://assets.exercism.org/bootcamp/diagrams/foreach-step-1-3.png" class="diagram"/>

He then starts on the second item in the list.
He creates a new box, and puts the second item (`"Bethany"`) inside it.

<img src="https://assets.exercism.org/bootcamp/diagrams/foreach-step-2-1.png" class="diagram"/>

He runs the code block, and when he needs to access `"Bethany"`, he gets it out of the box again.

<img src="https://assets.exercism.org/bootcamp/diagrams/foreach-step-2-2.png" class="diagram"/>

### Strings

Everything works exactly the same with strings.
We take the first letter out of the string on the first iteration.

<img src="https://assets.exercism.org/bootcamp/diagrams/foreach-strings-1.png" class="diagram"/>

And can then use it whenever we need to in that iteration.

<img src="https://assets.exercism.org/bootcamp/diagrams/foreach-strings-2.png" class="diagram"/>

### Dictionaries

Dictionaries work similarly, but for each loops over the key value **pairs**, so you need to specify two variable names - one for the key and one for the value.

<img src="https://assets.exercism.org/bootcamp/diagrams/foreach-dictionaries.png" class="diagram"/>
