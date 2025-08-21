import { EditorView } from 'codemirror'
import { createContext } from 'react'
import { Handler } from '../JikiscriptExercisePage/CodeMirror/CodeMirror'

type FrontendExercisePageContextType = {
  links: FrontendExercisePageProps['links']
  exercise: FrontendExercisePageProps['exercise']
  solution: FrontendExercisePageProps['solution']
  code: FrontendExercisePageProps['code']
  defaultCode: FrontendExercisePageProps['code']['default']
  resetEditors: () => void
  actualIFrameRef: React.RefObject<HTMLIFrameElement>
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
  expectedReferenceIFrameRef: React.RefObject<HTMLIFrameElement>
  htmlEditorRef: React.RefObject<EditorView>
  cssEditorRef: React.RefObject<EditorView>
  jsEditorRef: React.RefObject<EditorView>
  jsCodeRunId: React.MutableRefObject<number>
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

export const FrontendExercisePageContext =
  createContext<FrontendExercisePageContextType>(
    {} as FrontendExercisePageContextType
  )
