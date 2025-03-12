import React, { createContext, useEffect, useRef } from 'react'
import {
  Resizer,
  useResizablePanels,
} from '../SolveExercisePage/hooks/useResize'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { useEditorHandler } from './useEditorHandler'
import { Instructions } from '../SolveExercisePage/Instructions/Instructions'
import { html } from '@codemirror/lang-html'
import { basicLight } from 'cm6-theme-basic-light'
import { Prec } from '@codemirror/state'
import { ActualOutput } from './ActualOutput'
import { ExpectedOutput } from './ExpectedOutput'
import { updateIFrame } from './utils/updateIFrame'
import toast, { Toaster } from 'react-hot-toast'
import { getIframesMatchPercentage } from './utils/getIframesMatchPercentage'
import { useLocalStorage } from '@uidotdev/usehooks'

type FrontendTrainingPageContextType = {
  actualIFrameRef: React.RefObject<HTMLIFrameElement>
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
  expectedReferenceIFrameRef: React.RefObject<HTMLIFrameElement>
  expectedImgRef: React.RefObject<HTMLImageElement>
  expectedCanvasContainerRef: React.RefObject<HTMLDivElement>
}

export const FrontendTrainingPageContext =
  createContext<FrontendTrainingPageContextType | null>(null)

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
  const expectedReferenceIFrameRef = useRef<HTMLIFrameElement>(null)
  const expectedImgRef = useRef<HTMLImageElement>(null)
  const expectedCanvasContainerRef = useRef<HTMLDivElement>(null)

  const {
    primarySize: LHSWidth,
    secondarySize: RHSWidth,
    handleMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    direction: 'horizontal',
    localStorageId: 'solve-exercise-page-lhs',
  })

  const [editorCode, setEditorCode] = useLocalStorage('frontend-editor-code', {
    htmlEditorContent: '',
    cssEditorContent: '',
  })
  const {
    editorViewRef: htmlEditorViewRef,
    handleEditorDidMount: handleHtmlEditorDidMount,
  } = useEditorHandler(editorCode.htmlEditorContent)
  const {
    editorViewRef: cssEditorViewRef,
    handleEditorDidMount: handleCssEditorDidMount,
  } = useEditorHandler(editorCode.cssEditorContent)

  useEffect(() => {
    const { html, css } = accentDetection
    updateIFrame(expectedIFrameRef, html, css)
    updateIFrame(expectedReferenceIFrameRef, html, css)
  }, [])

  return (
    <FrontendTrainingPageContext.Provider
      value={{
        actualIFrameRef,
        expectedIFrameRef,
        expectedImgRef,
        expectedCanvasContainerRef,
        expectedReferenceIFrameRef,
      }}
    >
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
                setEditorCode({
                  htmlEditorContent: html,
                  cssEditorContent: css,
                })
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
                const html =
                  htmlEditorViewRef.current?.state.doc.toString() || ''
                updateIFrame(actualIFrameRef, html, css)
                setEditorCode({
                  htmlEditorContent: html,
                  cssEditorContent: css,
                })
              }}
              handleRunCode={() => {}}
              ref={cssEditorViewRef}
            />
          </div>

          <div className="flex flex-col gap-12">
            <button
              onClick={async () => {
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
            <ActualOutput />
            <ExpectedOutput />
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
    </FrontendTrainingPageContext.Provider>
  )
}

const helloWorld = {
  html: `
  <div id="asdf">Hello world!</div>
  `,
  css: `
  #asdf {
    color: red;
    font-weight: bold;
    font-size: 24px;
  }
    `,
}

const accentDetection = {
  html: `
  <div>Építészeti kiállítás</div>
  `,
  css: `

  body{
  margin: 0;
  height: 350px;
  overflow: hidden;
  }
   div {
    color: #242325;
    background-color: #DC965A;
    font-family: "Trebuchet MS";
    font-weight: semi-bold;
    font-size: 24px;
    padding: 8px 4px;
    height: 100%;
    width: 100%;
    text-align: center;
  }
    `,
}
