# Hairdresser

You run a small hairdressing salon that focusses on speed over quality.
People might leave a little rough around the edges, but they're not having to spend too long in the chair.

You offer a few different services from styling to full haircuts, which take different times to complete.
You run the salon on a first-come, first-serve basis.
There's no appointment system.

As it gets towards the end of the day, you need a way of knowing if you
have time for any new people that come into the shop.

Your job is to work out how long the queue will take to get through, and whether there is time for the next person.

## Instructions

Write a function called `can_fit_in` which takes three inputs.

- The first is the haircuts that you have in the queue already (list of strings).
- The second is the haircut that the new person wants (string).
- The third is the amount of minutes left in the day (number).

Return a boolean for whether you can fit the person in.

The styles you offer are:

- Mohawk: 20 minutes
- Slicked-Back Pixie: 15 minutes
- Bob: 25 minutes
- Shave and Polish: 15 minutes
- Afro Trim: 45 minutes
- Up-do: 30 minutes
