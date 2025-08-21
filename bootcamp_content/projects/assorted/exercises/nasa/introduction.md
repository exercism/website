# NASA Images

In this exercise, we're going to make a form that allows users to search the NASA image database and render the result.

**Important Note:** Remember to click "Run Code" each time before submitting the form (both in your code and the example, else the JavaScript won't run and the form submit will just reset the page).

## Instructions

There are two steps to this exercise:

1. Create the form, and intercept the `submit` event via JavaScript.
2. Query the NASA API and update the image and text accordingly.

## Forms

Your form has one input (with `type` of `search`) and a button.
You should intercept the `submit` event, then handle things in there. Remember to `preventDefault` on the event!

## The NASA API

The endpoint to use is:

```
https://images-api.nasa.gov/search
```

You need to provide query parameters such as `media_type=image` and `q=...`, where the ... should be replaced by what someone types into the box.

You should also URI encode what they type to make sure it's valid as part of a URL. See [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent) for more details!

A sample URL might look like this:

```
https://images-api.nasa.gov/search?q=curiosity%20surface&media_type=image
```

Remember the format for `fetchObject`:

```javascript
fetchObject(url, options, successFunction, errorFunction);
```

There are no options needed for this API, so that can always be `{}`.

## Extending this exercise

You could choose to extend this in lots of ways. A good starting point would be to handle what happens if there are no results - currently in the example nothing happens.

You could also extend the search, adding drop downs for years, or a selector for keywords or location.

To get started, try the example and search for `curiosity surface` or `red dwarf` or `lecture`. Consider how you could arrange the UI to fit around the components differently!

Have fun, be curious, and enjoy experimenting!
