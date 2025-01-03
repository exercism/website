import { useRef, useState } from 'react'
import { useOnRunCode } from '../hooks/useOnRunCode/useOnRunCode'
import { cleanUpEditor } from './extensions/clean-up-editor'
import type { EditorView } from 'codemirror'
import type { Handler } from './CodeMirror'
import { updateReadOnlyRangesEffect } from './extensions/read-only-ranges/readOnlyRanges'

export function useEditorHandler({
  links,
  code,
  config,
}: Pick<SolveExercisePageProps, 'links' | 'code'> & { config: Config }) {
  const editorHandler = useRef<Handler | null>(null)
  const editorViewRef = useRef<EditorView | null>(null)

  const [latestValueSnapshot, setLatestValueSnapshot] = useState<
    string | undefined
  >(undefined)

  const handleEditorDidMount = (handler: Handler) => {
    editorHandler.current = handler
    setupEditor(editorViewRef.current, code)
  }

  const onRunCode = useOnRunCode({
    links,
    config,
  })

  const resetEditorToStub = () => {
    if (editorHandler.current) {
      editorHandler.current.setValue(code.stub)
    }
  }

  const handleRunCode = () => {
    if (editorViewRef.current) {
      cleanUpEditor(editorViewRef.current)
    }
    if (editorHandler.current) {
      const value = editorHandler.current.getValue()

      setLatestValueSnapshot(value)
      onRunCode(value, editorViewRef.current)
    }
  }

  return {
    handleEditorDidMount,
    handleRunCode,
    editorHandler,
    latestValueSnapshot,
    editorViewRef,
    resetEditorToStub,
  }
}

function setupEditor(editorView: EditorView | null, code: Code) {
  if (!editorView || !code || !code.readonlyRanges) return
  editorView.dispatch({
    effects: updateReadOnlyRangesEffect.of(code.readonlyRanges),
  })
}
