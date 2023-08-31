import { useEffect, useState } from 'react'

export function useLatestData<T>(data: T): T | undefined {
  const [latestData, setLatestData] = useState<T>()

  useEffect(() => {
    if (data) setLatestData(data)
  }, [data])

  return latestData
}
