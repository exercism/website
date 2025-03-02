# LLM Response

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
