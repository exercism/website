import React from 'react'
import { ToggleButton } from '@/components/common/ToggleButton'
import { StaticTooltip } from '../../JikiscriptExercisePage/Scrubber/ScrubberTooltipInformation'
import customFunctionEditorStore from '../store/customFunctionEditorStore'

export function ActiveToggleButton() {
  const { isActivated, toggleIsActivated, areAllTestsPassing } =
    customFunctionEditorStore()

  return (
    <div>
      <ToggleButton
        className="w-fit"
        disabled={!areAllTestsPassing}
        checked={isActivated}
        onToggle={toggleIsActivated}
      />
      {!areAllTestsPassing && (
        <StaticTooltip
          text="You can activate this function only when all tests pass."
          className="block"
        />
      )}
    </div>
  )
}
