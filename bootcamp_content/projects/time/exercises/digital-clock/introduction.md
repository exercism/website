# Digital Clock

Welcome to the Time project.

In this first exercise you're going to use two new functions that we've given Jiki:

- `current_time_hour()`: Returns the current hour using 24 hour time (e.g. 15 minutes to midnight would return `23`) as a number.
- `current_time_minute()`: Returns the current minute as a number.

Your job is to update a digital clock based on whatever numbers those functions give back.

The digital clock expects the numbers to be in a 12 hour format with an `am` or `pm` (what's called the "meridiem").

So for example:

```
7:45 -> 7:45am
19:45 -> 7:45pm
```

To display the time on the clock you use the `display_time(hour, minutes, meridiem)` function.

## Scenarios

In this exercise, we introduce different **scenarios** for the first time.

Different scenarios test that your code works in different situations. In this exercise, the current time changes in each scenario. So in one scenario, the time might be `07:45` and in another it might be `21:33`.

Once you click "Run Scenarios", click through the `1`, `2`, `3`, ... boxes to see the different scenarios and whether your code solved that scenario or not.

Your job is to write code that makes **all the scenarios work**.
