import React from 'react'
import { useMemo } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { useMountViewOrImage } from '../TaskPreview/useMountViewOrImage'
import useTestStore from '../store/testStore'
import { getDiffOfExpectedAndActual } from '../TestResultsView/useInspectedTestResultView'
import { InspectedTestResultViewLHS } from '../TestResultsView/InspectedTestResultView'

function _PreviousTestResultView({ exercise }: { exercise: Exercise }) {
  const { inspectedPreviousTestResult: result, testSuiteResult } =
    useTestStore()
  const currentTaskTest: TaskTest = useMemo(() => {
    if (!result) {
      return exercise.tasks[0].tests[0]
    }
    for (const task of exercise.tasks) {
      const foundTest = task.tests.find((test) => test.slug === result.slug)
      if (foundTest) return foundTest
    }
    return exercise.tasks[0].tests[0]
  }, [exercise.tasks, result?.slug])

  const viewContainerRef = useMountViewOrImage({
    config: exercise.config,
    taskTest: currentTaskTest,
    result: result!,
  })

  // if recently ran testSuiteResult exists, don't show this
  if (!result || testSuiteResult) return null

  return (
    <div className={assembleClassNames('c-scenario', result.status)}>
      {/* TODO: add correct type here for result */}
      <InspectedTestResultViewLHS
        result={result as unknown as NewTestResult}
        firstExpect={{
          actual: result.actual,
          diff:
            result.status === 'pass'
              ? getDiffOfExpectedAndActual(result.expected, result.expected)
              : getDiffOfExpectedAndActual(result.expected, result.actual),
          pass: result.status === 'pass',
          testsType: result.testsType,
          errorHtml: result.errorHtml,
        }}
      />

      <div ref={viewContainerRef} id="view-container" />
    </div>
  )
}

export const PreviousTestResultView = wrapWithErrorBoundary(
  _PreviousTestResultView
)
