import { useLocalStorage } from '@uidotdev/usehooks'
import { useEditorHandler } from './useEditorHandler'

export function useSetupEditors() {
  const [editorCode, setEditorCode] = useLocalStorage('frontend-editor-code', {
    htmlEditorContent: '',
    cssEditorContent: '',
  })
  const {
    editorViewRef: htmlEditorViewRef,
    handleEditorDidMount: handleHtmlEditorDidMount,
  } = useEditorHandler(editorCode.htmlEditorContent)
  const {
    editorViewRef: cssEditorViewRef,
    handleEditorDidMount: handleCssEditorDidMount,
  } = useEditorHandler(editorCode.cssEditorContent)

  return {
    htmlEditorViewRef,
    cssEditorViewRef,
    handleHtmlEditorDidMount,
    handleCssEditorDidMount,
    setEditorCodeLocalStorage: setEditorCode,
  }
}
