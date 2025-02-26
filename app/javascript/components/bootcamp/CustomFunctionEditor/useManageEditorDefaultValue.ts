import { useEffect, useMemo } from 'react'
import { useLocalStorage } from '@uidotdev/usehooks'
import { CustomFunction } from './CustomFunctionEditor'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import { debounce } from 'lodash'

export function useManageEditorDefaultValue(customFunction: CustomFunction) {
  const [editorLocalStorageValue, setEditorLocalStorageValue] = useLocalStorage(
    `custom-fn-editor-${customFunction.uuid}`,
    { code: customFunction.code }
  )

  const { setDefaultCode } = useEditorStore()

  useEffect(() => {
    setDefaultCode(editorLocalStorageValue.code)
  }, [])

  const updateLocalStorageValueOnDebounce = useMemo(() => {
    return debounce((value: string) => {
      setEditorLocalStorageValue({
        code: value,
      })
    }, 500)
  }, [])

  return { updateLocalStorageValueOnDebounce }
}
