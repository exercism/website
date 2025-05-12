# Comments

Often when writing code, it can be helpful to write out a load of steps that you want to do before actually writing the code itself. And as code gets more complex, annotating it to explain what’s happening can be extremely useful for both your future self and anyone else that ever looks at your code.

To achieve this we write “comments” - bits of text that are readable to you and your fellow humans, but that don’t get passed onto the computer. They get ignored in the same way that blank lines get ignored.

<img src="https://assets.exercism.org/bootcamp/diagrams/comments.png" class="diagram"/>

In JikiScript, we write comments using two forward slashes (`//`). Everything on the line after those forward slashes gets ignored. You can add them at the beginning of a line so that the whole line becomes a comment (what we call a line comment), or you can add them after your code to explain something.

If you want to explain something complex, you can put lots of comments in a row:

```javascript
// This is something quite complex so I'll write
// information about it over multiple lines. I could
// even choose to make a list using dashes or numbers:
// 1. Think of the solution
// 2. Write comments
// 3. Write code.
//
// Everything here is totally ignored by the computer.
// You can even add emojis 🎉
```
