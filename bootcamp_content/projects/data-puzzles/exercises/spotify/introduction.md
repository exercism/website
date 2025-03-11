# LLM Response

In this exercise, we're taking a look at someone's top tracks via the Spotify API.

This API is a bit different in two key ways.

Firstly, when we look up a user's favourite tracks, rather than just getting the names back, we get a series of other URLs. We need to carry out subsequent API requests to get more information.

Secondly, the URL you use varies based on the data you use.
The base URL for the endpoint you want is `"https://api.spotify.com/v1/users/"`. But you then need to add the username of the person you're looking for on the end. So if you want to find our fred's favourite tunes, you'd use the endpoint `https://api.spotify.com/v1/users/fred`.

For this exercise, the parameters should always be an empty dictionary.

## Instructions

Create a function called `favorite_artists`.
It expects someone's username as an input.

Use the API explained above to retrieve the person's favourite artists, then combine them into a sentence like:

```jikiscript
"Fred's most listened to artists are: Glee, NSYNC, Beethoven, and Limp Bizkit!"
```

If there is an error from the API, you should return that error as a string, prefixed with `"Error: "`.

## Library Functions

This would be a good time to use your [`my#to_sentence`](/bootcamp/custom_functions/to_sentence/edit) and [`my#has_key`](/bootcamp/custom_functions/has_key/edit) library functions!

## Functions

You have three functions avaible:

- `fetch(url, params)`: Fetches data from an API.
- `concatenate(str1, str2, ...)`: Takes 2 or more strings and return them combined into one.
- `push(list, elem)`. Returns a new list with the element added to the original list.
