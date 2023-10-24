import React, { createContext, useCallback, useContext, useState } from 'react'
import { File } from '../types'

export const EditorFileContext = createContext<{
  files: File[]
  setFiles: React.Dispatch<React.SetStateAction<File[]>>
}>({ files: [], setFiles: () => null })

export function EditorFileWrapper({
  children,
  defaultFiles,
}: {
  children: React.ReactNode
  defaultFiles: File[]
}) {
  const [files, setFiles] = useState(defaultFiles)

  return (
    <EditorFileContext.Provider value={{ files, setFiles }}>
      {children}
    </EditorFileContext.Provider>
  )
}
