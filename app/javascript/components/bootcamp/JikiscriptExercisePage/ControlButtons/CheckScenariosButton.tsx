import React, { useCallback, useContext } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import useEditorStore from '../store/editorStore'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import useTestStore from '../store/testStore'
import useAnimationTimelineStore from '../store/animationTimelineStore'
import useErrorStore from '../store/errorStore'
import { flushSync } from 'react-dom'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'

export function CheckScenariosButton({
  handleRunCode,
}: {
  handleRunCode: () => void
}) {
  const { shouldAutoRunCode, setShouldAutoRunCode, cleanUpEditorStore } =
    useEditorStore()
  const { cleanUpTestStore } = useTestStore()
  const { setIsTimelineComplete } = useAnimationTimelineStore()
  const { cleanUpErrorStore } = useErrorStore()
  const { isSpotlightActive } = useContext(JikiscriptExercisePageContext)

  const cleanUpState = useCallback(() => {
    setIsTimelineComplete(false)
    cleanUpTestStore()
    cleanUpEditorStore()
    cleanUpErrorStore()
  }, [])

  return (
    <button
      data-ci="check-scenarios-button"
      className="scenarios-button btn-primary btn-s"
      disabled={isSpotlightActive}
      onClick={() => {
        flushSync(cleanUpState)
        handleRunCode()
        setShouldAutoRunCode(false)
      }}
    >
      Check Scenarios
      <GraphicalIcon
        icon="bootcamp-autorun"
        width={20}
        height={20}
        className={assembleClassNames(
          '!mx-0 !w-[20px]',
          shouldAutoRunCode ? 'invert' : ''
        )}
      />
    </button>
  )
}
