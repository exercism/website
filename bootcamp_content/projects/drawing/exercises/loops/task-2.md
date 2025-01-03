Nice work!

Now we need to handle the situation where we **do** know the person's name.

Sometime's the name will be empty (`""`) in which case we want to continue returning `"One for you, one for me."`, but other times `name` will contain a name, in which case we want to include it in the return value (e.g. `"One for Jeremy, one for me."`).

Remember, you can join multiple strings together using the `join_strings(...)` function.
