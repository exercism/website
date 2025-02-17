# Meal Prep

You're the sort of person that likes to pop to the shops each day to get whatever ingredients you need for dinner.
It gives you a nice excuse to stretch your legs and chat to the local shopkeeper.

Each day you choose a recipe, then check what's in the fridge, and note down what you need to buy.

Now you've decided to make your life a little easier, by writing a program to do the hard work for you!

## Instructions

Write a function called `shopping_list`.
It takes two inputs.
The first is the contents of your fridge as a list of strings.
The second are the items in the recipe, also as a list of strings.
It should return the things you need to buy, as a list of strings.

You have one function available:

- `push(list, element)`: This adds an element to a list, then returns the new list. (e.g. `push(["a"], "b") → ["a", "b"]`)

Remember to write out your method of solving this on pen and paper.
Try and replicate what you would do in the real world! Good luck and ask for help if you get too stuck!

## Hints

Stuck? Click to expand the hints below.

<details><summary>How do I compare two lists?</summary>

In JikiScript, you can't just compare two lists by writing `["a"] == ["a"]`.
Jiki will give you an error.

But do you actually want to do that?
Do you want to know if the lists are identical, or rather if they contain the same items?

You can check to see if the items in two lists are the same.
Imagine you're given two lists both containing 20 items.
If I ask you if the lists contain the same items, what are the steps you take to work that out?
The way you do that in the real world is pretty much identical to the way you do it in code.

</details>
