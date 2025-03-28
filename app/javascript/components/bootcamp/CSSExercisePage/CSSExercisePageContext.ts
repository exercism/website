import { EditorView } from 'codemirror'
import { createContext } from 'react'
import { Handler } from '../JikiscriptExercisePage/CodeMirror/CodeMirror'

type CSSExercisePageContextType = {
  actualIFrameRef: React.RefObject<HTMLIFrameElement>
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
  expectedReferenceIFrameRef: React.RefObject<HTMLIFrameElement>
  htmlEditorRef: React.RefObject<EditorView>
  cssEditorRef: React.RefObject<EditorView>
  exercise: CSSExercisePageExercise
  handleCompare: () => void
  handleHtmlEditorDidMount: (handler: Handler) => void
  handleCssEditorDidMount: (handler: Handler) => void
  setEditorCodeLocalStorage: React.Dispatch<
    React.SetStateAction<{
      htmlEditorContent: string
      cssEditorContent: string
      storedAt: string
    }>
  >
}

export const CSSExercisePageContext = createContext<CSSExercisePageContextType>(
  {} as CSSExercisePageContextType
)
