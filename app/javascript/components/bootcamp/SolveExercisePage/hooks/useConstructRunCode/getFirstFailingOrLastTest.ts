/**
 * Returns the first failing test or the last test if all tests pass
 */
export function getFirstFailingOrLastTest(
  testResults: TestSuiteResult<NewTestResult>,
  bonusTestResults: TestSuiteResult<NewTestResult>,
  inspectedTestResult: NewTestResult | null,
  shouldShowBonusTasks: boolean
): NewTestResult {
  const allTests = [...testResults.tests, ...bonusTestResults.tests]

  const failingSlugs = new Set(
    allTests.filter((t) => t.status === 'fail').map((t) => t.slug)
  )

  // if inspectedTestResult is still failing, return it
  if (
    inspectedTestResult &&
    inspectedTestResult.status === 'fail' &&
    failingSlugs.has(inspectedTestResult.slug)
  ) {
    return inspectedTestResult
  }

  const firstFailingTest = testResults.tests.find(
    (test) => test.status === 'fail'
  )
  if (firstFailingTest) return firstFailingTest

  // if all basic tests pass and shouldShowBonusTasks, return the first failing bonus test
  const firstFailingBonusTest = bonusTestResults.tests.find(
    (test) => test.status === 'fail'
  )
  if (firstFailingBonusTest && shouldShowBonusTasks)
    return firstFailingBonusTest

  // if everything passes, return the last test
  return testResults.tests[testResults.tests.length - 1]
}
