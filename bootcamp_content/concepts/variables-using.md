# Using Variables

Having variables isn't much use if we can't do something with them. And then main thing we do with variables is use them as inputs to functions.

For example, rather than writing this:

```jikiscript
fill_color_hex("blue")
```

we can create and use a variable instead.

```jikiscript
set sky_color to "blue"
fill_color_hex(sky_color)
```

1. The first line tells Jiki to create a box with the label `sky_color` and put the string `"blue"` in it.
2. The second line tells Jiki to go get the contents of `sky_color` and use the fill_color_hex function with that as an input.

<img src="https://assets.exercism.org/bootcamp/diagrams/using-variable-1.png" class="diagram"/>
<img src="https://assets.exercism.org/bootcamp/diagrams/using-variable-2.png" class="diagram"/>
