# Squares

We now have an emoji collecting blob that can successfully avoid 💩 and 🔥.
Before we go and raise investment for our genius invention, we've decided to "upgrade" the code to use Objects.

Previously, when you used `look(direction)` you would get a emoji back representing what was going on.
That was a little odd as some of the emojis had meaning (e.g. `"⭐"` or `"🏁"`) whereas others were available for you to pick up.

To make things clearer, we've now changed the way `look` works.
Rather than returning a string back, it now returns an object that is an instance of the `Square` class.

The object has a few properties you can use:

- `is_start`: A boolean representing whether this is the start square.
- `is_finish`: A boolean representing whether this is the finishing square.
- `is_wall`: A boolean representing whether this is the all square.
- `in_maze`: A boolean representing whether the square you're asking about is in the maze.
- `contents`: A string containing an emoji, or an empty string.

## Instructions

Your job is to upgrade your code to make use of these new objects.
We've given you your emoji-collector code as your starting point, and left the scenarios the same as in the last exercise.

Once you've got things green, take a look for opportunities to tidy your code now the underlying data has changed.

## Library Functions

This exercise will probably need your [`my#has_key`](/bootcamp/custom_functions/has_key/edit) library function!

### Recap

Special emojis. Avoid these:

- `"🔥"` (Careful!)
- `"💩"` (Ewww)

Game functions:

- `move()`
- `turn_left()`
- `turn_right()`
- `look(direction)`
- `remove_emoji()`
- `announce_emojis(dict)`
