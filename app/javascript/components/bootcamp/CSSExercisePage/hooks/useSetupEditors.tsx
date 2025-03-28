import { useLocalStorage } from '@uidotdev/usehooks'
import { useEditorHandler } from './useEditorHandler'

export function useSetupEditors(slug: string) {
  const [editorCode, setEditorCode] = useLocalStorage(
    `css-editor-code-${slug}`,
    {
      htmlEditorContent: '',
      cssEditorContent: '',
    }
  )
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
