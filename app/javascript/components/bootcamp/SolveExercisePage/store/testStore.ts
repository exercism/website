import { createStoreWithMiddlewares } from './utils'

type TestStore = {
  inspectedTestResult: NewTestResult | null
  setInspectedTestResult: (inspectedTestResult: NewTestResult | null) => void
  inspectedPreviousTestResult: PreviousTestResult | null
  setInspectedPreviousTestResult: (
    inspectedTestResult: PreviousTestResult | null
  ) => void
  testSuiteResult: TestSuiteResult<NewTestResult> | null
  setTestSuiteResult: (
    testSuiteResult: TestSuiteResult<NewTestResult> | null
  ) => void
  previousTestSuiteResult: TestSuiteResult<PreviousTestResult> | null
  setPreviousTestSuiteResult: (
    testSuiteResult: TestSuiteResult<PreviousTestResult> | null
  ) => void
}

const useTestStore = createStoreWithMiddlewares<TestStore>(
  (set) => ({
    inspectedTestResult: null,
    setInspectedTestResult: (inspectedTestResult) => {
      set({ inspectedTestResult }, false, 'exercise/setTestResults')
    },
    inspectedPreviousTestResult: null,
    setInspectedPreviousTestResult: (inspectedPreviousTestResult) => {
      set({ inspectedPreviousTestResult }, false, 'exercise/setTestResults')
    },
    previousTestSuiteResult: null,
    setPreviousTestSuiteResult: (previousTestSuiteResult) => {
      set(
        { previousTestSuiteResult },
        false,
        'exercise/setPreviousTestSuiteResult'
      )
    },
    testSuiteResult: null,
    setTestSuiteResult: (testSuiteResult) => {
      set(
        { testSuiteResult: testSuiteResult },
        false,
        'exercise/setTestSuiteResult'
      )
    },
  }),
  'TestStore'
)

export default useTestStore
