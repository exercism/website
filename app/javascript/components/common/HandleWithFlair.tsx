import React from 'react'
import { GraphicalIcon } from './GraphicalIcon'

export type Flair = 'insider' | 'lifetime_insider' | 'founder' | 'staff'

type FlairIcons = 'insiders' | 'lifetime-insiders' | 'exercism-face-gradient'

type Flairs = Record<Flair, FlairIcons>

const FLAIRS: Flairs = {
  insider: 'insiders',
  lifetime_insider: 'lifetime-insiders',
  founder: 'exercism-face-gradient',
  staff: 'exercism-face-gradient',
}

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
  flair: Flair
  size?: keyof typeof FLAIR_SIZE
  iconClassName?: string
}): JSX.Element | null {
  return (
    <span className="flex items-center">
      {handle}
      {Object.prototype.hasOwnProperty.call(FLAIRS, flair) && (
        <>
          &nbsp;
          <GraphicalIcon
            className={'handle-with-flair-icon ' + iconClassName}
            height={FLAIR_SIZE[size]}
            width={FLAIR_SIZE[size]}
            icon={FLAIRS[flair]}
          />
        </>
      )}
    </span>
  )
}
