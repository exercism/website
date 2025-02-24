import React, { useContext } from 'react'
import { useCallback } from 'react'
import useEditorStore from '../store/editorStore'
import useTestStore from '../store/testStore'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'
import { scrollToLine } from '../CodeMirror/scrollToLine'

export function InformationWidgetToggleButton({
  disabled,
}: {
  disabled: boolean
}) {
  const {
    toggleShouldShowInformationWidget,
    shouldShowInformationWidget,
    setHighlightedLine,
  } = useEditorStore()
  const { inspectedTestResult } = useTestStore()
  const { editorView } = useContext(SolveExercisePageContext)
  const { highlightedLine } = useEditorStore()
  const handleToggleShouldShowInformationWidget = useCallback(() => {
    toggleShouldShowInformationWidget()

    // if previous toggle state is `off` - which means we are about to turn it `on`...
    // scroll to the highlighted line
    if (!shouldShowInformationWidget) {
      scrollToLine(editorView, highlightedLine)
    }

    if (!inspectedTestResult) return

    //  if there is only one frame..
    if (inspectedTestResult.frames.length === 1) {
      // ...and we are about to show information widget
      if (!shouldShowInformationWidget) {
        // highlight relevant line
        setHighlightedLine(inspectedTestResult.frames[0].line)
      } else {
        // if toggling's next step is off, remove highlight
        setHighlightedLine(0)
      }
    }
  }, [shouldShowInformationWidget, inspectedTestResult, highlightedLine])
  return (
    <label data-ci="information-widget-toggle" className="switch">
      <input
        disabled={disabled}
        type="checkbox"
        onChange={handleToggleShouldShowInformationWidget}
        checked={shouldShowInformationWidget}
      />
      <span className="slider round"></span>
    </label>
  )
}
