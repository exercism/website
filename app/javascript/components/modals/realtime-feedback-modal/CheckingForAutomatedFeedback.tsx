import React, { memo } from 'react'
import { GraphicalIcon } from '@/components/common'

function CheckingForFeedback({
  onClick,
  showTakingTooLong,
}: {
  onClick: () => void
  showTakingTooLong: boolean
}): JSX.Element {
  return (
    <div className="flex flex-col gap-16">
      <div className="flex gap-8 text-h4 text-textColor1">
        <GraphicalIcon
          icon="spinner"
          className="animate-spin filter-textColor1"
          height={24}
          width={24}
        />
        Checking for automated feedback...{' '}
      </div>
      {showTakingTooLong && <TakingTooLong />}
      <button onClick={onClick} className="btn-primary btn-s mr-auto">
        Continue anyway
      </button>
    </div>
  )
}

function TakingTooLong(): JSX.Element {
  return (
    <div>
      <p className="text-p-base">
        Sorry, this is taking a little long.
        <br />
        We&apos;ll continue gathering feedback in the background.
      </p>
    </div>
  )
}

export const CheckingForAutomatedFeedback = memo(CheckingForFeedback)
