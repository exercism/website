import React from 'react'
import { File } from '../../types'
import { useHighlighting } from '../../../utils/highlight'

export const FileViewer = ({
  language,
  file,
}: {
  language: string
  file: File
}): JSX.Element => {
  const parentRef = useHighlighting<HTMLPreElement>()

  return (
    <pre ref={parentRef}>
      <code
        className={language}
        data-highlight-line-numbers={true}
        data-highlight-line-number-start={1}
        dangerouslySetInnerHTML={{ __html: file.content }}
      />
    </pre>
  )
}
