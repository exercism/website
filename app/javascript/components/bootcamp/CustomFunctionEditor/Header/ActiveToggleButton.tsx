import React, { useContext } from 'react'
import { ToggleButton } from '@/components/common/ToggleButton'
import { StaticTooltip } from '../../SolveExercisePage/Scrubber/ScrubberTooltipInformation'
import { CustomFunctionEditorStoreContext } from '../CustomFunctionEditor'

export function ActiveToggleButton() {
  const labelClassName = 'font-mono font-semibold mb-4'
  const { customFunctionEditorStore } = useContext(
    CustomFunctionEditorStoreContext
  )
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
