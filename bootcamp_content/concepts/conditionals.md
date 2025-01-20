# Conditionals

Often we need to only run code in certain situations.
To achieve this we use `if` statements - also know as conditionals.

We specifiy the `if` keyword, then a **condition** then a block of code we want to run if that condition is `true`

<img src="https://assets.exercism.org/bootcamp/diagrams/if-statement-anatomy.png" class="diagram"/>

### Conditions

A condition is something that is either `true` or `false`.
Conditions are normally relationships between two things, such as "is this the same as that" or "is this bigger than that".

<img src="https://assets.exercism.org/bootcamp/diagrams/conditions.png" class="diagram"/>

In JikiScript there are 6 different conditions we can use:

<img src="https://assets.exercism.org/bootcamp/diagrams/conditions-table.png" class="diagram"/>

### Variables

It's most common to use a variable as part of an `if` statement.
We get the value from the box, and check how it relates to another number.

For example, imagine we're creating a Bouncer Robot to work at a nightclub.
There's a rule that everyone has to be older than 20 to be allowed in.
The code for that might look like this:

<img src="https://assets.exercism.org/bootcamp/diagrams/if-bouncer-variables.png" class="diagram"/>

### Functions

We can also use the results of functions directly in if statements

Rather than setting a variable, we can use a function to get a result, and then compare that to our condition.

For example, imagine Jiki has a list of everyone's name and age.
We can use a function where he gets someone's age based on their name.
And then he compares it to the entry critera for the club:

<img src="https://assets.exercism.org/bootcamp/diagrams/if-bouncer-functions.png" class="diagram"/>
