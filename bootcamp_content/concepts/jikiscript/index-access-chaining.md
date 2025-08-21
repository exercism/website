# Index Access Chaining

So far you've learnt that you can use the index syntax to get specific elements out of strings or lists:

- Writing `["DJ", "Jeremy", "Bethany"][2]` gets `"Jeremy"` out of the list.
- Writing `"Jeremy"[3]` get the `"r"` out.

You can also chain accessors together.
You can do the exact same log as above and extract the `"r"` with this one liner:

```jikiscript
["DJ", "Jeremy", "Bethany"][2][3]
```

<img src="https://assets.exercism.org/bootcamp/diagrams/index-access-chaining.png" class="diagram"/>

---

These two examples of Jiki working result in the exact same output, but the second has much less work for Jiki:

<img src="https://assets.exercism.org/bootcamp/diagrams/index-access-chaining-jiki-1.png" class="diagram"/>
<img src="https://assets.exercism.org/bootcamp/diagrams/index-access-chaining-jiki-2.png" class="diagram"/>
