import React from 'react'
import { useContinuousHighlighting } from '@/hooks/use-syntax-highlighting'
import type { File } from '@/components/types'

export const FileViewer = ({
  language,
  indentSize,
  file,
}: {
  language: string
  indentSize: number
  file: File
}): JSX.Element => {
  const parentRef = useContinuousHighlighting<HTMLPreElement>(file.content)

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
