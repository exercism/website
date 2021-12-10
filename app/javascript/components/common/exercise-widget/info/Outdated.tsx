import React from 'react'
import { Icon } from '../..'

export const Outdated = (): JSX.Element => {
  return (
    <Icon
      className="--out-of-date"
      icon="warning"
      alt="This solution was solved against an older version of this exercise"
    />
  )
}
