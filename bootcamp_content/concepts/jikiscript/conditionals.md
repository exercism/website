# Conditionals

Often we need to only run code in certain situations.
To achieve this we use `if` statements - also known as conditionals.

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

## Joining conditions together with `and`

Finally, sometimes we might want to say "if something and something else". To achieve this we can use the `and` keyword.

Imagine a nightclub that's disco themed. Only people 21 or over dressed in Disco clothes can get it. For this we can use an `and` statement to combine the two conditions:

<img src="https://assets.exercism.org/bootcamp/diagrams/conditions-and.png" class="diagram"/>

It's important to remember that both sides of the `and` are individual conditions. Both most be comparisons that equate to `true` or `false`:

<img src="https://assets.exercism.org/bootcamp/diagrams/conditions-and-valid.png" class="diagram"/>

## Joining conditions together with `or`

In a similar way, we have an `or` keyword which we can use when we want to say `if something or something else`

Imagine our nightclub is putting on an alcohol-free event so people of any age are allowed, but everyone has to wear a ball gown or a tuxedo. To check this we can use an `or` statement to combine the two conditions:

<img src="https://assets.exercism.org/bootcamp/diagrams/conditions-or.png" class="diagram"/>

Again, both sides of the `or` are individual conditions. Both most be comparisons that equate to `true` or `false`:

<img src="https://assets.exercism.org/bootcamp/diagrams/conditions-or-valid.png" class="diagram"/>

## Joining multiple `and` and `or` together

As we progress, we might sometimes want more complex scenarios.
Imagine our formal event has an afterparty that is for 25yr olds and over. Now we have to combine the age condition with the clothes condition.

For this, we can use parentheses (`( )`) to group the conditions. So to ensure only smart-looking 25+ partygoes get in, we could write:

<img src="https://assets.exercism.org/bootcamp/diagrams/conditions-or-and.png" class="diagram"/>

---

### Next Concept: [Else Statements](./else-statements.md)
