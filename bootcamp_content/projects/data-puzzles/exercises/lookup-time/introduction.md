# LLM Response

This exercise is the first in a series of exercises that explore using APIs. The aim of these exercises is to get you familiar with the process of using APIs and manipulating the data you get back.
You'll be using lots of dictionaries and lists, transforming strings to numbers (and maybe back again) and then piecing things together into a sensible response.

In this first exercise, we're using a simple API to get a single value back, which we return as part of a short sentence.

To do this, we're using a function called `fetch(url, params)`.
The fetch function expects the URL of the API it's supposed to talk to, and any parameters that need to be given to that API.
Parameters are always a dictionary.
If there are no parameters, the dictionary should be empty.

The `fetch` function will return a different response for each API.
You should always use `log` to see what response you get back and work out how to process it. We call this process "parsing" (e.g. "I'll parse this data to get the sentence I need out").

## Instructions

Create a function called `get_time` which takes a city as its input, uses an API to get the time in that city, then returns it as part of a string.

The URL of the API is `"https://timeapi.io/api/time/current/city"`.
The params for `fetch` should have one key `city` set to the string that's passed into `get_time`.

You should turn that response into a string formatted like: `"The time on this Sunday in Amsterdam is 00:28"`

## Library Functions

Try using your [`my#has_key`](/bootcamp/custom_functions/has_key/edit) function in this exercise.
If you've not activated it yet, now's a great time to go and do that!

## Functions

You have two functions:

- `fetch(url, params)`
- `concatenate(str1, str2, ...)`: Combines two or more strings and returns the result.
