## Manual mapping in JavaScript (vs JikiScript)

In JikiScript, you learned how to iterate through a list and build a different list with the results.
In programming, this procedure is called `mapping`.
We "map" one set of things into another set of things.

For example, in JikiScript we could write some code to double an array of numbers like this:

```jikiscript
set numbers to [1,2,3]

set doubled to []
for each number in numbers do
  change doubled to push(doubled, number * 2)
end

log(doubled) //-> [2,4,6]
```

The equivelent code in JavaScript is very similar.

```javascript
const numbers = [1, 2, 3];

const doubled = [];
for (const number of numbers) {
  doubled.push(number * 2);
}

log(doubled); //-> [2,4,6]
```

There are a few changes:

- Use `const` instead of `set`
- Use `for (const xxx of xxx)` instead of `for each xxx in xxx`
- Make use of the fact that arrays can be mutated using the `push` method (rather than having to use a `push` function and change the variable each time).

But fundamentally the concept is the same.
