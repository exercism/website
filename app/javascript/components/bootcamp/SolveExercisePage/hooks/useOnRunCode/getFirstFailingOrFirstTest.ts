/**
 * Returns the first failing test or the first test if all tests pass
 */
export function getFirstFailingOrFirstTest(
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
    const firstFailingOrFirstIndex = Math.max(
      testResults.tests.findIndex((test) => test.status === 'fail'),
      0
    )

    return testResults.tests[firstFailingOrFirstIndex]
  }
}
