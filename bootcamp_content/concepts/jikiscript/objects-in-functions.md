# Using objects in Functions

When we want to use objects in functions, we do things slightly differently to how we use other data like numbers or lists.

For normal data, we make a copy before putting it into a function.
However, with objects, we input a copy of the object's **tag** instead.

This means that the function can actually change the data inside the object, affecting the rest of your code!

## Example

Let's imagine we have a very sophisticated function that looks at a person and tells you how old they will be on their next birthday.

We want to use it to log out the next birthday of a person that's been created using:

```jikiscript
set jeremy to new Person("Jeremy", 41)
```

We start by getting the function off the shelf.
Then we get the tag from the `jeremy` box, make a copy of it (remember it's a copy of the **tag**, not of the object!), and input it into the function.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-in-functions-1.png" class="diagram"/>

Next, Jiki heads inside, retrieves the tag from the input chute and puts it in a new box:

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-in-functions-2.png" class="diagram"/>

Now when we want to use that object to get the age, Jiki retrieves the tag, and heads back out the function to find the object.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-in-functions-3.png" class="diagram"/>

He finds the correct object on the Objects Shelf and expands it ready to look inside.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-in-functions-4.png" class="diagram"/>

Now he heads inside, finds the age, makes a copy of it, and heads back out.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-in-functions-5.png" class="diagram"/>

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-in-functions-6.png" class="diagram"/>

He shrinks the object back down and puts it back on the shelves (because he always likes to keep things neat), then heads back into the function, does a little mental arithmetic, and puts the resulting value into the chute.

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-in-functions-7.png" class="diagram"/>

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-in-functions-8.png" class="diagram"/>

Finally, he retrieves the value from the function, and writes it on out to the log!

<img src="https://assets.exercism.org/bootcamp/diagrams/objects-in-functions-9.png" class="diagram"/>
