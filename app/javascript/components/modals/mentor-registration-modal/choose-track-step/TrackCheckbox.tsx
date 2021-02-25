import React from 'react'
import pluralize from 'pluralize'
import { Track } from '../ChooseTrackStep'
import { Icon } from '../../../common'

export const TrackCheckbox = ({
  slug,
  title,
  iconUrl,
  avgWaitTime,
  numSolutionsQueued,
  checked,
  onChange,
}: Track & {
  checked: boolean
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void
}): JSX.Element => {
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
        <div className="selected-icon">
          <Icon icon="checkmark" alt="Track selected" />
        </div>
        {/* TODO: @iHiD I'm confused what to use here. icon URL or icon name? */}
        <img
          src={iconUrl}
          className="c-icon c-track-icon"
          role="presentation"
        />
        <div className="title">{title}</div>
        <div className="info">
          Avg. wait time ~ {avgWaitTime}
          <br />
          {numSolutionsQueued} {pluralize('solution', numSolutionsQueued)}{' '}
          queued
        </div>
      </label>
    </div>
  )
}
