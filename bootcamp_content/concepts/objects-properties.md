# Objects' Properties

Objects contain data that we can read and change.

To do this we use dot notation.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-dot-notation.png" class="diagram"/>

## Getting data from a property

Let's presume we've made a person using:

```jikiscript
set jeremy to new Person("Jeremy", 41)
```

Now we want to look at that person's name (and hopefully find `"Jeremy"`) and log it out.

To start with, we need to find the correct object from the shelves.
Jiki takes the tag out of the box, identifies the object that has the same id on their tag, then expands the object and heads inside.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-properties-1.png" class="diagram"/>

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-properties-2.png" class="diagram"/>

Now he retrieves the data from the variable inside the object, just like he'd do normally.
He makes a copy of the name, then heads back out.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-properties-3.png" class="diagram"/>

Once he's back out of the object, he shrinks it down and puts it back on the shelves, then writes the resulting name onto the log.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-properties-4.png" class="diagram"/>

## Changing data from a property

Changing data works in a very similar manner.
Firsly, Jiki finds the right object, expands its, and heads inside, exactly as before.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-properties-5.png" class="diagram"/>

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-properties-6.png" class="diagram"/>

Now, he finds the data that needs updating, and updates it!

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-properties-7.png" class="diagram"/>

And finally shrinks the object back down and puts it back on the shelves.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-properties-8.png" class="diagram"/>
