# Coding Fundamentals Advert

In this exercise you're going to recreate the advert for Coding Fundamentals that sits in the header of Exercism.

## Instructions

Firstly, ensure that you can see all the elements of the target. You might need to zoom out a little to do this. It should look like the image below. It doesn't matter if it's a little different on your screen as long as you can see all the elements.

<img src="https://assets.exercism.org/bootcamp/graphics/coding-fundamentals-advert-sample.png" style="width: 100%; max-width:300px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

### Properties

You can use whatever properties you feel are appropriate to solve this exercise.

Here's some notes:

- All sizes are pixels (with one possible exception noted below about making images behave). Except for font-sizes they are all divisible by 5.
- There are two purples. A lighter one for the border background (`rgb(96 79 205)`) and a darker one (`rgb(19 11 67)`). The button text is `white`.

There are two small details that might be hard to spot:

- The images have a both purple (`rgb(96 79 205)`) and white lines around them.
- The button has a border (`rgb(19 11 67)`).

### Misbehaving images

One thing that can be a bit confusing is fitting an imagine into a grid slot. If you choose to use grid to solve this exercise, then setting `width: 100%` on the images will mean they obey an grid column instructions you give.

### Page Copy

The copy on the page is:

```text
Coding Fundamentals
Video tutorials. Fun projects. Fair pricing.
A course designed to give you rock-solid programming fundamentals.  Totally new? Stuck in "Tutorial Hell"?
In 12 weeks you'll go from zero to making...
Explore Coding Fundamentals
```
