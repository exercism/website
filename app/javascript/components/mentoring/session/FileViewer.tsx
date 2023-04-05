import React from 'react'
import { File } from '../../types'
import { useHighlighting } from '../../../utils/highlight'

export const FileViewer = ({
  language,
  indentSize,
  file,
}: {
  language: string
  indentSize: number
  file: File
}): JSX.Element => {
  const parentRef = useHighlighting<HTMLPreElement>()

  return (
    <pre ref={parentRef}>
      <code
        className={`language-${language}`}
        data-highlight-line-numbers={true}
        data-highlight-line-number-start={1}
        style={{ tabSize: indentSize }}
      >
        {file.content}
      </code>
    </pre>
  )
}
