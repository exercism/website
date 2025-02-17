# Emoji Collector

Last time you were in the maze, you implemented the `can_...()` functions to move around by looking around.

### Old ideas, new emojis

Previously, you checked for words when you looked around. But now we've upgraded the mazes to use emojis! So you need to update your code to handle these:

- `"⭐"` (Where you start)
- `"🏁"` (Where you're trying to get to)
- `"⬜"` (An empty space you can move into)
- `"🔥"` (Careful!)
- `"💩"` (Ewww)
- `"🧱"` (A wall)

### New emojis!

We've also scattered some extra emojis around the mazes for you to pick up. Each time your character find an emoji that's not in the list above, it should add it to its tally.

To help we've added:

- A new direction you can look (`"down"`!). This tells you what's in the current square.
- A new function `remove_emoji()` that removes whatever emoji is on the current square from the board. Don't try and pick up a special emoji from above!

Once you move into the finishing square (`"🏁"`), you should use the `announce_emojis(result)` function, passing a dictionary representing the amount of emojis you've collected into its `result` chute. For example, if you've collected 4x 🐽s and 3x 🧠s, you should use the function like this:

```
announce_emojis({ "🐽": 4, "🧠": 3 })
```

### A helpful function

We've also added the `has_key(dictionary, key)` function, which returns a boolean stating whether or not the key exists.
So for the dictionary

```
set details to {"name": "Jeremy"}`

has_key("name") // true
has_key("age") // false
```

### Summary

In summary, you have the following functions available.

Dictionary functions:

- `has_key(dict, key)`

Game functions:

- `move()`
- `turn_left()`
- `turn_right()`
- `look(direction)`
- `collect_emoji()`
- `announce_emojis(dict)`
