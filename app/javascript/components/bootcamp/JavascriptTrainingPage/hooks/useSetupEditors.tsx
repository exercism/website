import { useLocalStorage } from '@uidotdev/usehooks'
import { useEditorHandler } from './useEditorHandler'

export function useSetupEditors() {
  const [editorCode, setEditorCode] = useLocalStorage('frontend-editor-code', {
    htmlEditorContent: '',
    cssEditorContent: '',
    javaScriptEditorContent: '',
  })
  const {
    editorViewRef: htmlEditorViewRef,
    handleEditorDidMount: handleHtmlEditorDidMount,
  } = useEditorHandler(editorCode.htmlEditorContent)
  const {
    editorViewRef: cssEditorViewRef,
    handleEditorDidMount: handleCssEditorDidMount,
  } = useEditorHandler(editorCode.cssEditorContent)

  const {
    editorViewRef: javaScriptEditorViewRef,
    handleEditorDidMount: handleJavaScriptEditorDidMount,
  } = useEditorHandler(editorCode.javaScriptEditorContent)

  return {
    htmlEditorViewRef,
    cssEditorViewRef,
    javaScriptEditorViewRef,
    handleHtmlEditorDidMount,
    handleCssEditorDidMount,
    handleJavaScriptEditorDidMount,
    setEditorCodeLocalStorage: setEditorCode,
  }
}
