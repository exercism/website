So far we’ve seen that Jiki can follow instructions you give him. But to actually do anything with those, we need to give the workshop it’s next element - **functions.**

Functions are like little machines that you can tell Jiki to use.

<img src="https://assets.exercism.org/bootcamp/diagrams/functions-on-shelves.png" class="diagram"/>

> Note: You might remember “functions” from when you’ve studied maths. I **strongly recommend** of thinking of these programming functions as totally different things from those mathematical ones.

Each function has a name, which is how we use it in our code In Jikiscript we write the name using lowercase letters. A name can have multiple words, in which case we separate them using an underscore.

<img src="https://assets.exercism.org/bootcamp/diagrams/anatomy-of-a-function-definition.png" class="diagram"/>

Coding is a little like lego, but rather than little plastic blocks, we have functions. The vast majority of your time coding will be creating functions to do things and then using them in other places in your programs.

To start with, we’re going to learn how to use some very basic functions. We’ve created three functions for you - the ones you can see on the shelves in the image above. They’ve all been designed to help a character navigate through a maze.

- `move` - A function that moves the character forward
- `turn_left` - A function that tells the character to turn left.
- `turn_right` - A function that tells the character to turn right

To use a function you specify its name and then two brackets - e.g. `turn_left()`

<img src="https://assets.exercism.org/bootcamp/diagrams/calling-a-function.png" class="diagram"/>

So if your program was this…

```jsx
move();
turn_left();
turn_right();
```

…Jiki would work through each of those instructions. For the first, he’d get the `move()` function off the shelf and to run it. Then he’d move onto the second line and run the `turn_left()` function.

<img src="https://assets.exercism.org/bootcamp/diagrams/using-a-function.png" class="diagram"/>

### Don’t try and remember functions!

One of the big mistakes people make when they’re learning is to try and remember all the functions they can use and the inputs they can take etc. This is a ginormous waste of your time. If there are functions that you use often, you’ll naturally remember them. But the rest of the time (and it’s like the 90% majority) you can just look them up. This is normal and expected. I look up functions all the time.

In this course, you’ll always be able to see a list of all the functions you’re expected to use in the instructions, along with a description of what they do and how to use them. And you can also replay your code and see what actually happened using the “Info” button at any time.
