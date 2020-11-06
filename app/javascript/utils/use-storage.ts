import React, { useCallback } from 'react'
import { StoredMemoryValue, useMutableMemoryValue } from 'use-memory-value'

export function useStorage(key, initialValue) {
  const memoryValue = new StoredMemoryValue(key, true, initialValue)

  return useMutableMemoryValue(memoryValue)
}
