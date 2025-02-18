# Bonus Tasks

Congratulations on getting this far.
Can you handle apostrophies properly, so they're only included in the middle of a word?

So for this:
`"That's the password: 'PASSWORD 123!"', cried the Special Agent. So I fled.`

Only the apostrophie in the middle of the word counts.
The mapping would be:

```text
123: 1
agent: 1
cried: 1
fled: 1
i: 1
password: 2
so: 1
special: 1
that's: 1
the: 2
```
