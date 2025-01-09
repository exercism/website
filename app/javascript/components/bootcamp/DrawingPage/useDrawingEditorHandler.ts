import { useRef, useState } from 'react'
import type { EditorView } from 'codemirror'
import type { Handler } from '../SolveExercisePage/CodeMirror/CodeMirror'
import DrawExercise from '../SolveExercisePage/exercises/draw'
import { interpret } from '@/interpreter/interpreter'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import { showError } from '../SolveExercisePage/utils/showError'
import { AnimationTimeline } from '../SolveExercisePage/AnimationTimeline/AnimationTimeline'
import type { Frame } from '@/interpreter/frames'

export function useDrawingEditorHandler({
  drawing,
  code,
  links,
}: DrawingPageProps) {
  const editorHandler = useRef<Handler | null>(null)
  const editorViewRef = useRef<EditorView | null>(null)
  const viewContainerRef = useRef<HTMLDivElement | null>(null)
  const [animationTimeline, setAnimationTimeline] =
    useState<AnimationTimeline>()
  const [frames, setFrames] = useState<Frame[]>([])

  const [latestValueSnapshot, setLatestValueSnapshot] = useState<
    string | undefined
  >(undefined)

  const handleEditorDidMount = (handler: Handler) => {
    editorHandler.current = handler
    // run code on mount
    handleRunCode()
  }

  const getStudentCode = () => {
    if (editorViewRef.current) {
      return editorViewRef.current.state.doc.toString()
    }
  }

  const {
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    setShouldShowInformationWidget,
    setUnderlineRange,
    setHasCodeBeenEdited,
  } = useEditorStore()

  const handleRunCode = () => {
    document.querySelectorAll('.exercise-container').forEach((e) => e.remove())
    setHasCodeBeenEdited(false)
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
      setFrames(frames)

      const { animations } = drawExerciseInstance
      const animationTimeline =
        animations.length > 0
          ? new AnimationTimeline({}, frames).populateTimeline(animations)
          : null

      if (animationTimeline) {
        setAnimationTimeline(animationTimeline)
      }

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
    }
  }

  return {
    handleEditorDidMount,
    handleRunCode,
    getStudentCode,
    editorHandler,
    latestValueSnapshot,
    editorViewRef,
    viewContainerRef,
    animationTimeline,
    frames,
  }
}
