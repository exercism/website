# Good Boy

In this exercise, we're going to create a little game where you can select the best dog from a selection of photos!

It'll be your first time using an API for real and also the first time you're making this sort of interactive game, so break it down into small pieces and work at each one at a time.

## Instructions

The game is a simple one.
You're shown two dogs and have to click on the one you think is the best (choose your own metric for "best"!).
Every time you click a dog, a tick should appear on it and then the other one should change to a new dog.

Play with the example to get a feel for the game (remember to click Run Code to start it off!)

### API

The API we'll be using for this lives at `https://random.dog/woof.json`.
The API does not have authentication, so you can just use `fetchObject` to retrieve the data without any options.

Remember the format for `fetchObject`:

```javascript
fetchObject(url, options, successFunction, errorFunction);
```

The API returns either images or videos.

For images, you can change the `src` attribute of an `<img />` tag to change the image. For videos, you can change the `src` of a `<video></video>` element. You might like to also set the `autoplay` and `loop` attributes on the video element.

### Design

You can design the game however you like, but try and make it feel as fun and professional as you can!

You might like to explore events like the `load` event on images or the `loadeddata` events on videos to improve the loading experience.

Most of all, have fun!
