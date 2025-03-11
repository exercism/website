# LLM Response

In this exercise, we follow the same pattern as we did in the Lookup Time exercise - using the `fetch` function to get some data.
But this time we're going to do a little more processing of that data!

Imagine you're building a website where someone has asked the question: "What's the best percentage cocao in chocolate?"
You use the API of an LLM (like ChatGPT) to get a response back.
Then you transform that response into a sentence.

### Instructions

Create a function called `ask_llm` that takes one input - the question to ask.

Use the `fetch(url, parameters)` function to hit the API at `"https://myllm.com/api/v2/qanda"`. The parameters should be a dictionary with one key/value pair for `"question"`.

Explore the data you get back using `log` then transform it into the following format:

```jikiscript
"The answer to 'Who won the 1966 Football Men's World Cup?' is 'England' (100% certainty in 0.5s)."
```

Finally, return that string.

A couple of notes:

- You will receive multiple possible answers. Choose the one that the LLM has the highest certainty about.
- `0.78` as a decimal is the same as `78%` as a percentage.
- `123ms` is the same as `0.123s` (there are 1000 miliseconds in a second).

## Library Functions

This function will probably benefit from your [`my#contains`](/bootcamp/custom_functions/contains/edit) library function!

## Functions

You have a few functions you can use

- `concatenate(str1, str2, ...)`: Takes 2 or more strings and return them combined into one.
- `string_to_number(str)`: Takes a string and returns it converted to a number. The string must only contain digits.
- `number_to_string(num)`: Takes a number and returns it converted to a string.
