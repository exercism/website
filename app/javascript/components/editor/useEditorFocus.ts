import { useEffect, useRef } from 'react'
import { FileEditorHandle } from './FileEditorCodeMirror'

export const useEditorFocus = ({
  editor,
  isProcessing,
}: {
  editor?: FileEditorHandle
  isProcessing: boolean
}): void => {
  const previouslyProcessedRef = useRef(false)

  useEffect(() => {
    if (!editor) {
      return
    }

    if (!previouslyProcessedRef.current) {
      previouslyProcessedRef.current = true

      return
    }

    if (isProcessing) {
      return
    }

    editor.focus()
  }, [editor, isProcessing])
}
