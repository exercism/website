# Dictionaries

Dictionaries are a data type that allow you to group data into key-value pairs.
They are often used to store data about a specific thing (e.g. a person)

<img src="https://assets.exercism.org/bootcamp/diagrams/dictionaries.png" class="diagram"/>

## Keys and Values

In JikiScript, keys are always strings, so you need to remember to use double quotations.
Values can be any data type, strings, booleans, numbers, lists, more dictionaries, and other data types you've not learnt of yet.

<img src="https://assets.exercism.org/bootcamp/diagrams/keys-and-values.png" class="diagram"/>

## Creating Dictionaries

We use "braces" or "curly brackets" to start and end dictionaries.
They can be written over multiple lines.

<img src="https://assets.exercism.org/bootcamp/diagrams/dictionaries-creating.png" class="diagram"/>

## Getting data out

We get a value out of a dictionary using a key.
We use the same "index into" syntax we used for lists, with `[]` but this time we specify the key's string value, not the index.

<img src="https://assets.exercism.org/bootcamp/diagrams/dictionaries-get.png" class="diagram"/>

## Changing a value

We can change a value using the change keyword with the key we want to change.

<img src="https://assets.exercism.org/bootcamp/diagrams/dictionaries-change.png" class="diagram"/>

## Adding a new key/value

If we try and change the value of a key that doesn't exist, Jiki will just make a new one.
So we use the exact same syntax for changing an existing key as adding a new one.

<img src="https://assets.exercism.org/bootcamp/diagrams/dictionaries-set.png" class="diagram"/>
