# Formal Robots

Welcome back to our formal robots. In the last exercise you used the `Robot` and the `FormalConversation` classes to hold a conversation.
This time you need to create them yourself!

The actual code to solve the exercise is written and locked - your job is to provide the classes it needs to work.

There's only one external thing you need and that's the ability for the robots to speak, which we've provided in a function called `vibrate_air(name, utterance)`.
It takes two inputs, the name of a Robot, and the words it speaks. When you want your robot to speak, you should use this function. It should only appear once in your code!

The `Robot` class differs slightly to the last exercise as its constructor takes two inputs, the `name` and `age`.

Also the `participant_2_name` property has changed to become a method called `get_participant_name(idx)`, which takes the participant's index (`1` or `2`) as the input.

## Instructions

Create the `Robot` and `FormalConversation` classes.

When the `exchange_salutations()` method is called, it should result in the first robot saying `"Hello ⚡☂♞✿☯."` and the second saying `"Hello ✦☀♻❄☘."`.

When the `exchange_valedictions()` method is called, it should result in the first robot saying `"Goodbye ★⚔♠✧❀."` and the second saying `"Goodbye ♜⚙❖☾✺."`.

## Library Functions

This exercise requires you to have a [`my#number_to_string`](/bootcamp/custom_functions/number_to_string/edit) function.
