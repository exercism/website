# Digital Clock

Waaaaay back in Level 3, you made a digital clock.

We're going to carry on that theme in this Exercise.

## Instructions

Your job is to make a new `Clock` class.

Its constructor should take two inputs - the `hours` and `minutes` (both in 24-hour format).

It should have two methods:

- `get_railway_time()`: Returns the time in 24 hour format (`"16:42"`)
- `get_duodecimal_time()`: Returns the time in 12 hour format (`"4:42pm"`)

For example:

```jikiscript
set clock to new Clock(19, 35)
log clock.get_railway_time() // Should log "19:35"
log clock.get_duodecimal_time() // Should log "7:35pm"
```

We've given you your original code. You should reuse whatever parts you feel are appropriate and delete the rest.

Your final solution should contain the `Clock` class.

## Library Functions

This exercise might benefit from your [`my#number_to_string`](/bootcamp/custom_functions/number_to_string/edit) function.
