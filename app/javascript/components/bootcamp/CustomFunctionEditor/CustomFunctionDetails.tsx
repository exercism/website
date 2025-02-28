import { ToggleButton } from '@/components/common/ToggleButton'
import React, { useContext } from 'react'
import { StaticTooltip } from '../SolveExercisePage/Scrubber/ScrubberTooltipInformation'
import { CustomFunctionEditorStoreContext } from './CustomFunctionEditor'

const labelClassName = 'font-mono font-semibold mb-4'
export function CustomFunctionDetails() {
  const { customFunctionEditorStore } = useContext(
    CustomFunctionEditorStoreContext
  )

  const {
    customFunctionDisplayName,
    customFunctionDescription,
    setCustomFunctionDescription,
    isActivated,
    toggleIsActivated,
    areAllTestsPassing,
  } = customFunctionEditorStore()

  return (
    <div className="flex flex-col mb-24">
      <label className={labelClassName} htmlFor="fn-name">
        Function name{' '}
      </label>
      <input
        className="mb-24"
        name="fn-name"
        type="text"
        readOnly
        value={customFunctionDisplayName}
      />

      <label
        className={labelClassName + ' w-1-3 relative group flex flex-col gap-4'}
        htmlFor="active-toggle"
      >
        Active
        <ToggleButton
          className="w-fit mb-24"
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
      </label>

      <label className={labelClassName} htmlFor="description">
        Description{' '}
      </label>
      <textarea
        name="description"
        value={customFunctionDescription}
        onChange={(e) => setCustomFunctionDescription(e.target.value)}
        id=""
      ></textarea>
    </div>
  )
}
