export async function describe(
  suiteName: string,
  callback: (
    test: (
      testName: string,
      descriptionHtml: string | undefined,
      testCallback: TestCallback
    ) => void
  ) => Promise<void>
): Promise<TestSuiteResult<NewTestResult>> {
  // test results are collected in one shared array
  const tests: NewTestResult[] = []

  const test = await createTestCallback(tests)

  // invokes the test callbacks, which mutate the tests array by pushing the new results to it
  await callback(test)

  return {
    suiteName: suiteName,
    tests,
    status: tests.every((test) => test.status === 'pass') ? 'pass' : 'fail',
  }
}

function createTestCallback(tests: NewTestResult[]) {
  return async function (
    testName: string,
    descriptionHtml: string | undefined,
    testCallback: TestCallback
  ): Promise<void> {
    const result = await testCallback()
    tests.push({
      // we need testIndex, so we can retrieve quickly the test that we are currently inspecting/working on
      testIndex: tests.length,
      name: testName,
      descriptionHtml: descriptionHtml,
      status: result.expects.every((t) => t.pass) ? 'pass' : 'fail',
      ...result,
    })
  }
}
