import { useEffect } from 'react'
import { useLocalStorage } from '../../utils/use-storage'
import { File } from '../types'

export const useSaveFiles = ({
  key,
  saveInterval,
  defaultFiles,
  getFiles,
}: {
  key: string
  saveInterval: number
  defaultFiles: File[]
  getFiles: () => File[] | undefined
}) => {
  const [files, setFiles] = useLocalStorage<File[]>(
    `solution-files-${key}`,
    defaultFiles
  )

  useEffect(() => {
    const interval = setInterval(() => {
      const newFiles = getFiles() || defaultFiles

      if (JSON.stringify(files) === JSON.stringify(newFiles)) {
        return
      }

      setFiles(newFiles)
    }, saveInterval)

    return () => clearInterval(interval)
  }, [files, getFiles, defaultFiles, saveInterval, setFiles])
}
