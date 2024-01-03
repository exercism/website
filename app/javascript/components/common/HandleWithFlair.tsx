import React from 'react'
import { Icon } from './Icon'
import { assembleClassNames } from '@/utils/assemble-classnames'

export type Flair = 'insider' | 'lifetime_insider' | 'founder' | 'staff'

type FlairIcons = 'insiders' | 'lifetime-insiders' | 'exercism-face-gradient'

type FlairTitle = 'An Insider' | 'A lifetime Insider' | 'Founder' | 'Staff'

type Flairs = Record<Flair, FlairIcons>

type FlairTitles = Record<Flair, FlairTitle>

const FLAIRS: Flairs = {
  insider: 'insiders',
  lifetime_insider: 'lifetime-insiders',
  founder: 'exercism-face-gradient',
  staff: 'exercism-face-gradient',
}

const FLAIR_TITLES: FlairTitles = {
  founder: 'Founder',
  staff: 'Staff',
  insider: 'An Insider',
  lifetime_insider: 'A lifetime Insider',
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
  className,
}: {
  handle: string
  flair: Flair
  size?: keyof typeof FLAIR_SIZE
  iconClassName?: string
  className?: string
}): JSX.Element | null {
  return (
    <span className={assembleClassNames('flex items-center', className)}>
      {handle}
      {Object.prototype.hasOwnProperty.call(FLAIRS, flair) && (
        <>
          &nbsp;
          <Icon
            className={'handle-with-flair-icon ' + iconClassName}
            height={FLAIR_SIZE[size]}
            width={FLAIR_SIZE[size]}
            icon={FLAIRS[flair]}
            title={FLAIR_TITLES[flair]}
            alt={`${FLAIR_TITLES[flair]}'s flair`}
          />
        </>
      )}
    </span>
  )
}
