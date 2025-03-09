# Formal Dinner

You're back in your side hustle as a bouncer.
It's the evening after the After Party, and there's yet another shindig.
This time it's a formal dinner.

This definitely isn't the place to use **just** your first name.
In fact it isn't the place to use your first name at all.
Here, everyone goes by an honorific (Miss, Mr, Dr, etc) and their surname.

Once again, though, your list of names is just people's full names.
So when Mr Pitt turns up, you need to work out that this is the "Brad Pitt" on your guest list.

## Instructions

Write a function called `on_guest_list`.
The function has two inputs.
The first will contain the guest_list as a list of strings.
The second is the name of the person formatted as honorific and a surname.
You should return a boolean specifying whether the person is on the guest list.

For this task, you can presume that honorifics will always be one word.

### Functions

You have one function available:

- `concatenate(str1, str2)`: This takes two strings and returns them joined together.

## Hints

<details><summary>A general piece of advice</summary>

This exercise would be a lot easier if you had some common functions available.

For example, most languages provide:

- a `length` function that tells you how long a string is.
- an `ends_with` function that tells you whether a string ends with another string.

Starting off by adding these functions will make your life a lot easier.

Maybe you've already written those functions in other exercises and you can reuse them here?

</details>

<details><summary>The structure of the <code>on_guest_list</code> function</summary>

The on_guest_list function is quite similar to the easier first exercise.
A good outline would be something like this:

```jikiscript
function on_guest_list with names, person do
  // Remove the honorific from the person's name to get the surname
  // Go through each name on the list in names
    // If the name ends with person's surname, return true
  // If none of the names match, return false
end
```

</details>
