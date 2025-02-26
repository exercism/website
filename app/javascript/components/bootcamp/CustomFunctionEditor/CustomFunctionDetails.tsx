import { ToggleButton } from '@/components/common/ToggleButton'
import React from 'react'
import { StaticTooltip } from '../SolveExercisePage/Scrubber/ScrubberTooltipInformation'

const labelClassName = 'font-mono font-semibold mb-4'
export function CustomFunctionDetails({
  name,
  description,
  setDescription,
  areAllTestsPassing,
  isActivated,
  setIsActivated,
}: {
  name: string
  description: string
  setDescription: React.Dispatch<React.SetStateAction<string>>
  areAllTestsPassing: boolean
  isActivated: boolean
  setIsActivated: React.Dispatch<React.SetStateAction<boolean>>
}) {
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
        value={name}
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
          onToggle={() => setIsActivated((a) => !a)}
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
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        id=""
      ></textarea>
    </div>
  )
}
