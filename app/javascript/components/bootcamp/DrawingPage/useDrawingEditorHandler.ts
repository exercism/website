import { useRef, useState } from 'react'
import type { EditorView } from 'codemirror'
import type { Handler } from '../SolveExercisePage/CodeMirror/CodeMirror'
import DrawExercise from '../SolveExercisePage/exercises/draw'
import { interpret } from '@/interpreter/interpreter'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import { showError } from '../SolveExercisePage/utils/showError'
import { AnimationTimeline } from '../SolveExercisePage/AnimationTimeline/AnimationTimeline'

export function useDrawingEditorHandler({
  drawing,
  code,
  links,
}: DrawingPageProps) {
  const editorHandler = useRef<Handler | null>(null)
  const editorViewRef = useRef<EditorView | null>(null)
  const [view, setView] = useState<ReturnType<
    typeof DrawExercise.prototype.getView
  > | null>(null)
  const viewContainerRef = useRef<HTMLDivElement | null>(null)

  const [latestValueSnapshot, setLatestValueSnapshot] = useState<
    string | undefined
  >(undefined)

  const handleEditorDidMount = (handler: Handler) => {
    editorHandler.current = handler
  }

  const {
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    setShouldShowInformationWidget,
    setUnderlineRange,
  } = useEditorStore()

  const handleRunCode = () => {
    document.querySelectorAll('.exercise-container').forEach((e) => e.remove())
    const drawExerciseInstance = new DrawExercise()
    if (editorHandler.current) {
      const value = editorHandler.current.getValue()
      setLatestValueSnapshot(value)
      // value is studentCode
      const evaluated = interpret(value, {
        externalFunctions: drawExerciseInstance?.availableFunctions,
        language: 'JikiScript',
      })

      const { frames } = evaluated

      const { animations } = drawExerciseInstance
      const animationTimeline =
        animations.length > 0
          ? new AnimationTimeline({}, frames).populateTimeline(animations)
          : null

      if (evaluated.error) {
        showError({
          error: evaluated.error,
          setHighlightedLine,
          setHighlightedLineColor,
          setInformationWidgetData,
          setShouldShowInformationWidget,
          setUnderlineRange,
        })
      }

      console.log(evaluated, value, animationTimeline)
      const view = drawExerciseInstance.getView()

      if (view) {
        if (!viewContainerRef.current) return
        if (viewContainerRef.current.children.length > 0) {
          const oldView = viewContainerRef.current.children[0] as HTMLElement
          document.body.appendChild(oldView)
          oldView.style.display = 'none'
        }

        // on each result change, clear out view-container
        viewContainerRef.current.innerHTML = ''
        viewContainerRef.current.appendChild(view)
        view.style.display = 'block'
      }

      setView(view)
    }
  }

  return {
    handleEditorDidMount,
    handleRunCode,
    editorHandler,
    latestValueSnapshot,
    editorViewRef,
    view,
    viewContainerRef,
  }
}
