# Elyse's Enchantments

In this exercise we'll be working with Arrays (lists).

There are lots of properties and [methods][array_methods] on arrays.
Here are a few to consider when working on this exercise:

### length

The `length` property returns the length of the array

```javascript
const numbers = [1, "two", 3, "four"];
log(numbers.length); // => 4
```

### push

The `push()` method adds one or more elements to the end of an array and returns the new length of the array.

```javascript
const numbers = [1, "two", 3, "four"];
numbers.push(5); // => 5
log(numbers); // => [1, 'two', 3, 'four', 5]
```

### pop

The `pop()` method removes the last element from an array and returns that element.
This method changes the length of the array.

```javascript
const numbers = [1, "two", 3, "four"];
numbers.pop(); // => four
log(numbers); // => [1, 'two', 3]
```

### shift

The `shift()` method removes the first element from an array and returns that removed element.
This method changes the length of the array.

```javascript
const numbers = [1, "two", 3, "four"];
numbers.shift(); // => 1
log(numbers); // => ['two', 3, 'four']
```

### unshift

The unshift() method adds one or more elements to the beginning of an array and returns the new length of the array.

```javascript
const numbers = [1, "two", 3, "four"];
numbers.unshift("one"); // => 5
log(numbers); // => ['one', 1, 'two', 3, 'four']
```

### splice

The splice() method changes the contents of an array by removing or replacing existing elements and/or adding new elements in place.
This method returns an array containing the deleted elements.

```javascript
const numbers = [1, "two", 3, "four"];
numbers.splice(2, 1, "one"); // => [3]
log(numbers); // => [1, 'two', 'one', 'four']
```

[array_methods]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array

## Instructions

As a magician-to-be, Elyse needs to practice some basics. She has
a stack of cards that she wants to manipulate.

To make things a bit easier she only uses the cards 1 to 10 so her
stack of cards can be represented by an array of numbers. The position
of a certain card corresponds to the index in the array. That means
position 0 refers to the first card, position 1 to the second card
etc.

<!-- prettier-ignore-start -->
~~~~exercism/note
All functions should update the array of cards and then return the modified array - a common way of working known as the Builder pattern, which allows you to nicely daisy-chain functions together.
~~~~
<!-- prettier-ignore-end -->

### 1. Retrieve a card from a stack

To pick a card, return the card at index `position` from
the given stack.

```javascript
const position = 2;
getItem([1, 2, 4, 1], position);
// => 4
```

### 2. Exchange a card in the stack

Perform some sleight of hand and exchange the card at index `position`
with the replacement card provided.
Return the adjusted stack.

```javascript
const position = 2;
const replacementCard = 6;
setItem([1, 2, 4, 1], position, replacementCard);
// => [1, 2, 6, 1]
```

### 3. Insert a card at the top of the stack

Make a card appear by inserting a new card at the top of the stack.
Return the adjusted stack.

```javascript
const newCard = 8;
insertItemAtTop([5, 9, 7, 1], newCard);
// => [5, 9, 7, 1, 8]
```

### 4. Remove a card from the stack

Make a card disappear by removing the card at the given `position` from the stack.
Return the adjusted stack.

```javascript
const position = 2;
removeItem([3, 2, 6, 4, 8], position);
// => [3, 2, 4, 8]
```

### 5. Remove the top card from the stack

Make a card disappear by removing the card at the top of the stack.
Return the adjusted stack.

```javascript
removeItemFromTop([3, 2, 6, 4, 8]);
// => [3, 2, 6, 4]
```

### 6. Insert a card at the bottom of the stack

Make a card appear by inserting a new card at the bottom of the stack.
Return the adjusted stack.

```javascript
const newCard = 8;
insertItemAtBottom([5, 9, 7, 1], newCard);
// => [8, 5, 9, 7, 1]
```

### 7. Remove a card from the bottom of the stack

Make a card disappear by removing the card at the bottom of the stack.
Return the adjusted stack.

```javascript
removeItemAtBottom([8, 5, 9, 7, 1]);
// => [5, 9, 7, 1]
```

### 8. Check the size of the stack

Check whether the size of the stack is equal to `stackSize` or not.

```javascript
const stackSize = 4;
checkSizeOfStack([3, 2, 6, 4, 8], stackSize);
// => false
```
