/**
 * Returns the first failing test or the last test if all tests pass
 */
export function getFirstFailingOrLastTest(
  testResults: TestSuiteResult<NewTestResult>,
  bonusTestResults: TestSuiteResult<NewTestResult>,
  inspectedTestResult: NewTestResult | null,
  shouldShowBonusTasks: boolean
): NewTestResult {
  const allTests = [
    ...(testResults?.tests ?? []),
    ...(bonusTestResults?.tests ?? []),
  ]

  const failingSlugs = new Set(
    allTests.filter((t) => t.status === 'fail').map((t) => t.slug)
  )

  const inspectedTest = inspectedTestResult
    ? allTests.find((t) => t.slug === inspectedTestResult.slug)
    : undefined

  // if inspected test still fails, keep it
  if (
    inspectedTest &&
    inspectedTest.status === 'fail' &&
    failingSlugs.has(inspectedTest.slug)
  ) {
    return inspectedTest
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
  return allTests[allTests.length - 1]
}
