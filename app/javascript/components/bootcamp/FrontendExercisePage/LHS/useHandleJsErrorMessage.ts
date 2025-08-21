import { useEffect } from 'react'
import { extractLineAndColumnFromStack } from '../utils/extractLineColFromStackMessage'
import { jsLineOffset } from '../utils/updateIFrame'
import { showJsError } from './showJsError'
import { EditorView } from 'codemirror'
import { TabIndex } from './LHS'

export function useHandleJsErrorMessage({
  jsViewRef,
  setTab,
}: {
  jsViewRef: React.RefObject<EditorView>
  setTab: React.Dispatch<React.SetStateAction<TabIndex>>
}) {
  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const data = event.data
      if (
        data?.type === 'iframe-js-error' ||
        data?.type === 'iframe-js-parse-error'
      ) {
        setTab('javascript')

        const { column, line } = extractLineAndColumnFromStack(data.stack)

        const adjustedLineNumber = Math.min(
          Math.max(1, line - jsLineOffset),
          jsViewRef.current?.state.doc.lines || 1
        )

        showJsError(jsViewRef.current, {
          message: data.message,
          // column gets adjusted + positioned in showJsError
          colNumber: column,
          lineNumber: adjustedLineNumber,
        })
      }
    }

    window.addEventListener('message', handleMessage)
    return () => window.removeEventListener('message', handleMessage)
  }, [])
}
