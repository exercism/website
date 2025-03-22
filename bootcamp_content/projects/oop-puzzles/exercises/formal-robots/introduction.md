# Formal Robots

In this exercises, you're going to host two short conversations between two formal robots.

The aim of this exercise is to get your familiar and comfortable with creating objects and using methods.

You have two Classes to use:

### The `Robot` class.

The `Robot` class represents a robot. It provides one method:

- `say(string)`: Says whatever you tell it to.

It also has a readonly property:

- `age`: The robot's age.

### The `FormalConversation` class.

Robots have very complex and formal social interactions and follow a specific set of rules when saying hello and goodbye.

Fortunately for you, there is a helpful class called `FormalConversation`, which encapsulates all the details.
The `FormalConversation`'s constructor takes two inputs - the two robot objects that are having the conversation.

This class has three methods:

- `exchange_salutations()`: Cause the robots go through their formal hello process.
- `exchange_valedictions()`: Cause the robots go through their formal goodbye process.
- `get_participant_name(index)`: Returns the name of either the first or the second robot in the conversation (based on an index of `1` or `2`).

## The conversation(s)

Your code should output two conversations.

The rules of conversations are always that:

1. First, the robots must exchange hellos.
2. The conversation proceeds.
3. Finally, the robots must exchange goodbyes.

### Conversation 1

The first conversation is between Robot 1 and Robot 2.
They are meeting for the first time.

The second conversation is between Robot 3 and Robot 1.
Robot 3 is interested in who Robot 1 had just met.

The conversation should look like this (with different names and ages per scenario):

```
R1: [Mysterious greetings]
R2: [Mysterious greetings]
R1: I am 10 years old. How old are you?
R2: I am 15. Together we are 25 years old. Wow.
R1: Wow.
R1: [Mysterious goodbyes]
R2: [Mysterious goodbyes]

R3: [Mysterious greetings]
R1: [Mysterious greetings]
R3: Who was that?
R1: That was Nicole.
R3: [Mysterious goodbyes]
R1: [Mysterious goodbyes]
```

## Instructions

You don't need to create any specific function.
Just write out the code to hold the conversations between the robots, using the `Robot` and `FormalConversation` classes.

## Functions

You have two functions available:
`concatenate(str1, str2, ...)`: Takes 2 or more strings and return them combined into one.
`number_to_string(number)`: Takes a number and returns it as a string.
