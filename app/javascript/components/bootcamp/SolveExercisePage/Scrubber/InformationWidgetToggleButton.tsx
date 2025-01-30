import React from 'react'
import { useCallback } from 'react'
import useEditorStore from '../store/editorStore'
import useTestStore from '../store/testStore'
import { scrollToHighlightedLine } from './scrollToHighlightedLine'

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
  const handleToggleShouldShowInformationWidget = useCallback(() => {
    toggleShouldShowInformationWidget()

    // if previeous state is off - which means we are about to turn it on
    // scroll to the highlighted line
    if (!shouldShowInformationWidget) {
      scrollToHighlightedLine()
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
  }, [shouldShowInformationWidget, inspectedTestResult])
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
