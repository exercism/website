import React from 'react'
import { useMemo } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import useTestStore from '../store/testStore'
import { StatePreview } from './StatePreview'
import { IOPreview } from './IOPreview'
import { useMountViewOrImage } from './useMountViewOrImage'

export function _TaskPreview({ exercise }: { exercise: Exercise }) {
  const firstTest = useMemo(() => exercise.tasks[0].tests[0], [exercise.tasks])
  const { testSuiteResult, previousTestSuiteResult } = useTestStore()

  const viewContainerRef = useMountViewOrImage({
    config: exercise.config,
    taskTest: firstTest,
  })

  if (testSuiteResult || previousTestSuiteResult) return null

  return (
    <div className="m-8 border rounded-3 bg-blue-100 border-blue-300 h-full text-16 leading-150 flex justify-between flex-grow overflow-hidden">
      {exercise.config.testsType === 'io' ? (
        <IOPreview firstTest={firstTest} />
      ) : (
        <StatePreview firstTest={firstTest} config={exercise.config} />
      )}
      <div ref={viewContainerRef} id="view-container" />
    </div>
  )
}

export const TaskPreview = wrapWithErrorBoundary(_TaskPreview)
