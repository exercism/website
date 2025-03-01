# LLM Response

In this exercise, we're taking a sample response from an LLM (like ChatGPT) and getting the data out that we need.
We call this process "parsing" (e.g. "I'll parse this data to get the sentence I need out")

Imagine you're building a website where someone has asked the question: "What's the best percentage cocao in chocolate?"
You've used the LLM's API and got a response back.
You now want to transform that response into a sentence such as:

```jikiscript
"The answer to 'What's the best percentage cocao in chocolate?' is 'The deep sensations of 82% are the best' (78% certainty in 0.123s)."
```

### Instructions

Create a function called `parse_response` that takes one input - the data from the LLM.
Explore the data using `log` then work out how to transform it into the correct format.
Then return that string.

A couple of notes:

- You will receive multiple possible responses. Choose the one that the LLM has the highest certainty about.
- `0.78` as a decimal is the same as `78%` as a percentage.
- `123ms` is the same as `0.123s` (there are 1000 miliseconds in a second).
