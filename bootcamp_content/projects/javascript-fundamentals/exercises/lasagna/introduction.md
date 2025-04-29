# Lasagna

Welcome to the first JavaScript exercise.
In Level 12, we'll be walking through a few exercises that each focus on one or two ideas, then giving you one exercise that brings everything together.

In this exercise, you're going to write some code to help Lucian cook an exquisite lasagna from his favorite cookbook.This should feel quite straightforward for you, but give you a basic sense of working with JavaScript.

One thing to note - all the functions are prefixed with `export`. This means that they're visible outside of this file (ie we can see them and check them). You need to ensure these functions stay exported, but if you make your own helper functions, they do **not** need to be exported!

## Instructions

According to the cooking book, the expected oven time in minutes is `40`.

You have three tasks related to the time spent cooking the lasagna:

### 1. Calculate the remaining oven time in minutes

Implement the `remainingMinutesInOven` function that takes the actual minutes the lasagna has been in the oven as a _parameter_ and _returns_ how many minutes the lasagna still has to remain in the oven, based on the **expected oven time in minutes** from the previous task.

```javascript
remainingMinutesInOven(30);
// => 10
```

### 2. Calculate the preparation time in minutes

Implement the `preparationTimeInMinutes` function that takes the number of layers you added to the lasagna as a _parameter_ and _returns_ how many minutes you spent preparing the lasagna, assuming each layer takes you 2 minutes to prepare.

```javascript
preparationTimeInMinutes(2);
// => 4
```

### 3. Calculate the total working time in minutes

Implement the `totalTimeInMinutes` function that takes _two parameters_: the `numberOfLayers` parameter is the number of layers you added to the lasagna, and the `actualMinutesInOven` parameter is the number of minutes the lasagna has been in the oven. The function should _return_ how many minutes in total you've worked on cooking the lasagna, which is the sum of the preparation time in minutes, and the time in minutes the lasagna has spent in the oven at the moment.

```javascript
totalTimeInMinutes(3, 20);
// => 26
```
