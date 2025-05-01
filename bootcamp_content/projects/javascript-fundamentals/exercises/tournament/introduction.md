# Tournament

This exercise brings together all the elements from the first video session, and gives you a more challenging project to have fun with!

There's a couple of things you might find useful to know.

### Using `Object.keys` and `Object.values`

If you have a dictionary, and you just want to get the keys or values out, you can use `Object.keys` or `Object.values`. e.g.

```javascript
const people = {
  jeremy: { name: "Jeremy", age: 41 },
  ducky: { name: "Rubber Duck", age: 1 },
};

Object.keys(people); // Results in [ "jeremy", "ducky" ]
Object.values(people); // Results in [ { name: "Jeremy", age: 41 }, { name: "Rubber Duck", age: 1 } ]
```

### The newline character ("\n")

When working with strings, we often need to add linebreaks.
We can generally do that by inserting the special `\n` character.
e.g.

```javascript
"My name\nis Jeremy";
```

will generally get rendered as:

```text
My name
is Jeremy
```

### String Functions

In this exercise, both your input and output are strings, and it may well be useful to be familiar with some of the methods you can use.
You can see all string methods [on MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String).

### Splitting strings

You might want to split your string into pieces. You can achieve this using the [`split` method](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/split). It takes the character you want to split on.

```javascript
const name = "Jeremy Walker";
name.split(" "); // ["Jeremy", "Walker"]
```

You can pass any character in, including the newline character (`"\n"`) that's discussed above.

### Padding strings

It is often useful to be able to add whitespace (or other characters) at the start or end of strings to ensure a string is a certain length. To do this we "pad" a string, and there are some nice built-in JavaScript methods to help you: [`padStart`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/padStart) and [`padEnd`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/padEnd). The both take two inputs - the total length of the string, and the character you want to use to pad.

```javascript
const name = "Jeremy";

name.padStart(10, " "); // "    Jeremy"
name.padEnd(10, " "); // "Jeremy    "
```

## Instructions

Your job is to tally the results of a small football competition.

Based on an input string containing which team played against which and what the outcome was, create a string with a table like this:

```text
Team                           | MP |  W |  D |  L |  P
Devastating Donkeys            |  3 |  2 |  1 |  0 |  7
Allegoric Alaskans             |  3 |  2 |  0 |  1 |  6
Blithering Badgers             |  3 |  1 |  0 |  2 |  3
Courageous Californians        |  3 |  0 |  1 |  2 |  1
```

What do those abbreviations mean?

- MP: Matches Played
- W: Matches Won
- D: Matches Drawn (Tied)
- L: Matches Lost
- P: Points

A win earns a team 3 points.
A draw earns 1.
A loss earns 0.

The outcome is ordered by points, descending.
In case of a tie, teams are ordered alphabetically.

## Input

Your tallying program will receive input that looks like:

```text
Allegoric Alaskans;Blithering Badgers;win
Devastating Donkeys;Courageous Californians;draw
Devastating Donkeys;Allegoric Alaskans;win
Courageous Californians;Blithering Badgers;loss
Blithering Badgers;Devastating Donkeys;loss
Allegoric Alaskans;Courageous Californians;win
```

The result of the match refers to the first team listed.
So this line:

```text
Allegoric Alaskans;Blithering Badgers;win
```

means that the Allegoric Alaskans beat the Blithering Badgers.

This line:

```text
Courageous Californians;Blithering Badgers;loss
```

means that the Blithering Badgers beat the Courageous Californians.

And this line:

```text
Devastating Donkeys;Courageous Californians;draw
```

means that the Devastating Donkeys and Courageous Californians tied.

### Sorting

A little later in the course, we'll look at how to use the sort method on arrays.
It involves a few concepts we've not covered yet, so we've provided you with a `sort` function which sorts data as required by the exercise. When you get to the point you need to sort your data, you can come and read this properly! 🙂

To use it, pass in three inputs:

1. An array of objects representing teams.
2. The key for the points scored
3. The key for the team name

It will return a copy of the array, sorted as needed by the exercise.

e.g.

```javascript
const teams = [
  { name: "iHiD's Heros", points: 20, wins: 15 },
  { name: "DJ's Villains", points: 17, wins: 12 },
];
const sortedTeams = sort(teams, "points", "name");
```
