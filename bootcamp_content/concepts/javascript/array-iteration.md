## Array Iteration in JavaScript (vs JikiScript)

In JikiScript, you learned how to iterate through a list and do something with each item (e.g. call a function).

For example, in JikiScript we could write some code to log out all the emojis in a list:

```jikiscript
for each emoji in ["😀", "🚀", "🌱"] do
  log emoji
end

// Will log three times:
// 😀
// 🚀
// 🌱
```

The equivelent code in JavaScript is very similar.

```javascript
for (const emoji of ["😀", "🚀", "🌱"]) {
  log(emoji);
}

// Will log three times:
// 😀
// 🚀
// 🌱
```

There are a two changes:

- We use `for (const xxx of xxx)` instead of `for each xxx in xxx`
- Log is a function, not a keyword (so we use it with `()`)

But fundamentally the concept is exactly the same!

---

<img src="https://assets.exercism.org/bootcamp/diagrams/javascript/14.png" class="diagram"/>
