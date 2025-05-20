import React, { useContext, useMemo } from 'react'
import { FrontendExercisePageContext } from '../../../FrontendExercisePageContext'
import { useFrontendExercisePageStore } from '../../../store/frontendExercisePageStore'
import { javascript } from '@codemirror/lang-javascript'
import { EDITOR_HEIGHT } from '../Panels'
import { SimpleCodeMirror } from '@/components/bootcamp/CSSExercisePage/SimpleCodeMirror/SimpleCodeMirror'
import {
  highlightLine,
  informationWidgetDataField,
  initReadOnlyRangesExtension,
  jsTheme,
  lineInformationExtension,
  readOnlyRangeDecoration,
  showInfoWidgetField,
  underlineExtension,
} from '@/components/bootcamp/JikiscriptExercisePage/CodeMirror/extensions'
import { eslintLinter } from '@/components/bootcamp/CSSExercisePage/SimpleCodeMirror/extensions/eslinter'
import { createUpdateLocalStorageValueOnDebounce } from '../utils/updateLocalStorageValueOnDebounce'
import { cleanUpEditorErrorState } from '../../showJsError'
import { moveCursorByPasteLength } from '@/components/bootcamp/JikiscriptExercisePage/CodeMirror/extensions/move-cursor-by-paste-length'

export function JavaScriptEditor() {
  const {
    jsEditorRef,
    htmlEditorRef,
    cssEditorRef,
    handleJsEditorDidMount,
    setEditorCodeLocalStorage,
    defaultCode,
  } = useContext(FrontendExercisePageContext)
  const {
    panelSizes: { LHSWidth },
  } = useFrontendExercisePageStore()

  const updateLocalStorageValueOnDebounce = useMemo(() => {
    return createUpdateLocalStorageValueOnDebounce()
  }, [setEditorCodeLocalStorage])

  return (
    <SimpleCodeMirror
      defaultCode={defaultCode.js}
      style={{ width: LHSWidth, height: EDITOR_HEIGHT }}
      editorDidMount={handleJsEditorDidMount}
      extensions={[
        javascript(),
        moveCursorByPasteLength,
        eslintLinter,
        jsTheme,
        readOnlyRangeDecoration(),
        initReadOnlyRangesExtension(),
        underlineExtension(),
        highlightLine(0),
        showInfoWidgetField,
        informationWidgetDataField,
        lineInformationExtension({
          onClose: (view) => {
            cleanUpEditorErrorState(view)
          },
        }),
      ]}
      // here we don't want to update the iframe on each keystroke, because that'd be really annoying
      onEditorChangeCallback={(view) => {
        updateLocalStorageValueOnDebounce(
          {
            cssEditor: cssEditorRef.current,
            htmlEditor: htmlEditorRef.current,
            jsEditor: view,
          },
          setEditorCodeLocalStorage
        )

        cleanUpEditorErrorState(view)
      }}
      ref={jsEditorRef}
    />
  )
}
