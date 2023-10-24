import { useEffect } from 'react'
import { useLocalStorage } from '../../utils/use-storage'
import { File } from '../types'

export const useSaveFiles = ({
  key,
  saveInterval,
  currentFiles,
}: {
  key: string
  saveInterval: number
  currentFiles: File[]
}) => {
  const [files, setFiles] = useLocalStorage<File[]>(
    `solution-files-${key}`,
    currentFiles
  )

  useEffect(() => {
    const interval = setInterval(() => {
      const newFiles = currentFiles

      if (JSON.stringify(files) === JSON.stringify(newFiles)) {
        return
      }

      setFiles(newFiles)
    }, saveInterval)

    return () => clearInterval(interval)
  }, [JSON.stringify(files), currentFiles, saveInterval, setFiles])

  return [files]
}
