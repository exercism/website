import { AvatarGroup, AvatarGroupProps } from '@/components/common'
import { pluralizeWithNumber } from '@/utils/pluralizeWithNumber'
import React from 'react'

type CreditsProps = {
  topLabel: string
  topCount: number
  bottomLabel?: string
  bottomCount?: number
  fontSize?: number
} & AvatarGroupProps

export function Credits({
  topLabel,
  topCount,
  bottomLabel,
  bottomCount,
  max,
  avatarUrls,
  fontSize = 14,
}: CreditsProps): JSX.Element {
  return (
    <div
      className={`flex gap-x-16 text-textColor1 leading-150 whitespace-nowrap text-${fontSize} items-center`}
    >
      <AvatarGroup max={max} avatarUrls={avatarUrls} />
      <div className="flex flex-col gap-y-2">
        <div className="font-semibold">
          {pluralizeWithNumber(topCount, topLabel)}
        </div>
        {bottomCount &&
        bottomLabel &&
        bottomCount > 0 &&
        bottomLabel.length > 0 ? (
          <div>{pluralizeWithNumber(bottomCount, bottomLabel)}</div>
        ) : null}
      </div>
    </div>
  )
}
