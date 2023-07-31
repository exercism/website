import React, { useEffect, useRef } from 'react'
import { Diff2HtmlUI } from 'diff2html/lib/ui/js/diff2html-ui-base.js'
import HighlightJS from 'highlight.js'

export const DiffViewer = ({ diff }: { diff: string }): JSX.Element => {
  const contentRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!contentRef.current) {
      return
    }

    const configuration = {
      drawFileList: false,
      fileListToggle: false,
      fileListStartVisible: false,
      fileContentToggle: false,
    }

    const diff2htmlUi = new Diff2HtmlUI(
      contentRef.current,
      diff,
      configuration,
      HighlightJS
    )
    diff2htmlUi.draw()
  }, [diff])

  return <div className="c-diff" ref={contentRef} />
}
