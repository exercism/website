import React, { useEffect } from 'react'
import { useLocalStorage } from '../../utils/use-storage'
import { File } from '../types'

const SAVE_INTERVAL = 500

export const useSaveFiles = (
  storageKey: string,
  initialFiles: File[],
  getFiles: () => File[]
): [File[], (files: File[]) => void] => {
  const [files, setFiles] = useLocalStorage<File[]>(
    `solution-files-${storageKey}`,
    initialFiles
  )

  useEffect(() => {
    const interval = setInterval(() => {
      const newFiles = getFiles()

      if (JSON.stringify(files) === JSON.stringify(newFiles)) {
        return
      }

      setFiles(getFiles())
    }, SAVE_INTERVAL)

    return () => clearInterval(interval)
  }, [files, getFiles, setFiles])

  return [files, setFiles]
}
