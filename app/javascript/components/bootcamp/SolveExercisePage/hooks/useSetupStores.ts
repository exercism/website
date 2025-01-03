import { useLayoutEffect } from 'react'
import useEditorStore from '../store/editorStore'
import useTaskStore from '../store/taskStore/taskStore'
import useTestStore from '../store/testStore'

export function useSetupStores({
  exercise,
  code,
}: Pick<SolveExercisePageProps, 'exercise' | 'code'>) {
  const { setDefaultCode } = useEditorStore()
  const { initializeTasks } = useTaskStore()
  const { setPreviousTestSuiteResult, setInspectedPreviousTestResult } =
    useTestStore()

  useLayoutEffect(() => {
    let previousTestSuiteResult: TestSuiteResult<PreviousTestResult> | null =
      null
    if (exercise.testResults) {
      const tests = (() => {
        const testArr = []
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
    setDefaultCode(code.code)
  }, [exercise, code])
}

function generateCodeRunString(fn: string, params: any[]) {
  if (!fn || !params) return ''
  return `${fn}(${params.join(', ')})`
}
