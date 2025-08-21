# Tracks Page

In this exercise, your job is to recreate the Exercism exercises page!

Retrieve the data from the Exercism API, render it beautifully onto a page, and then use JavaScript to add more functionality.

This is a complex exercise with lots of moving parts.
As always, take your time and break the problem into small chunks!
And don't be afraid to ask if you get stuck 🙂

## Instructions

There are two parts to this exercise:

1. Implement the design of the [Exercism exercises page](https://exercism.org/tracks/javascript/exercises). Can you make it as beautiful as the site?
2. Implement the JavaScript functionality - with the search bar and the status filtering.

To get started with this exercise, please ensure you have started an Exercism track (e.g. the [JavaScript Track](https://exercism.org/tracks/javascript/)) and completed the "Hello, World" exercise in the online editor. This should only take you two minutes.

Once you've done that, the exercises page should render nicely for you.

Note that the exercises render differently depending on the status! Put an exercise into each state on your track (locked, available, completed, published, in-progress, etc) to see the differences.

### The API

You can use the `fetch` method with the API endpoint `https://exercism.org/api/v2/tracks/ruby/exercises?sideload=solutions` in order to get the data you need. The response will in JSON, and contain both `exercises` and `solutions` keys.

To search for different exercises, use the `critera` query parameter (e.g. `https://exercism.org/api/v2/tracks/ruby/exercises?sideload=solutions&criteria=ruby`).

**Note:** you should **not** use the `fetchObject` method on this exercise - use `fetch` and promises instead!

### Filtering

The filtering of tracks into the different categories should be done **client-side**, meaning the logic for what goes where happens in JavaScript, not on the server.

The counts on the buttons should be updated when the data changes, and clicking the buttons should filter appropriately:

- **All**: All exercises
- **Completed**: A solution that has `published_at` or `completed_at` set.
- **Locked**: No solution, and exercise's `is_unlocked` is `false`.
- **Available**: No solution, and exercise's `is_unlocked` is `true`.
- **In Progress**: A solution where `completed_at` is null.

There's lots of subtleties to be careful of. For example, when you search, try and stay in the same tab that you're already in!

Try and get this exercise to a point you're proud of - that's what matters most!
