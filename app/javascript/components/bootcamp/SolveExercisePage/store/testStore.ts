import { createStoreWithMiddlewares } from './utils'

type TestStore = {
  inspectedTestResult: NewTestResult | null
  setInspectedTestResult: (inspectedTestResult: NewTestResult | null) => void
  testSuiteResult: TestSuiteResult<NewTestResult> | null
  setTestSuiteResult: (
    testSuiteResult: TestSuiteResult<NewTestResult> | null
  ) => void
  bonusTestSuiteResult: TestSuiteResult<NewTestResult> | null
  setBonusTestSuiteResult: (
    testSuiteResult: TestSuiteResult<NewTestResult> | null
  ) => void
  flatPreviewTaskTests: TaskTest[]
  setFlatPreviewTaskTests: (flatPreviewTaskTests: TaskTest[]) => void
  setInspectedPreviewTaskTest: (inspectedPreviewTaskTest: TaskTest) => void
  inspectedPreviewTaskTest: TaskTest
  hasSyntaxError: boolean
  setHasSyntaxError: (hasSyntaxError: boolean) => void
  cleanUpTestStore: () => void
}

const useTestStore = createStoreWithMiddlewares<TestStore>(
  (set) => ({
    inspectedTestResult: null,
    setInspectedTestResult: (inspectedTestResult) => {
      set({ inspectedTestResult }, false, 'exercise/setTestResults')
    },
    flatPreviewTaskTests: [],
    setFlatPreviewTaskTests: (flatPreviewTaskTests) => {
      set(
        {
          flatPreviewTaskTests,
          inspectedPreviewTaskTest: flatPreviewTaskTests[0],
        },
        false,
        'exercise/setFlatPreviewTaskTests'
      )
    },
    inspectedPreviewTaskTest: {} as TaskTest,
    setInspectedPreviewTaskTest: (inspectedPreviewTaskTest) => {
      set(
        { inspectedPreviewTaskTest },
        false,
        'exercise/setInspectedPreviewTaskTest'
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
    bonusTestSuiteResult: null,
    setBonusTestSuiteResult: (bonusTestSuiteResult) => {
      set(
        { bonusTestSuiteResult: bonusTestSuiteResult },
        false,
        'exercise/setTestSuiteResult'
      )
    },
    hasSyntaxError: false,
    setHasSyntaxError: (hasSyntaxError) => {
      set({ hasSyntaxError }, false, 'exercise/setHasSyntaxError')
    },
    cleanUpTestStore: () => {
      set(
        {
          inspectedTestResult: null,
          testSuiteResult: null,
          hasSyntaxError: false,
        },
        false,
        'exercise/cleanUpTestStore'
      )
    },
  }),
  'TestStore'
)

export default useTestStore
