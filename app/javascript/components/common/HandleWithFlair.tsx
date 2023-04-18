import React from 'react'
import { GraphicalIcon } from './GraphicalIcon'

const FLAIRS = ['insiders', 'og-insiders']

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
  return (
    <span className="flex items-center">
      {handle}
      {flair && (
        <>
          &nbsp;
          <GraphicalIcon
            className={iconClassName}
            height={size}
            width={size}
            icon={FLAIRS[+(flair === 'original_insider')]}
          />
        </>
      )}
    </span>
  )
}
