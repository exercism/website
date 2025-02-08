# Socks

There's little in life more annoying than having odd socks where you can't find its partner.
So one day you finally decide to sort those socks out!

You get all of the clean clothes from your drawers and put them into one basket.
Then you go searching under every surface and behind every cushion to find any other clothes lying around, and put them in a second basket of tidy items.

You now have two baskets and want to go through, finding whether each sock has a pair or not.

## Instructions

Write a function called `matching_socks`.
It takes two inputs, the dirty basket and the clean basket - both as lists of strings.
Return a list of all the pairs of socks.

For example:
- If the clean basket contains: `["left blue sock", "green sweater"]`
- And the dirty basket contains: `["blue shorts", "right blue sock", "left green sock"]` 
- You should return `["blue socks"]

The descriptions follow these rules:
- They'll always be lower case.
- They'll always be one or more words seperated by spaces.
- For things that can be pair, they will always start with `"left"` and `"right"`

You have the following functions available:
- `join(str1, str2)`: This takes two strings and returns them joined together.