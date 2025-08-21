# Socks

There's little in life more annoying than having odd socks where you can't find its partner.
So one day you finally decide to sort those socks out!

You get all of the clean clothes from your drawers and put them into one basket.
Then you go searching under every surface and behind every cushion to find any other clothes lying around, and put them in a second basket of tidy items.

You now have two baskets and want to go through, finding whether each sock has a pair or not.

## Instructions

Write a function called `matching_socks`.
It takes two inputs, the dirty basket and the clean basket - both as lists of strings.
Return a list of all the pairs of socks.

For example:

- If the clean basket contains: `["left blue sock", "green sweater"]`
- And the dirty basket contains: `["blue shorts", "right blue sock", "left green sock"]`
- You should return `["blue socks"]`

The descriptions follow these rules:

- They are always lower case.
- They are always one or more words separated by spaces.
- For things that can be pairs, they will always start with `"left"` and `"right"`

You have the following functions available:

- `concatenate(str1, str2)`: This takes two strings and returns them joined together.
- `push(list, element)`: This adds an element to a list, then returns the new list. (e.g. `push(["a"], "b") → ["a", "b"]`)
- `concat(list1, list2)`: This takes two lists, joins them together into one list, then returns the result. (e.g. `concat(["a"], ["b"]) → ["a", "b"]`)

## This is a challenge!

This exercise is a challenge.
It's the hardest you've had so far, and it involves writing quite a lot of code.
It is essential for you to break things down into small functions that do very specific things.

Take time to clearly write out all the steps you would take to do this in the real world.
There are probably 3 or more different approaches you could use in the real world.
Write them all out.
Think about which will be easiest in code.
Then go for that.
If it gets really tough, maybe consider if another approach might be easier.

As you work through the exercise and come across new little tasks you need to do, again pause, and write down how you would do that in the real world.

**Remember:** You can use the log word to see if something is working as you expect, so if you wrote a function called `is_frog_green` and wanted to check it does what you expect, you could do this:

```jikiscript
// Your code here

// The main function that gets called.
function matching_socks with clean, dirty do
  log is_frog_green("Ornate Horned Frog")
end
```

Then you can scroll straight to the end of the scrubber and see if that function returns what you expected.

## Hints

This exercise is tough.
If you get stuck, don't be afraid to use the hints below.
It's not cheating and they'll still leave you with lots of work to do!

<details><summary>A general piece of advice</summary>

This exercise would be a lot easier if you had some common functions available.

For example, most languages provide:

- a `length` function that tells you how long a string is.
- a `starts_with` function that tells you whether a string starts with another string.
- an `ends_with` function that tells you whether a string ends with another string.
- some sort of function that allows you to remove a certian amount of characters from the beginning or end of a string.

Starting off by adding these functions will make your life a lot easier.

Maybe you've already written those functions in other exercises and you can reuse them here?

</details>

<details><summary>The tricky middle bits</summary>

So you have your generic helper functions written out (go back to hint 1 if not!) and you now need to put them together.

Now think about the other functions you might like:

- Maybe a function to check if something is a sock
- Maybe a function that can remove the `"left "`/`"right "` prefix
- Maybe a function that can pluralize a word
- Maybe a function that can add an element to a list ifs not already on it
- Maybe a function that can switch left and right around

Your implementation might need all of these, or it might need none of them.
But try and break things into little steps like these, and **for each one** get out a pen and paper and work out what it should do.

</details>

<details><summary>The structure of a good solution</summary>

Here's an outline of a solution you might like to use

```jikiscript
function matching_socks with clean, dirty do
  // Get the clean socks
  // Get the dirty socks
  // Mix all the socks together

  // Go through each sock
  // Check the other socks for a matching one.
  // If it's there:
    // Format the word nicely
    // Add it to the final list (making sure it's not already on there)

  // Return the final list
end
```

</details>
