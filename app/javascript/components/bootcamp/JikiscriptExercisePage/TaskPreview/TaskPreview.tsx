import React, { useContext } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import useTestStore from '../store/testStore'
import { StatePreview } from './StatePreview'
import { IOPreview } from './IOPreview'
import { useMountViewOrImage } from './useMountViewOrImage'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'

export function _TaskPreview() {
  const { exercise } = useContext(JikiscriptExercisePageContext)
  const { testSuiteResult, inspectedPreviewTaskTest } = useTestStore()

  const viewContainerRef = useMountViewOrImage({
    config: exercise.config,
    taskTest: inspectedPreviewTaskTest,
    testSuiteResult,
    inspectedPreviewTaskTest,
  })

  if (testSuiteResult) {
    return null
  }

  return (
    <section data-ci="task-preview" className="c-scenario pending">
      {exercise.config.testsType === 'io' ? (
        <IOPreview inspectedPreviewTaskTest={inspectedPreviewTaskTest} />
      ) : (
        <StatePreview inspectedPreviewTaskTest={inspectedPreviewTaskTest} />
      )}
      <div ref={viewContainerRef} id="view-container" />
    </section>
  )
}

export const TaskPreview = wrapWithErrorBoundary(_TaskPreview)
