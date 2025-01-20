/**
 * Returns the first failing test or the last test if all tests pass
 */
export function getFirstFailingOrLastTest(
  testResults: TestSuiteResult<NewTestResult>,
  inspectedTestResult: NewTestResult | null
): NewTestResult {
  // if inspectedTestResult is already set and it fails again, keep it.
  if (
    inspectedTestResult &&
    inspectedTestResult.status === 'fail' &&
    testResults.tests[inspectedTestResult.testIndex].status === 'fail'
  ) {
    return testResults.tests[inspectedTestResult.testIndex]
  } else {
    const firstFailingOrLastIndex = (() => {
      const firstFailingIndex = testResults.tests.findIndex(
        (test) => test.status === 'fail'
      )
      return firstFailingIndex !== -1
        ? firstFailingIndex
        : testResults.tests.length - 1
    })()

    return testResults.tests[firstFailingOrLastIndex]
  }
}
