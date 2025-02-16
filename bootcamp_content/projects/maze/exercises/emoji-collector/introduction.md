# Emoji Collector

Last time you were in the maze, you implemented the `can_...()` functions to move around by looking around.

Previously, you checked for words when you looked around. But now we've upgraded the mazes to use emojis! So you need to update your code to handle these:

- `"⭐"` (Where you start)
- `"🏁"` (Where you're trying to get to)
- `"⬜"` (An empty space you can move into)
- `"🔥"` (Careful!)
- `"💩"` (Ewww)
- `"🧱"` (A wall)

We've also scattered some extra emojis around the mazes for you to pick up. Each time your character find an emoji that's not in the list above, it should add it to its tally.

Once you move into the finishing square (`"🏁`), you should use the `game_over(result)` function, passing a dictionary representing the amount of emojis you've collected into its `result` chute. For example, if you've collected 4x 💎s and 3x 🧠s the dictionary should be:

```
{
  "💎": 4,
  "🧠": 3
}
```

To help, you can use the `look(direction)` function with a new direction `"down"`, which tells you what's by your feet in the current square.
