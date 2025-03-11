import React, { useRef } from 'react'
import {
  Resizer,
  useResizablePanels,
} from '../SolveExercisePage/hooks/useResize'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { useHtmlEditorHandler } from './useHtmlEditorHandler'
import { Instructions } from '../SolveExercisePage/Instructions/Instructions'
import { html } from '@codemirror/lang-html'
import { basicLight } from 'cm6-theme-basic-light'
import { Prec } from '@codemirror/state'
import { ActualOutput } from './ActualOutput'
import { ExpectedOutput } from './ExpectedOutput'
import { updateIFrame } from './updateIFrame'
import { toPixelData } from 'html-to-image'
import toast, { Toaster } from 'react-hot-toast'

export default function FrontendTrainingPage() {
  const {
    primarySize: TopHeight,
    secondarySize: BottomHeight,
    handleMouseDown: handleHeightChangeMouseDown,
  } = useResizablePanels({
    initialSize: 500,
    secondaryMinSize: 250,
    direction: 'vertical',
    localStorageId: 'frontend-training-page-lhs-height',
  })

  const actualIFrameRef = useRef<HTMLIFrameElement>(null)
  const expectedIFrameRef = useRef<HTMLIFrameElement>(null)

  const {
    primarySize: LHSWidth,
    secondarySize: RHSWidth,
    handleMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    direction: 'horizontal',
    localStorageId: 'solve-exercise-page-lhs',
  })

  const {
    editorViewRef: htmlEditorViewRef,
    handleEditorDidMount: handleHtmlEditorDidMount,
  } = useHtmlEditorHandler()
  const {
    editorViewRef: cssEditorViewRef,
    handleEditorDidMount: handleCssEditorDidMount,
  } = useHtmlEditorHandler()

  return (
    <div id="bootcamp-custom-function-editor-page">
      <div className="page-body">
        <div className="page-body-lhs" style={{ width: LHSWidth }}>
          <CodeMirror
            style={{ height: `${TopHeight}px` }}
            editorDidMount={handleHtmlEditorDidMount}
            extensions={[Prec.highest([html(), basicLight])]}
            onEditorChangeCallback={(view) => {
              const html = view.state.doc.toString()
              const css = cssEditorViewRef.current?.state.doc.toString() || ''
              updateIFrame(actualIFrameRef, html, css)
            }}
            handleRunCode={() => {}}
            ref={htmlEditorViewRef}
          />
          <Resizer
            direction="horizontal"
            handleMouseDown={handleHeightChangeMouseDown}
          />
          <CodeMirror
            style={{ height: `${BottomHeight}px` }}
            editorDidMount={handleCssEditorDidMount}
            onEditorChangeCallback={(view) => {
              const css = view.state.doc.toString()
              const html = htmlEditorViewRef.current?.state.doc.toString() || ''
              updateIFrame(actualIFrameRef, html, css)
            }}
            handleRunCode={() => {}}
            ref={cssEditorViewRef}
          />
        </div>

        <div className="flex flex-col gap-12">
          <button
            onClick={async () => {
              // const isEqual = await compareIframes(actualIFrameRef, expectedIFrameRef)
              const percentage = await getIframesMatchPercentage(
                actualIFrameRef,
                expectedIFrameRef
              )
              if (percentage === 100) {
                toast.success(`MATCHING! ${percentage}%`)
              } else {
                toast.error(`NOT MATCHING! ${percentage}%`)
              }
            }}
            className="btn-xxs btn-primary"
          >
            Compare
          </button>
          <ActualOutput ref={actualIFrameRef} />
          <ExpectedOutput ref={expectedIFrameRef} />
        </div>
        <Resizer direction="vertical" handleMouseDown={handleMouseDown} />
        <div className="page-body-rhs" style={{ width: RHSWidth }}>
          <Instructions
            exerciseTitle="Css world!"
            exerciseInstructions="<div>Follow these instructions</div>"
          />
        </div>
      </div>
      <Toaster />
    </div>
  )
}

export async function captureIframeContent(
  iframeRef: React.RefObject<HTMLIFrameElement>
): Promise<Uint8ClampedArray | null> {
  if (!iframeRef.current) return null

  const iframe = iframeRef.current
  const iframeDoc = iframe.contentDocument || iframe.contentWindow?.document
  if (!iframeDoc || !iframeDoc.body) return null

  try {
    return await toPixelData(iframeDoc.body)
  } catch (error) {
    console.error('Error capturing iframe content:', error)
    return null
  }
}

export async function getIframesMatchPercentage(
  actualIFrameRef: React.RefObject<HTMLIFrameElement>,
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
): Promise<number> {
  const actualPixels = await captureIframeContent(actualIFrameRef)
  const expectedPixels = await captureIframeContent(expectedIFrameRef)

  if (!actualPixels || !expectedPixels) return 0

  if (actualPixels.length !== expectedPixels.length) return 0

  let differentPixels = 0
  const totalPixels = actualPixels.length / 4

  for (let i = 0; i < actualPixels.length; i += 4) {
    const rDiff = Math.abs(actualPixels[i] - expectedPixels[i])
    const gDiff = Math.abs(actualPixels[i + 1] - expectedPixels[i + 1])
    const bDiff = Math.abs(actualPixels[i + 2] - expectedPixels[i + 2])
    const aDiff = Math.abs(actualPixels[i + 3] - expectedPixels[i + 3])

    const threshold = 10
    if (
      rDiff > threshold ||
      gDiff > threshold ||
      bDiff > threshold ||
      aDiff > threshold
    ) {
      differentPixels++
    }
  }

  console.log('differentPixels', differentPixels)

  const matchPercentage = ((1 - differentPixels / totalPixels) * 100).toFixed(2)
  return parseFloat(matchPercentage)
}
