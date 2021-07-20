import { useEffect } from 'react'
import { useLocalStorage } from '../../utils/use-storage'
import { File } from '../types'

export const useSaveFiles = (
  storageKey: string,
  initialFiles: File[],
  saveInterval: number,
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
    }, saveInterval)

    return () => clearInterval(interval)
  }, [files, getFiles, saveInterval, setFiles])

  return [files, setFiles]
}
