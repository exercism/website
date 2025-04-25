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
  code: CSSExercisePageCode
  handleCompare: () => Promise<number>
  resetEditors: () => void
  handleHtmlEditorDidMount: (handler: Handler) => void
  handleCssEditorDidMount: (handler: Handler) => void
  setEditorCodeLocalStorage: React.Dispatch<
    React.SetStateAction<{
      htmlEditorContent: string
      cssEditorContent: string
      readonlyRanges: {
        css: ReadonlyRange[]
        html: ReadonlyRange[]
      }
      storedAt: string
    }>
  >
  links: CSSExercisePageProps['links']
  solution: CSSExercisePageProps['solution']
}

export const CSSExercisePageContext = createContext<CSSExercisePageContextType>(
  {} as CSSExercisePageContextType
)
