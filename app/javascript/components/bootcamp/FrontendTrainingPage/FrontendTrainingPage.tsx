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
                        // match HEX and rgb
                        regexp:
                          /#([0-9a-fA-F]{3,6})\b|rgb\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*\)/g,
                        cursor: 'pointer',
                        onDrag: (text, setText, e) => {
                          // setText("#000000")
                          const toHex = (rgb: string): string => {
                            const match = rgb.match(/\d+/g)
                            if (!match) return '#000000'
                            return `#${match
                              .map((num) =>
                                Number(num).toString(16).padStart(2, '0')
                              )
                              .join('')}`
                          }

                          const currentColor = text.startsWith('rgb')
                            ? toHex(text)
                            : text

                          document
                            .querySelectorAll('.color-picker')
                            .forEach((el) => el.remove())

                          const colorInput = document.createElement('input')
                          colorInput.type = 'color'
                          colorInput.className = 'color-picker'
                          colorInput.value = currentColor
                          colorInput.style.position = 'absolute'
                          colorInput.style.zIndex = '1000'
                          colorInput.style.left = `${e.clientX}px`
                          colorInput.style.top = `${e.clientY}px`
                          colorInput.style.border = 'none'
                          colorInput.style.padding = '0'
                          colorInput.style.width = '40px'
                          colorInput.style.height = '40px'
                          colorInput.style.background = 'transparent'
                          colorInput.style.cursor = 'pointer'

                          document.body.appendChild(colorInput)

                          colorInput.focus()

                          colorInput.addEventListener('input', (e) => {
                            console.log(
                              'inputting',
                              colorInput.value,
                              'text',
                              text,
                              e
                            )
                            setTimeout(() => {
                              setText(colorInput.value)
                            }, 0)
                          })

                          const closePicker = (event: MouseEvent) => {
                            if (!colorInput.contains(event.target as Node)) {
                              colorInput.remove()
                              document.removeEventListener('click', closePicker)
                            }
                          }

                          document.addEventListener('click', closePicker, {
                            capture: true,
                          })

                          colorInput.addEventListener('click', (event) => {
                            event.stopPropagation()
                          })
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
