import { Icon } from './common'
import React from 'react'

export const ResultsZone = ({
  isFetching,
  children,
}: React.PropsWithChildren<{ isFetching: boolean }>): JSX.Element => {
  const classNames = `c-results-zone ${isFetching ? '--fetching' : ''}`
  return (
    <div className={classNames}>
      {children}
      <div className="--fetching-overlay">
        <Icon icon="spinner" alt="Loading data" />
      </div>
    </div>
  )
}
