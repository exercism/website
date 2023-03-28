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

  const handleMouseUp = () => {
    const selection = window.getSelection()
    const fragment = selection?.getRangeAt(0).cloneContents()
    const div = document.createElement('div')
    div.appendChild(fragment)
    const idxDivs = div.querySelectorAll('.idx')
    idxDivs.forEach((idxDiv) => {
      idxDiv.remove()
    })

    const range = document.createRange()
    const startNode = div.firstChild?.firstChild
    const endNode = div.lastChild?.firstChild
    if (startNode && endNode) {
      range.setStart(startNode, 0)
      range.setEnd(endNode, endNode.textContent?.length || 0)
      selection?.removeAllRanges()
      selection?.addRange(range)
    }
    console.log(range.toString())
  }

  return (
    <pre ref={parentRef} onMouseUp={handleMouseUp}>
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
