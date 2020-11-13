import React, { useCallback } from 'react'
import { StoredMemoryValue, useMutableMemoryValue } from 'use-memory-value'

export function useStorage<T>(key: string, initialValue: T) {
  const memoryValue = new StoredMemoryValue<T>(key, true, initialValue)

  return useMutableMemoryValue(memoryValue)
}
