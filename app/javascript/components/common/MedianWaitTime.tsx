import React from 'react'
import {
  durationFromSeconds,
  durationTimeElementFromSeconds,
} from '../../utils/time'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type MedianWaitTimeProps = {
  seconds?: number
}

export function MedianWaitTime({ seconds }: MedianWaitTimeProps) {
  const { t } = useAppTranslation()

  if (seconds === undefined || seconds === null) {
    return null
  }

  const medianWaitTime = durationFromSeconds(seconds)

  return (
    <div>
      {t('medianWaitTime.avgWaitTime')}
      <time
        dateTime={durationTimeElementFromSeconds(seconds)}
        title={`Median wait time: ${medianWaitTime}`}
      >
        {medianWaitTime}
      </time>
    </div>
  )
}
