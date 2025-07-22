import React from 'react'
import pluralize from 'pluralize'
import { Icon, TrackIcon } from '@/components/common'
import { MedianWaitTime } from '@/components/common/MedianWaitTime'
import { Track } from '../TrackSelector'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TrackCheckbox = ({
  slug,
  title,
  iconUrl,
  medianWaitTime,
  numSolutionsQueued,
  checked,
  onChange,
}: Track & {
  checked: boolean
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/mentoring/track-selector')

  return (
    <div className="track">
      <input
        type="checkbox"
        id={slug}
        checked={checked}
        onChange={onChange}
        aria-labelledby={`${slug}-label`}
      />
      <label className="track" htmlFor={slug} id={`${slug}-label`}>
        {checked ? (
          <div className="selected-icon">
            <Icon icon="checkmark" alt={t('trackCheckbox.trackSelected')} />
          </div>
        ) : null}
        <TrackIcon iconUrl={iconUrl} title={title} />
        <div className="title">{title}</div>
        <div className="info">
          <MedianWaitTime seconds={medianWaitTime} />
          {numSolutionsQueued} {pluralize('solution', numSolutionsQueued)}{' '}
          queued
        </div>
      </label>
    </div>
  )
}
