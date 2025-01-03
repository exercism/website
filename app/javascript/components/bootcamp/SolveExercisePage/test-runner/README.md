# A test in its simplest form is:

```ts
import expect from "./expect";
describe("Test suit name", (test) => {
  test("test name", () => {
    const actual = 1;

 const expects = [expect({
      actual,
      testsType: "io",
      name: "test name",
      slug: "test-name",
    }).toBe(1), ...];

    return {
      expectes,
      codeRun: ''
    }
  });
});
```

Expect callback returns a matcher fn, which will return [`MatcherResult`][mr-location].

[`MatcherResult`][mr-location] is passed on

[mr-location]: /types/Matchers.d.ts
