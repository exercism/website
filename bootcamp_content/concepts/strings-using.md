# Introduction to Strings

I once stood in front of an audience of 250 medical doctors, giving a brief introduction to programming. I got about 30 minutes into talking before someone put their hand up and said “Sorry, I have no idea what a String is”. I had to start the talk again…

Strings are one of the most fundamental concepts in programming (so fundamental I forgot someone could not know what they are), and they’re quite simple (at least initially), but they’re worth ensuring you have a clear mental model of, as they trip people up.

## What are Strings?

A string is a piece of text. It can be a mixture of letters, numbers, or symbols. It can be a single character, a word, a sentence, or even a whole essay.

In this course, whenever we draw strings in diagrams, we represent them as pieces of paper with writing on. Rather than an abstract concept, try and thing of a strings as these pieces of paper - something you can pick up and hold.

<img src="https://assets.exercism.org/bootcamp/diagrams/sample-strings.png" class="diagram"/>

## Using Strings

To create a string we wrap the text in a pair of double-quotation marks (`”`).

<img src="https://assets.exercism.org/bootcamp/diagrams/string-literals.png" class="diagram"/>

Whenever we want to use text in our programs, we use a string. For example, if we’re drawing and we want to change the colour of our pen to blue, we’d want to use the `change_pen()` function and give it the string `“blue"` as an input.

<img src="https://assets.exercism.org/bootcamp/diagrams/using-strings-in-a-function.png" class="diagram"/>

### Strings with number in vs numbers

In programming, both of these are valid: `42` and `"42"` . The first is a number, the second is a string. When would we use each?

Well, it comes down to how we’re using it. If we’re doing something where we want to use it as a number, like adding to it, or using it as a coordinate, then we want to use a number (without quotes). If we’re using it as text rather than the value of the number we would use a string instead. For example, the White House’s zip code “20500” doesn’t really have any meaning as a number - it’s a piece of text used to signify something, not a numerical value we’d use mathematically, so it’s a string.

<img src="https://assets.exercism.org/bootcamp/diagrams/numbers-vs-strings.png" class="diagram"/>

```exercism/note
There are times that we want to use a string as a number. For example, we might want to replace all the coffee machines in the odd-numbered hotel rooms. In those situations, we might need to convert a string to a number. This is very simple to do, and we’ll cover it later, so don’t get too caught up in the possibly scenarios for now!
```

```exercism/note
As you move into other languages, you’ll see that sometimes they use single quotes (`’`) or backticks(`), but again we don’t need to worry about that here - just remember for now that you use a double-quotation mark to start and end a string.
```
