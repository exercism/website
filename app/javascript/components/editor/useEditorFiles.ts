import { useCallback } from 'react'
import { FileEditorHandle } from './FileEditorCodeMirror'
import { File } from '../types'

export const useEditorFiles = ({
  defaultFiles,
  editorRef,
}: {
  defaultFiles: File[]
  editorRef: React.MutableRefObject<FileEditorHandle | undefined>
}): { get: () => File[]; set: (files: File[]) => void } => {
  const get = useCallback(() => {
    const files = editorRef.current?.getFiles()

    if (!files || files.length === 0) {
      return defaultFiles
    }

    return files
  }, [defaultFiles, editorRef])
  const set = useCallback(
    (files) => editorRef.current?.setFiles(files),
    [editorRef]
  )

  return { get, set }
}
