# Chatty Robots

In this exercises, you're going to host two short conversations between robots.

The aim of this exercise is to get your familiar and comfortable with creating objects and using methods.

The Robot class provides a few methods:

- `say_hello()`: Says hello using the formal robot hello wording.
- `say(string)`: Says whatever you tell it to.
- `say_goodbye()`: Says goodbye using the formal robot goodbye wording.

It also has some properties:

- `name`: The robot's name - readonly.
- `age`: The robot's age - readonly.

## The conversation(s)

Your code should output two conversations.

The rules of the conversation are as follows:

1. Both robots should say hello to each other.
2. The robots should have a brief conversation.
3. The robots should say goodbye.

For (1) and (3) you need to use the special hello and goodbye wording. For the rest of the conversation, you should use the `say()` function and construct the response.

### Conversation 1

The first conversation is between Robot 1 and Robot 2.
They are meeting for the first time.

### Conversation 2

The second conversation is between Robot 3 and Robot 1.
Robot 3 is interested in who Robot 1 had just met.

The conversation should look like this (with different names and ages per scenario):

```
R1: Hello!
R2: Hello!
R1: My name is Jeremy. I am 41 years old. It is nice to meet you.
R2. Nice to meet you, Jeremy! I am Nicole. I am 36 years old.
R1: Wow. Together we are 77 years old!
R2: Wow!!
R1: I hope you have a lovely day, Nicole.
R2: I hope you have a lovely day too, Jeremy.
R1: Goodbye!
R2: Goodbye!

R3: Hello!
R1: Hello!
R3: Who was that?
R1: Oh, that was Nicole.
R3: Goodbye!
R1: Goodbye!
```

## Instructions

You don't need to create any specific function.
Just write out the code to hold the conversations between the robots, using the Robot class.
