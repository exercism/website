import { EditorView } from 'codemirror'
import { createContext } from 'react'
import { Handler } from '../SolveExercisePage/CodeMirror/CodeMirror'

type FrontendTrainingPageContextType = {
  actualIFrameRef: React.RefObject<HTMLIFrameElement>
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
  expectedReferenceIFrameRef: React.RefObject<HTMLIFrameElement>
  htmlEditorRef: React.RefObject<EditorView>
  cssEditorRef: React.RefObject<EditorView>
  javaScriptEditorRef: React.RefObject<EditorView>
  handleHtmlEditorDidMount: (handler: Handler) => void
  handleCssEditorDidMount: (handler: Handler) => void
  handleJavaScriptEditorDidMount: (handler: Handler) => void
}

export const FrontendTrainingPageContext =
  createContext<FrontendTrainingPageContextType>(
    {} as FrontendTrainingPageContextType
  )
