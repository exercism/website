import React from 'react'
import { GraphicalIcon } from '../common'

export function TooltipUnlockButton({
  unlockUrl,
}: {
  unlockUrl: string
}): JSX.Element {
  return (
    // or flex container in haml
    <div className="flex mb-10">
      <button className="btn-primary btn-s flex items-center grow w-[100%] text-14 py-4 px-16">
        <GraphicalIcon icon="unlock" width={14} height={14} className="mr-8" />
        Unlock this tab
      </button>
    </div>
  )
}
