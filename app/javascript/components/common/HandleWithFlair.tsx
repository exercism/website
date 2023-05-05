import React from 'react'
import { GraphicalIcon } from './GraphicalIcon'

const FLAIRS = ['insiders', 'lifetime-insiders']

const FLAIR_SIZE = {
  small: 10,
  base: 13,
  medium: 15,
  large: 17,
  xlarge: 28,
}

export function HandleWithFlair({
  handle,
  flair,
  size = 'base',
  iconClassName,
}: {
  handle: string
  flair: string
  size?: keyof typeof FLAIR_SIZE
  iconClassName?: string
}): JSX.Element | null {
  return (
    <span className="flex items-center">
      {handle}
      {flair && (
        <>
          &nbsp;
          <GraphicalIcon
            className={'handle-with-flair-icon ' + iconClassName}
            height={FLAIR_SIZE[size]}
            width={FLAIR_SIZE[size]}
            icon={FLAIRS[+(flair === 'lifetime_insider')]}
          />
        </>
      )}
    </span>
  )
}
