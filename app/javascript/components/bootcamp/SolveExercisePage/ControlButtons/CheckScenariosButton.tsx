import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import useEditorStore from '../store/editorStore'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import useTestStore from '../store/testStore'
import useAnimationTimelineStore from '../store/animationTimelineStore'
import useErrorStore from '../store/errorStore'
import { flushSync } from 'react-dom'

export function CheckScenariosButton({
  handleRunCode,
}: {
  handleRunCode: () => void
}) {
  const { shouldAutoRunCode, setShouldAutoRunCode } = useEditorStore()
  const { setInformationWidgetData, setShouldShowInformationWidget } =
    useEditorStore()
  const {
    setHasSyntaxError,
    inspectedTestResult,
    setTestSuiteResult,
    setInspectedTestResult,
  } = useTestStore()
  const { setIsTimelineComplete } = useAnimationTimelineStore()
  const { setHasUnhandledError } = useErrorStore()

  function cleanUpState() {
    setHasSyntaxError(false)
    setHasUnhandledError(false)
    setShouldShowInformationWidget(false)
    setInformationWidgetData({
      html: '',
      line: 0,
      status: 'SUCCESS',
    })
    if (inspectedTestResult) {
      inspectedTestResult.animationTimeline?.destroy()
      inspectedTestResult.animationTimeline = null
    }
    setIsTimelineComplete(false)
    setTestSuiteResult(null)
    setInspectedTestResult(null)
  }

  return (
    <button
      data-ci="check-scenarios-button"
      className="scenarios-button btn-primary btn-s"
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
