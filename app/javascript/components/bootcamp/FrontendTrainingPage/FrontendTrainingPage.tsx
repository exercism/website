import React, { useCallback, useRef, useState } from 'react'
import { Resizer } from '../SolveExercisePage/hooks/useResize'
import { CodeMirror } from '../SolveExercisePage/CodeMirror/CodeMirror'
import { Instructions } from './Instructions'
import { html } from '@codemirror/lang-html'
import { css } from '@codemirror/lang-css'
import interact from '@replit/codemirror-interact'
import { basicLight } from 'cm6-theme-basic-light'
import { Prec } from '@codemirror/state'
import { ActualOutput } from './ActualOutput'
import { ExpectedOutput } from './ExpectedOutput'
import { updateIFrame } from './utils/updateIFrame'
import { Toaster } from 'react-hot-toast'
import { Header } from './Header'
import { useInitResizablePanels } from './useInitResizablePanels'
import { useSetupEditors } from './useSetupEditors'
import { useSetupIFrames } from './useSetupIFrames'
import { FrontendTrainingPageContext } from './FrontendTrainingPageContext'
import { interpret } from '@/css-interpreter/interpreter'
import { Frame } from '@/css-interpreter/frames'
import { showError } from '../SolveExercisePage/utils/showError'
import useEditorStore from '../SolveExercisePage/store/editorStore'
import SolveExercisePageContextWrapper from '../SolveExercisePage/SolveExercisePageContextWrapper'
import {
  Animation,
  AnimationTimeline,
} from '../SolveExercisePage/AnimationTimeline/AnimationTimeline'
import { DEFAULT_BROWSER_STYLES } from './defaultStyles'

let colorInput: HTMLInputElement | null = null

export default function FrontendTrainingPage() {
  const actualOutputRef = useRef<HTMLDivElement>(null)
  const {
    actualIFrameRef,
    expectedIFrameRef,
    expectedReferenceIFrameRef,
    handleCompare,
  } = useSetupIFrames()

  const {
    BottomHeight,
    LHSWidth,
    RHSWidth,
    TopHeight,
    handleHeightChangeMouseDown,
    handleWidthChangeMouseDown,
  } = useInitResizablePanels()

  const {
    htmlEditorViewRef,
    cssEditorViewRef,
    handleCssEditorDidMount,
    handleHtmlEditorDidMount,
    setEditorCodeLocalStorage,
  } = useSetupEditors()

  const {
    setUnderlineRange,
    setHighlightedLine,
    setHighlightedLineColor,
    setInformationWidgetData,
    setShouldShowInformationWidget,
    setHasCodeBeenEdited,
  } = useEditorStore()

  const [frames, setFrames] = useState<Frame[] | undefined>(undefined)
  const [cssAnimationTimeline, setCssAnimationTimeline] = useState()

  const interpreterCssCode = useCallback(() => {
    if (actualIFrameRef.current) {
      // Reload iframe
      actualIFrameRef.current.contentWindow?.location.reload()

      updateIFrame(
        actualIFrameRef,
        htmlEditorViewRef?.current?.state.doc.toString() || ''
      )
    }

    const cssCode = cssEditorViewRef.current?.state.doc.toString() || ''
    const interpretation = interpret(cssCode)
    if (interpretation.error) {
      showError({
        error: interpretation.error,
        editorView: cssEditorViewRef.current,
        setHighlightedLine,
        setHighlightedLineColor,
        setInformationWidgetData,
        setShouldShowInformationWidget,
        setUnderlineRange,
      })
    }

    setHasCodeBeenEdited(false)
    const { frames } = interpretation
    if (frames && frames.length > 0) {
      setFrames(frames)
      const animationTimeline = buildCssAnimationTimeline(
        actualIFrameRef.current,
        frames
      )
      console.log(animationTimeline)
      // @ts-ignore
      setCssAnimationTimeline(animationTimeline)
    }

    console.log(interpretation)
  }, [])

  return (
    <SolveExercisePageContextWrapper
      // @ts-ignore
      value={{
        editorView: cssEditorViewRef.current,
        isSpotlightActive: false,
        links: {} as SolveExercisePageProps['links'],
      }}
    >
      <FrontendTrainingPageContext.Provider
        value={{
          actualIFrameRef,
          expectedIFrameRef,
          expectedReferenceIFrameRef,
        }}
      >
        <div id="bootcamp-front-end-training-page">
          <Header onCompare={handleCompare} />
          <div className="page-body">
            <div className="page-body-lhs" style={{ width: LHSWidth }}>
              <CodeMirror
                style={{ height: `${TopHeight}px` }}
                editorDidMount={handleHtmlEditorDidMount}
                extensions={[Prec.highest([html(), basicLight])]}
                onEditorChangeCallback={(view) => {
                  const html = view.state.doc.toString()
                  const css =
                    cssEditorViewRef.current?.state.doc.toString() || ''
                  setEditorCodeLocalStorage({
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
                style={{ height: `${BottomHeight - 100}px` }}
                editorDidMount={handleCssEditorDidMount}
                onEditorChangeCallback={(view) => {
                  const css = view.state.doc.toString()
                  const html =
                    htmlEditorViewRef.current?.state.doc.toString() || ''
                  setEditorCodeLocalStorage({
                    htmlEditorContent: html,
                    cssEditorContent: css,
                  })
                  updateIFrame(actualIFrameRef, html, css)
                }}
                extensions={[
                  Prec.highest([css(), basicLight]),
                  interact({
                    rules: [
                      // {
                      //   regexp: /-?\b\d+\.?\d*\b/g,
                      //   // set cursor to "ew-resize" on hover
                      //   cursor: "ew-resize",
                      //   // change number value based on mouse X movement on drag
                      //   onDrag: (text, setText, e) => {
                      //     const newVal = Number(text) + e.movementX;
                      //     if (isNaN(newVal)) return;
                      //     setText(newVal.toString());
                      //   },
                      // },
                      {
                        regexp: /(-?\d+\.?\d*)(px|%)/g,
                        cursor: 'ew-resize',
                        onDrag: (text, setText, e) => {
                          // Match numbers even if they are followed by 'px' or '%', etc
                          const match = text.match(/(-?\d+\.?\d*)(px|%|vw|vh)/)
                          if (!match) return

                          const [, num, unit] = match
                          const newVal = Number(num) + e.movementX

                          if (isNaN(newVal)) return

                          setText(`${newVal}${unit}`)
                        },
                      },
                      {
                        regexp: /rgb\(.*\)/g,
                        cursor: 'pointer',
                        onDrag: (text, setText, e) => {
                          const res =
                            /rgb\((?<r>\d+)\s*,\s*(?<g>\d+)\s*,\s*(?<b>\d+)\)/.exec(
                              text
                            )
                          const r = Number(res?.groups?.r)
                          const g = Number(res?.groups?.g)
                          const b = Number(res?.groups?.b)
                          const sel = document.createElement('input')
                          sel.style.position = 'absolute'
                          sel.type = 'color'
                          if (!isNaN(r + g + b)) sel.value = rgb2hex(r, g, b)
                          sel.addEventListener('input', (e) => {
                            const el = e.target as HTMLInputElement
                            if (el.value) {
                              const [r, g, b] = hex2rgb(el.value)
                              setText(`rgb(${r}, ${g}, ${b})`)
                            }
                          })
                          sel.click()
                        },
                      },
                    ],
                  }),
                ]}
                handleRunCode={() => {}}
                ref={cssEditorViewRef}
              />

              {/* <div className="page-body-lhs-bottom">
                <button
                  onClick={interpreterCssCode}
                  className="btn-primary btn-s grow shrink-0 w-fit"
                >
                  Interpret CSS
                </button>
                {cssAnimationTimeline && frames && (
                  <Scrubber
                    animationTimeline={cssAnimationTimeline}
                    // @ts-ignore
                    frames={frames}
                  />
                )}
              </div> */}
            </div>

            <div className="flex flex-col gap-12">
              <div ref={actualOutputRef} />
              <ActualOutput />
              <ExpectedOutput />
            </div>
            <Resizer
              direction="vertical"
              handleMouseDown={handleWidthChangeMouseDown}
            />
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
    </SolveExercisePageContextWrapper>
  )
}

export function buildCssAnimationTimeline(
  domElement: HTMLIFrameElement | null,
  frames: Frame[]
) {
  let animations: Animation[] = []
  let placeholder = false

  if (!domElement) return

  const document = domElement.contentDocument
  if (!document) return

  frames.forEach((frame) => {
    if (frame.animations) {
      frame.animations.forEach((animation) => {
        const target = document.querySelector(animation.selector)
        if (!target) return

        const defaultStyle =
          DEFAULT_BROWSER_STYLES[target.tagName.toLowerCase()][
            animation.property
          ]

        // // if there is a default style, prepend it to the animation, so the student can undo their css
        if (defaultStyle && typeof defaultStyle === 'string') {
          const newAnim: Animation = {
            targets: target,
            [animation.property]: defaultStyle,
            duration: 0,
            offset: frame.time - 1,
          }
          animations.push(newAnim)
        }

        const newAnim: Animation = {
          targets: target,
          [animation.property]: animation.value,
          duration: 0,
          offset: frame.time,
        }
        animations.push(newAnim)
      })
    }
  })

  // @ts-ignore
  return new AnimationTimeline({}, frames).populateTimeline(
    animations,
    placeholder
  )
}

const hex2rgb = (hex: string): [number, number, number] => {
  const v = parseInt(hex.substring(1), 16)
  return [(v >> 16) & 255, (v >> 8) & 255, v & 255]
}

const rgb2hex = (r: number, g: number, b: number): string =>
  '#' + r.toString(16) + g.toString(16) + b.toString(16)
