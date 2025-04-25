import { useEffect } from 'react'
import useEditorStore from '../JikiscriptExercisePage/store/editorStore'

export function useSetupDrawingPage({
  editorLocalStorageValue,
  setEditorLocalStorageValue,
  code,
}) {
  const { setDefaultCode, setShouldAutoRunCode } = useEditorStore()

  // Setup hook
  useEffect(() => {
    if (
      editorLocalStorageValue.storedAt &&
      code.storedAt &&
      // if the code on the server is newer than in localstorage, update the storage and load the code from the server
      editorLocalStorageValue.storedAt < code.storedAt
    ) {
      setEditorLocalStorageValue({ code: code.code, storedAt: code.storedAt })
      setDefaultCode(code.code)
    } else {
      // otherwise we are using the code from the storage
      setDefaultCode(editorLocalStorageValue.code)
    }
    setShouldAutoRunCode(true)
  }, [code, setDefaultCode, setEditorLocalStorageValue])
}
