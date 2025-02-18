# Function Arguments

To explain this concept, we’re going to use functions to draw things. And we’re going to start by looking at the `rectangle` function.

Think for a moment about what you expect to happen if you wrote a program:

```jikiscript
rectangle();
```

Your instinct is probably that’ll draw a rectangle. But go a little deeper. Where does it draw the rectangle? How big should it be? The actual answer is that if you run that program it’ll error telling you that you’ve not given it enough information.

The functions you used to solve the maze all did the same thing every time you used them. When you used `move` it always moved the character one step forward (or errored if it couldn’t). When you used `turn_left` , the character always turned left. But most of the time when we use functions, we want them to do something based on information we give them.

So let’s expand our mental image of what a functions look like, and add a version that has inputs.

<img src="https://assets.exercism.org/bootcamp/diagrams/functions-with-and-without-args.png" class="diagram"/>

You can see from the diagram, that the `rectangle` function has 4 inputs, the x and y co-ordinates it’s to be drawn at, and its width/height. When we use the function, we have to tell it what to put into those values. If we want to draw a rectangle at 10x20 with a width of 40 and a height of 70, we’d write a program that looks like:

```jikiscript
rectangle(10, 20, 40, 70);
```

This tells Jiki that when he uses the `rectangle` function, he needs to put 10, 20, 40 and 70 into the input chutes. The order is important - Jiki will put the first value you give it into the first chute, the second value into the second chute, etc.

<img src="https://assets.exercism.org/bootcamp/diagrams/using-rectangle-function.png" class="diagram"/>
