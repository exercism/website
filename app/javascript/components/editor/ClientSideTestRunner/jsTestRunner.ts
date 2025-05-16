export function runJsTests() {
  // run tests here with the js test-runner from npm and return results

  return TEST_RESULTS
}

const TEST_RESULTS = {
  version: 3,
  status: 'pass',
  message: null,
  messageHtml: null,
  output: null,
  outputHtml: null,
  tests: [
    {
      name: 'Hello World > Say Hi!',
      status: 'pass',
      testCode: "expect(hello()).toEqual('Hello, World!');",
      message:
        'Error: \u001b[2mexpect(\u001b[22m\u001b[31mreceived\u001b[39m\u001b[2m).\u001b[22mtoEqual\u001b[2m(\u001b[22m\u001b[32mexpected\u001b[39m\u001b[2m) // deep equality\u001b[22m\n\nExpected: \u001b[32m"\u001b[7mHello, World\u001b[27m!"\u001b[39m\nReceived: \u001b[31m"\u001b[7mGoodbye, Mars\u001b[27m!"\u001b[39m',
      messageHtml:
        "Error: expect(<span style='color:#A00;'>received</span>).toEqual(<span style='color:#0A0;'>expected</span>) // deep equality\n\nExpected: <span style='color:#0A0;'>&quot;Hello, World!&quot;</span>\nReceived: <span style='color:#A00;'>&quot;Goodbye, Mars!&quot;</span>",
      expected: null,
      output: null,
      outputHtml: null,
      taskId: null,
    },
  ],
  tasks: [],
  highlightjsLanguage: 'javascript',
  links: {
    self: 'http://local.exercism.io:3020/api/v2/solutions/b714573e50244417a0812ca49cc76a1d/submissions/71487f490f584bfaa61a0051bd244932/test_run',
  },
}
