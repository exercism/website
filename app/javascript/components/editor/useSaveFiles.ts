import { useEffect } from 'react'
import { useLocalStorage } from '../../utils/use-storage'
import { File } from '../types'

export const useSaveFiles = ({
  key,
  saveInterval,
  getFiles,
}: {
  key: string
  saveInterval: number
  getFiles: () => File[]
}) => {
  const [files, setFiles] = useLocalStorage<File[]>(
    `solution-files-${key}`,
    getFiles()
  )

  useEffect(() => {
    const interval = setInterval(() => {
      const newFiles = getFiles()

      if (JSON.stringify(files) === JSON.stringify(newFiles)) {
        return
      }

      setFiles(newFiles)
    }, saveInterval)

    return () => clearInterval(interval)
  }, [JSON.stringify(files), getFiles, saveInterval, setFiles])

  return [files]
}
