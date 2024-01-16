import React, { useState } from 'react'
import { pluralizeWithNumber } from '@/utils/pluralizeWithNumber'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { AvatarGroup } from '.'
import { User } from '../types'

type CreditsProps = {
  topLabel: string
  topCount: number
  bottomLabel?: string
  bottomCount?: number
  fontSize?: number
  users: User[]
  className?: string
}

export default function Credits({
  topLabel,
  topCount,
  bottomLabel,
  bottomCount,
  users,
  className,
}: CreditsProps): JSX.Element | null {
  const [overflow] = useState<number>(topCount + Number(bottomCount) - 2)

  if (!users || users.length === 0) {
    return null
  }

  return (
    <div className={assembleClassNames('flex items-center', className)}>
      <AvatarGroup
        className={`mr-${overflow > 0 ? 12 : 8}`}
        overflow={overflow}
        users={users}
      />
      <div>
        {topCount + Number(bottomCount) > 1 || users[0]['handle'].length === 0
          ? pluralizeWithNumber(topCount, topLabel)
          : `By ${users[0]['handle']}`}
        {bottomCount &&
        bottomLabel &&
        bottomCount > 0 &&
        bottomLabel.length > 0 ? (
          <div className="font-normal">
            {pluralizeWithNumber(bottomCount, bottomLabel)}
          </div>
        ) : null}
      </div>
    </div>
  )
}
