import React from 'react'
import { Icon } from './Icon'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  className,
}: {
  handle: string
  flair: Flair
  size?: keyof typeof FLAIR_SIZE
  iconClassName?: string
  className?: string
}): JSX.Element | null {
  const { t } = useAppTranslation()

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
            title={t(`flair.${flair}`)}
            alt={t('flair.alt', { title: t(`flair.${flair}`) })}
          />
        </>
      )}
    </span>
  )
}
