import React from 'react'
import pluralize from 'pluralize'

export const SelectedTracksMessage = ({
  numSelected,
}: {
  numSelected: number
}): JSX.Element => {
  const classNames = ['selected', numSelected === 0 ? 'none' : ''].filter(
    (name) => name !== ''
  )
  const message =
    numSelected === 0
      ? 'No tracks selected'
      : `${numSelected} ${pluralize('track', numSelected)} selected`

  return <div className={classNames.join(' ')}>{message}</div>
}
