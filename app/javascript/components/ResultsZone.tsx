import React, { useEffect, useState, useRef } from 'react'
import { Icon } from './common/Icon'

const DELAY_MS = 250

export const ResultsZone = (
  props: React.PropsWithChildren<{
    isFetching: boolean
    className?: string | null
  }>
): JSX.Element => {
  const [isFetching, setIsFetching] = useState(false)
  const timerRef = useRef<number | null>(null)
  const classNames = `c-results-zone ${isFetching ? '--fetching' : ''} ${
    props.className ?? ''
  }`

  useEffect(() => {
    if (props.isFetching) {
      timerRef.current = window.setTimeout(() => setIsFetching(true), DELAY_MS)
    } else {
      setIsFetching(false)

      if (timerRef.current) {
        window.clearTimeout(timerRef.current)
      }
    }

    return () => {
      if (!timerRef.current) {
        return
      }

      clearTimeout(timerRef.current)
    }
  }, [props.isFetching])

  return (
    <div className={classNames}>
      {props.children}
      <div className="--fetching-overlay">
        <Icon icon="spinner" className="animate-spin-slow" alt="Loading data" />
      </div>
    </div>
  )
}
