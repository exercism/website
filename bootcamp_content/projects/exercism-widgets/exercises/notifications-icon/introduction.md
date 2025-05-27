# Notifications Icon

In this exercise, we're recreating the notifications icon that you can find on the top bar inside Exercism.

In reality it has multiple states (no notifications, single digit notifications, double-digit notifications and 100s of notifications). In this exercise we're looking at the double-digit version.

## Instructions

You can solve this using whichever properties you want.

### Centering

You need to center a lot of things in this exercise. One nifty trick to know for when you have one element centered in another is that you can use:

```
display: grid;
place-items: center;
```

### Box Shadows

This exercise uses box shadows for the first time.

You can set the correct box-shadow using this property:

```
box-shadow: 0px 4px 24px rgb(156, 130, 38);
```

**Colors:**

There are three colors used:

- Yellow: `#fff4e3`
- Red: `#EB5757`
- White: `white`

**Sizes:**

- Everything uses pixels other than the border radiuses and the outermost height of `100%`;
- Other than the font-size, everything is divisble by 5.

**Image:**

The bell icon lives at
`/bootcamp/images/notifications.svg`
