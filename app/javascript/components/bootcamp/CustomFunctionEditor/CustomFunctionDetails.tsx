import { ToggleButton } from '@/components/common/ToggleButton'
import React from 'react'

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

      <label className={labelClassName} htmlFor="active-toggle">
        Active
      </label>
      <ToggleButton
        className="w-fit mb-24"
        checked={isActivated}
        onToggle={() => setIsActivated((a) => !a)}
      />

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
