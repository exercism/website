import React from 'react'
import { Icon } from '../..'

export const Outdated = (): JSX.Element => {
  return (
    <Icon
      className="--out-of-date"
      icon="warning"
      alt="The solution has not been solved against the latest version of the exercise"
    />
  )
}
