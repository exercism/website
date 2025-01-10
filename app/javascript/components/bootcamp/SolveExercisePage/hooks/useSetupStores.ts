import { useLayoutEffect } from 'react'
import useEditorStore from '../store/editorStore'
import useTaskStore from '../store/taskStore/taskStore'
import useTestStore from '../store/testStore'
import { useLocalStorage } from '@uidotdev/usehooks'

export function useSetupStores({
  exercise,
  code,
}: Pick<SolveExercisePageProps, 'exercise' | 'code'>) {
  const [editorLocalStorageValue, setEditorLocalStorageValue] = useLocalStorage(
    'bootcamp-editor-value-' + exercise.config.title,
    {
      code: code.code,
      storedAt: code.storedAt,
      readonlyRanges: code.readonlyRanges,
    }
  )
  const { setDefaultCode, setReadonlyRanges } = useEditorStore()
  const { initializeTasks } = useTaskStore()
  const {
    setPreviousTestSuiteResult,
    setInspectedPreviousTestResult,
    setFlatPreviewTaskTests,
  } = useTestStore()

  useLayoutEffect(() => {
    let previousTestSuiteResult: TestSuiteResult<PreviousTestResult> | null =
      null
    if (exercise.testResults) {
      const tests = (() => {
        const testArr: {
          name: string
          testIndex: number
          slug: string
          status: 'pass' | 'fail'
          actual: string
          expected: string | undefined
          errorHtml?: string
          codeRun: string
          testsType: 'io' | 'state'
        }[] = []

        let i = 0
        for (let taskInConfig of exercise.tasks) {
          for (let testInConfig of taskInConfig.tests) {
            const prevTest = exercise.testResults.tests[i]
            if (testInConfig.slug === prevTest.slug) {
              testArr.push({
                name: testInConfig.name,
                testIndex: i,
                slug: testInConfig.slug,
                status: prevTest.status,
                actual: prevTest.actual,
                errorHtml:
                  exercise.config.testsType === 'state' &&
                  prevTest.status === 'fail'
                    ? prevTest.actual
                    : undefined,
                expected: testInConfig.expected,
                codeRun: generateCodeRunString(
                  testInConfig.function,
                  testInConfig.params
                ),

                testsType: exercise.config.testsType,
              })
            }
            i++
          }
        }
        return testArr
      })()

      const firstFailingTest = tests.find((test) => test.status === 'fail')
      setInspectedPreviousTestResult(firstFailingTest ?? tests[0])

      previousTestSuiteResult = {
        suiteName: exercise.config.title,
        status: exercise.testResults.status,
        tests,
      }
      setPreviousTestSuiteResult(previousTestSuiteResult)
    }

    initializeTasks(exercise.tasks, previousTestSuiteResult)
    setFlatPreviewTaskTests(exercise.tasks.flatMap((task) => task.tests))

    // ensure we always load the latest code to editor
    if (
      editorLocalStorageValue.storedAt &&
      code.storedAt &&
      // if the code on the server is newer than in localstorage, update the storage and load the code from the server
      editorLocalStorageValue.storedAt < code.storedAt
    ) {
      setEditorLocalStorageValue({
        code: code.code,
        storedAt: code.storedAt,
        readonlyRanges: code.readonlyRanges,
      })
      setDefaultCode(code.code)
    } else {
      // otherwise we are using the code from the storage
      setDefaultCode(editorLocalStorageValue.code)
      if (editorLocalStorageValue.readonlyRanges) {
        setReadonlyRanges(editorLocalStorageValue.readonlyRanges)
      }
    }
  }, [exercise, code])
}

export function generateCodeRunString(fn: string, params: any[]) {
  if (!fn || !params) return ''
  return `${fn}(${params.join(', ')})`
}
