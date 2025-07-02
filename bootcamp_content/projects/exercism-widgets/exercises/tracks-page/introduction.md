# Tracks Page

In this exercise, your job is to recreate the Exercism tracks page!

Retrieve data from the Exercism API and render it beautifully onto a page. Then add a search bar with some added functionality!

## Instructions

There are two parts to this exercise:

1. Implement the design of the [Exercism Tracks page](https://exercism.org/tracks). Can you make it as beautiful as the site?
2. Implement the JavaScript functionality - with the search bar and the various resulting tracks.

To get started with this exercise, please ensure you have started an Exercism track (e.g. the [JavaScript Track](https://exercism.org/tracks/javascript/)) and completed the "Hello, World" exercise in the online editor. This should only take you two minutes.

Once you've done that, the tracks page should render nicely for you.

### The API

You can use the `fetchObject` method with the API endpoint `https://exercism.org/api/v2/tracks/` in order to get the data you need:

- To search for different tracks, use the `critera` query parameter (e.g. `https://exercism.org/api/v2/tracks?criteria=ruby`).
- To filter by joined tracks, use the `status` query parameter, set to `all`, `joined` or `unjoined` (e.g. `https://exercism.org/api/v2/tracks?status=joined`)

At a minimum in this exercise you should implement the search bar. But you might also like to add a drop-down for status to push yourself.
