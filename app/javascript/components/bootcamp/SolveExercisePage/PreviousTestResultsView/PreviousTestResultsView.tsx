import React from 'react'
import { useMemo } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { IOTestResultView } from '../TestResultsView/IOTestResultView'
import { StateTestResultView } from '../TestResultsView/StateTestResultView'
import { useMountViewOrImage } from '../TaskPreview/useMountViewOrImage'
import useTestStore from '../store/testStore'
import { getDiffOfExpectedAndActual } from '../TestResultsView/useInspectedTestResultView'
import { CodeRun } from '../TestResultsView/CodeRun'
import { PassMessage } from '../TestResultsView/PassMessage'

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
    <div
      className={assembleClassNames(
        'c-scenario',
        result.status === 'fail' ? 'fail' : 'pass'
      )}
    >
      <PreviousTestResultViewLHS result={result} />

      <div ref={viewContainerRef} id="view-container" />
    </div>
  )
}

export const PreviousTestResultView = wrapWithErrorBoundary(
  _PreviousTestResultView
)

function PreviousTestResultViewLHS({ result }: { result: PreviousTestResult }) {
  return (
    <div className="flex flex-col justify-between w-full">
      <div className="flex flex-col gap-4 p-8">
        <h2
          className={assembleClassNames(
            'text-18 font-semibold ',
            result.status === 'fail' ? 'mb-8' : ''
          )}
        >
          Scenario: {result.name} - {result.status}
        </h2>
        {result.status === 'fail' ? (
          <div className="[&_h5]:font-bold [&_p]:font-mono text-[16px] [&_h5]:uppercase [&_h5]:leading-140  [&_p_span]:rounded-3">
            {result.testsType === 'state' ? (
              <StateTestResultView descriptionHtml={result.actual!} />
            ) : (
              <>
                <CodeRun codeRun={result.codeRun ?? ''} />
                <IOTestResultView
                  diff={getDiffOfExpectedAndActual(
                    result.expected,
                    result.actual
                  )}
                />
              </>
            )}
          </div>
        ) : (
          <PassMessage testIdx={result.testIndex} />
        )}
      </div>
    </div>
  )
}
