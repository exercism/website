import { useState, useEffect } from 'react'

export function useShouldAnimate(
  testSuiteResult: TestSuiteResult<NewTestResult> | null
) {
  const [shouldAnimate, setShouldAnimate] = useState(false)

  useEffect(() => {
    if (!testSuiteResult) return
    setShouldAnimate(true)
  }, [testSuiteResult])

  return { shouldAnimate }
}
