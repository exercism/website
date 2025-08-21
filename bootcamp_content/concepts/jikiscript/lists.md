# Lists

Lists are a data type that allow you to group multiple other pieces of data (strings, numbers, booleans) together.

Lists are ordered.
You can put things into them in various ways, but they stay in the order you want them to.

<img src="https://assets.exercism.org/bootcamp/diagrams/lists-intro.png" class="diagram"/>

Lists can have any number of items in them.
A list with no items in is still a list.
It is just empty.

<img src="https://assets.exercism.org/bootcamp/diagrams/lists-sizes.png" class="diagram"/>

Lists can have items of all the same data type (e.g. all strings) or a mixture of data types (e.g. a number, a string and a boolean).
Lists where everything is the same type are called homogeneous lists.

<img src="https://assets.exercism.org/bootcamp/diagrams/lists-types.png" class="diagram"/>

## Creating a list

To create a list we use square brackets.
We put an open square bracket to start (`[`), then write whatever we want in the list separated by commas, then we put a closing square bracket (`]`).

Jiki makes whatever we need to put in the list, then constructs a new list, and puts the items in it.

If we use the `set` keyword to store the list in a variable, he then puts the whole list into the variable.

<img src="https://assets.exercism.org/bootcamp/diagrams/lists-creating.png" class="diagram"/>

## Indexing into Lists

We can access specific elements in a list by using their index - their position in the list.

In JikiScript, we start counting at 1.
So the first item can be accessed via `[1]`, the second via `[2]` etc.

<img src="https://assets.exercism.org/bootcamp/diagrams/lists-index-1.png" class="diagram"/>

Jiki will scan through the list until he gets to the index you specify.
If he finds a string, number or boolean, he'll make a copy of what he finds and, if you ask him to, store it in a box.

<img src="https://assets.exercism.org/bootcamp/diagrams/lists-index-2.png" class="diagram"/>

## Updating elements by index

We use a similar syntax to change what is in each position of the list.

If we want to change the item in the third slot, we could say `change list[3] to ...`.
Jiki would scan through the list, find the third item, and replace it with whatever you ask him to.

<img src="https://assets.exercism.org/bootcamp/diagrams/lists-changing-elements.png" class="diagram"/>
