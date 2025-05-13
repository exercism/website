# Conditionals

## If / Else

JavaScript has quite normal if/else semantics.

<img src="https://assets.exercism.org/bootcamp/diagrams/javascript/17.png" class="diagram"/>
<img src="https://assets.exercism.org/bootcamp/diagrams/javascript/18.png" class="diagram"/>

## And/or

It also follows quite normal and/or rules, using `&&` to mean "and", and `||` to mean "or".

<img src="https://assets.exercism.org/bootcamp/diagrams/javascript/19.png" class="diagram"/>

## Ternaries

You can use ternaries in JavaScript.
They follow the pattern:

```javascript
conditional ? trueBranch : falseBranch;
```

For example, these two pieces of code are identical in meaning:

```javascript
// if/else variant
let result;
if (something) {
  result = "Yes!";
} else {
  result = "No!";
}

// Ternary
let result = something ? "Yes!" : "No!";
```
