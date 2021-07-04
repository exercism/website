import React, { useCallback } from 'react'
import { Period } from '../ContributorsList'

export const PeriodButton = ({
  period,
  current,
  setPeriod,
  children,
}: React.PropsWithChildren<{
  period: Period
  current: Period
  setPeriod: (period: Period) => void
}>): JSX.Element => {
  const classNames = ['c-tab-2', period === current ? 'selected' : ''].filter(
    (className) => className.length > 0
  )

  const handleClick = useCallback(() => {
    setPeriod(period)
  }, [period, setPeriod])

  return (
    <button className={classNames.join(' ')} onClick={handleClick}>
      {children}
    </button>
  )
}
