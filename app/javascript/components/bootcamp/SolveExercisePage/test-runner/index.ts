export function describe(
  suiteName: string,
  callback: (
    test: (
      testName: string,
      descriptionHtml: string | undefined,
      testCallback: TestCallback
    ) => void
  ) => void
): TestSuiteResult<NewTestResult> {
  // test results are collected in one shared array
  const tests: NewTestResult[] = []

  const test = createTestCallback(tests)

  // invokes the test callbacks, which mutate the tests array by pushing the new results to it
  callback(test)

  return {
    suiteName: suiteName,
    tests,
    status: tests.every((test) => test.status === 'pass') ? 'pass' : 'fail',
  }
}

function createTestCallback(tests: NewTestResult[]) {
  return function (
    testName: string,
    descriptionHtml: string | undefined,
    testCallback: TestCallback
  ): void {
    const testCallbackResult = testCallback()
    tests.push({
      // we need testIndex, so we can retrieve quickly the test that we are currently inspecting/working on
      testIndex: tests.length,
      name: testName,
      descriptionHtml: descriptionHtml,
      status: testCallbackResult.expects.every((t) => t.pass) ? 'pass' : 'fail',
      ...testCallbackResult,
    })
  }
}
