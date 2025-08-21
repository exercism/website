import { Dispatch, SetStateAction, useRef, useState } from 'react'
import { useConstructRunCode } from '../hooks/useConstructRunCode/useConstructRunCode'
import type { EditorView } from 'codemirror'
import type { Handler } from './CodeMirror'
import { updateReadOnlyRangesEffect } from './extensions/read-only-ranges/readOnlyRanges'
import useEditorStore from '../store/editorStore'
import useErrorStore from '../store/errorStore'
import { ExerciseLocalStorageData } from '../JikiscriptExercisePageContextWrapper'
import { updateUnfoldableFunctions } from './unfoldableFunctionNames'

export function useEditorHandler({
  links,
  code,
  exercise,
  exerciseLocalStorageData,
  setExerciseLocalStorageData,
  unfoldableFunctionNames,
}: Pick<JikiscriptExercisePageProps, 'links' | 'code' | 'exercise'> & {
  exerciseLocalStorageData: ExerciseLocalStorageData
  setExerciseLocalStorageData: Dispatch<
    SetStateAction<ExerciseLocalStorageData>
  >
  unfoldableFunctionNames: string[]
}) {
  const editorHandler = useRef<Handler | null>(null)
  const editorViewRef = useRef<EditorView | null>(null)
  const { setDefaultCode } = useEditorStore()
  const { setHasUnhandledError, setUnhandledErrorBase64 } = useErrorStore()

  const [latestValueSnapshot, setLatestValueSnapshot] = useState<
    string | undefined
  >(undefined)

  const handleEditorDidMount = (handler: Handler) => {
    editorHandler.current = handler

    if (
      // if there is no storedAt it means we have not submitted the code yet, ignore this, and keep using localStorage
      // localStorage defaults to the stub code.
      exerciseLocalStorageData.storedAt &&
      code.storedAt &&
      // if the code on the server is newer than in localstorage, update the storage and load the code from the server
      // ---
      // code on the server must be newer by at least a minute
      new Date(exerciseLocalStorageData.storedAt).getTime() <
        new Date(code.storedAt).getTime() - 60000
    ) {
      setExerciseLocalStorageData({
        code: code.code,
        storedAt: code.storedAt,
        readonlyRanges: code.readonlyRanges,
      })
      setDefaultCode(code.code)
      setupEditor(editorViewRef.current, unfoldableFunctionNames, code)
    } else {
      // otherwise we are using the code from the storage
      setDefaultCode(exerciseLocalStorageData.code)
      setupEditor(
        editorViewRef.current,
        unfoldableFunctionNames,
        exerciseLocalStorageData
      )
    }

    if (code.storedAt && exercise.language !== 'javascript') {
      handleRunCode()
    }
  }

  const runCode = useConstructRunCode({
    links,
    config: exercise.config,
    language: exercise.language,
  })

  const resetEditorToStub = () => {
    if (editorHandler.current) {
      setExerciseLocalStorageData({
        code: code.stub,
        storedAt: new Date().toISOString(),
        readonlyRanges: code.readonlyRanges,
      })
      setupEditor(editorViewRef.current, unfoldableFunctionNames, {
        code: '',
        readonlyRanges: [],
      })
      setupEditor(editorViewRef.current, unfoldableFunctionNames, {
        code: code.stub,
        readonlyRanges: code.defaultReadonlyRanges,
      })
    }
  }

  const handleRunCode = () => {
    if (editorHandler.current) {
      const value = editorHandler.current.getValue()

      setLatestValueSnapshot(value)
      try {
        //const time = performance.now()
        runCode(value, editorViewRef.current)
        //console.log('Duration', performance.now() - time)
      } catch (e: unknown) {
        if (
          process.env.NODE_ENV === 'development' ||
          process.env.NODE_ENV === 'test'
        ) {
          throw e
        }

        setHasUnhandledError(true)
        setUnhandledErrorBase64(
          JSON.stringify({
            error: String(e),
            code: value,
            type: 'Error firing runCode',
          })
        )
      }
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

function setupEditor(
  editorView: EditorView | null,
  unfoldableFunctionNames: string[],
  {
    readonlyRanges,
    code,
  }: { readonlyRanges?: { from: number; to: number }[]; code: string }
) {
  if (!editorView) return

  // This needs to happen before the code is added.
  updateUnfoldableFunctions(editorView, unfoldableFunctionNames)

  if (code) {
    editorView.dispatch({
      changes: {
        from: 0,
        to: editorView.state.doc.length,
        insert: code,
      },
    })
  }
  if (readonlyRanges) {
    editorView.dispatch({
      effects: updateReadOnlyRangesEffect.of(readonlyRanges),
    })
  }
}
