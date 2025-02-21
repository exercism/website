# After Party

We're back to playing the role of a bouncer.
But this time, we're dealing with A-List Celebrities at the After Party.

When these people show up to your party, they expect you to know them just by their first-names.
Brad Pitt isn't going to waste his breath telling you his surname, he'll just say "Brad".

Now, you're not really into all the celebrity nonsense, so despite Brad's expectations, you have no idea who he is.
But you've been told not to make a fuss, so you just check the list to see if there's **any** Brads on there, and if there are, you let him in.

## Instructions

Write a function called `on_guest_list`.
The function has two inputs.
The first will contain the guest_list as a list of strings.
The second is the **first name** of the person you need to check.
You should return if the person is on the guest list.

## Hints

<details><summary>A general piece of advice</summary>

This exercise would be a lot easier if you had some common functions available.

For example, most languages provide:

- a `length` function that tells you how long a string is.
- an `starts_with` function that tells you whether a string starts with another string.

Starting off by adding these functions will make your life a lot easier.

Maybe you've already written those functions in other exercises and you can reuse them here?

</details>

<details><summary>The structure of the <code>on_guest_list</code> function</summary>

The on_guest_list function is quite similar to the easier first exercise.
A good outline would be something like this:

```jikiscript
function on_guest_list with names, person do
  // Go through each name on the list in names
    // If the name starts with person's first name, return true
  // If none of the names match, return false
end
```

</details>
