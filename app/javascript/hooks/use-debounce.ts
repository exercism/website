import { useState, useEffect } from 'react'

export function useDebounce<TValue>(value: TValue, delay: number): TValue {
  const [debouncedValue, setDebouncedValue] = useState<TValue>(value)

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => {
      clearTimeout(handler)
    }
  }, [value, delay])

  return debouncedValue
}
