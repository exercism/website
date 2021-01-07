import React, { useEffect, useState } from 'react'
import { File } from './types'
import { highlight } from '../utils/highlight'

export const FileViewer = ({
  language,
  file,
}: {
  language: string
  file: File
}): JSX.Element => {
  const [content, setContent] = useState('')

  useEffect(() => {
    setContent(highlight(language, file.content))
  }, [file, language])

  return (
    <div>
      <pre>
        <code dangerouslySetInnerHTML={{ __html: content }} />
      </pre>
    </div>
  )
}
