import React, { useState, useCallback } from 'react'

export function useLocalStorage(key, initialValue) {
  const [storedValue, setStoredValue] = useState(() => {
    const item = localStorage.getItem(key)
    return item ? item : initialValue
  })

  const setValue = useCallback(
    (value) => {
      setStoredValue(value)
      localStorage.setItem(key, value)
    },
    [setStoredValue, localStorage, key]
  )

  const removeValue = useCallback(() => {
    localStorage.removeItem(key)
  })

  return [storedValue, setValue]
}
