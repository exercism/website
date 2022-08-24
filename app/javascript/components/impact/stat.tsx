import React, { useEffect, useState } from 'react'
import { StatsChannel } from '../../channels/statsChannel'

export default ({
  metric,
  initialValue,
}: {
  metric: string
  initialValue: number
}): JSX.Element => {
  const [value, setValue] = useState(initialValue)

  useEffect(() => {
    const connection = new StatsChannel((data) => {
      if (metric != data.metric) {
        return
      }

      setValue(value + 1)
    })

    return () => connection.disconnect()
  }, [value])

  return <>{value.toLocaleString()}</>
}
