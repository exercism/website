import React from 'react'
import pluralize from 'pluralize'
import { Track } from '../ChooseTrackStep'

export const TrackCheckbox = ({
  id,
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
    <div className="track-checkbox">
      <input
        type="checkbox"
        id={id}
        checked={checked}
        onChange={onChange}
        aria-labelledby={`${id}-label`}
      />
      <label className="track" htmlFor={title} id={`${id}-label`}>
        <div className="selected-icon" />
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
