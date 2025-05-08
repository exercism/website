import { EditorView } from 'codemirror'
import { createContext } from 'react'
import { Handler } from '../JikiscriptExercisePage/CodeMirror/CodeMirror'

type FrontendTrainingPageContextType = {
  actualIFrameRef: React.RefObject<HTMLIFrameElement>
  htmlEditorRef: React.RefObject<EditorView>
  cssEditorRef: React.RefObject<EditorView>
  jsEditorRef: React.RefObject<EditorView>
  handleHtmlEditorDidMount: (handler: Handler) => void
  handleCssEditorDidMount: (handler: Handler) => void
  handleJsEditorDidMount: (handler: Handler) => void
  setEditorCodeLocalStorage: React.Dispatch<
    React.SetStateAction<{
      htmlEditorContent: string
      cssEditorContent: string
      jsEditorContent: string
      readonlyRanges: {
        css: ReadonlyRange[]
        html: ReadonlyRange[]
        js: ReadonlyRange[]
      }
      storedAt: string
    }>
  >
}

export const FrontendTrainingPageContext =
  createContext<FrontendTrainingPageContextType>(
    {} as FrontendTrainingPageContextType
  )
