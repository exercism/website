Change all the function calls to use variables not numbers.

For example, change:

```jikiscript
// The frame of the house
rectangle(house_left,50,60,40)
```

to

```jikiscript
set house_left to 20
set house_top to 50
set house_width to 60
set house_height to 40
rectangle(house_left, house_top, house_width, house_height)
```
