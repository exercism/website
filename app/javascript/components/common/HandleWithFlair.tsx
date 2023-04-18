import React from 'react'
import { GraphicalIcon } from './GraphicalIcon'

const FLAIRS = ['insiders', 'original-insiders']

export function HandleWithFlair({
  handle,
  flair,
  size,
  iconClassName,
}: {
  handle: string
  flair: string
  size: number
  iconClassName?: string
}): JSX.Element | null {
  size = size - 3

  return (
    <span className="flex items-center">
      {handle}
      {flair && (
        <>
          &nbsp;
          <GraphicalIcon
            className={'handle-with-flair-icon ' + iconClassName}
            height={size}
            width={size}
            icon={FLAIRS[+(flair === 'original_insider')]}
          />
        </>
      )}
    </span>
  )
}
