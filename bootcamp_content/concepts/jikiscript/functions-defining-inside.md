# Inside a function

So we have a function on our shelves called `shoot_if_alien_above()`.

What happens when we want to use the function?

Well we know to use the function, we'd write `shoot_if_alien_above()` in our code. And we know that Jiki goes and gets that function off the shelf and wheels it over.

<img src="https://assets.exercism.org/bootcamp/diagrams/use-shoot-if-alien-above-3.png" class="diagram"/>

At this point, he needs to actually get inside the function and follow the instructions you gave him about shooting the aliens. So he expands the function back up to be life-sized.
And then he gets in...

<img src="https://assets.exercism.org/bootcamp/diagrams/use-shoot-if-alien-above-4.png" class="diagram"/>

Now he's inside, he starts following the instructions on the function's whiteboard, just like he would follow the instructions on his main whiteboard outside.
He can still use any of the other functions he has access to outside.

<img src="https://assets.exercism.org/bootcamp/diagrams/use-shoot-if-alien-above-5.png" class="diagram"/>

So he runs your code, checks for an alien, and shoots it if it's there.

## Functions with Inputs

Sometimes we also need functions that have inputs.

We also tell Jiki whether the function has any inputs.
If it does we specify those with the `with` keyword.

Let's imagine we want a machine that tells us whether a time is midmight, morning, noon or afternoon. It could take two inputs (hour and minutes) and returns one of "afternoon", "morning", "midnight" or "noon".

We can tell Jiki to create a new machine with the label `time_of_day`, an input with the labels `hour` and `minutes`, and a output shoot where the machine can return the resulting string.

```jikiscript
function time_of_day with hours, minutes do
  // ...
end
```

You can think of this function as it's own little program.
It has its own whiteboard and it also has its own set of shelves on which to store variables.

And this is a very important thing to understand.
The variables Jiki uses **inside** the function are kept inside the function.
He can't use the variables from outside, and when he's finished with the function, the shelves are cleared again inside it.

So anything you want Jiki to be able to use inside the function needs to be passed in via the inputs.

Let's break down how that works.

Firstly, when you use the function, you specify what inputs you're using.
So if we want to use our `time_of_day` machine to say "What time of day is `2:50`?" you would write `time_of_day(2, 50)`.

Jiki goes and gets the function off the shelves.

<img src="https://assets.exercism.org/bootcamp/diagrams/use-time-of-day-1.png" class="diagram"/>

He puts a 2 and a 50 in, expands the function, then gets inside.

<img src="https://assets.exercism.org/bootcamp/diagrams/use-time-of-day-2.png" class="diagram"/>

<img src="https://assets.exercism.org/bootcamp/diagrams/use-time-of-day-3.png" class="diagram"/>

Once he's inside, Jiki takes the 2 and the 50 and puts them into new boxes that have the labels on the shoots.

<img src="https://assets.exercism.org/bootcamp/diagrams/use-time-of-day-4.png" class="diagram"/>

So on the first shoot we have the label "hour", so Jiki makes a new box, gives it the label "hour", puts the `2` in it, and pops it on the shelf.

<img src="https://assets.exercism.org/bootcamp/diagrams/use-time-of-day-5.png" class="diagram"/>

He then works through the code on the function whiteboard:

<img src="https://assets.exercism.org/bootcamp/diagrams/use-time-of-day-6.png" class="diagram"/>

As the hour is 2, he eventually gets to the line `return "morning"`.
The code is telling him to `return`. That means two things...

Firstly, whatever he's told to return gets pushed out the function.
In this case the string `"morning"`

<img src="https://assets.exercism.org/bootcamp/diagrams/use-time-of-day-7.png" class="diagram"/>

Secondly, it means that the function has finished.
Jiki won't run any more code in the machine.

So he cleans up, throws away any boxes off the shelves, and leaves the machine.

<img src="https://assets.exercism.org/bootcamp/diagrams/use-time-of-day-8.png" class="diagram"/>

He then collects the output from the machine and stores it in the box `time` as the code instructs him to.

<img src="https://assets.exercism.org/bootcamp/diagrams/use-time-of-day-9.png" class="diagram"/>

Finally he puts the function back on the shelf to be used later if needed.

### Think about the functions you've already used.

Take a minute to imagine what Jiki has been doing in the functions you've already used. When you've used the `circle` function, Jiki has got the machine, expanded it, gone inside, made boxes for the numbers you've input into it, drawn the circle on the canvas, then cleaned up and left again.

```exercism/note
Every language has a slightly different approach to what can and can't be access from inside functions. In fact, it's one of the things that often defines a language as been unique. Jiki takes the simplest route by keeping the variables inside the function entirely separate from the variables outside the function, and relying on you inputing things when you need them. But be aware that if you've done some programming before, this might be different from what you've previously experienced.
```
