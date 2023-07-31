import React from 'react'
import {
  durationFromSeconds,
  durationTimeElementFromSeconds,
} from '../../utils/time'

type MedianWaitTimeProps = {
  seconds?: number
}

export function MedianWaitTime({ seconds }: MedianWaitTimeProps) {
  if (seconds === undefined || seconds === null) {
    return null
  }

  const medianWaitTime = durationFromSeconds(seconds)

  return (
    <div>
      Avg. wait time: ~
      <time
        dateTime={durationTimeElementFromSeconds(seconds)}
        title={`Median wait time: ${medianWaitTime}`}
      >
        {medianWaitTime}
      </time>
    </div>
  )
}
