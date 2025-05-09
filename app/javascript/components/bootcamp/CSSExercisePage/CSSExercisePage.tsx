import React, { useEffect } from 'react'
import { Toaster } from 'react-hot-toast'
import { Resizer } from '../JikiscriptExercisePage/hooks/useResize'
import { Header } from './Header/Header'
import { useInitResizablePanels } from './hooks/useInitResizablePanels'
import { useSetupEditors } from './hooks/useSetupEditors'
import { useSetupIFrames } from './hooks/useSetupIFrames'
import { LHS } from './LHS/LHS'
import { RHS } from './RHS/RHS'
import { CSSExercisePageContext } from './CSSExercisePageContext'
import { useCSSExercisePageStore } from './store/cssExercisePageStore'
import { getStylesFromCss } from './utils/getStylesFromCss'

export default function CSSExercisePage(data: CSSExercisePageProps) {
  const {
    actualIFrameRef,
    expectedIFrameRef,
    expectedReferenceIFrameRef,
    handleCompare,
  } = useSetupIFrames(data.exercise.config, data.code)

  const { setAssertionStatus } = useCSSExercisePageStore()

  useEffect(() => {
    if (data.solution.passedBasicTests) {
      setAssertionStatus('pass')
    }
  }, [data.solution])

  const { handleWidthChangeMouseDown } = useInitResizablePanels()

  const {
    htmlEditorViewRef,
    cssEditorViewRef,
    handleCssEditorDidMount,
    handleHtmlEditorDidMount,
    setEditorCodeLocalStorage,
    resetEditors,
    getEditorValues,
    defaultCode,
  } = useSetupEditors(data.exercise.slug, data.code, actualIFrameRef)

  useEffect(() => {
    const selector = '#flag #top #rhs div:nth-child(1)'
    getStylesFromCss(DUMMY_CSS, selector).then((styles) => {
      console.log(`getting styles for selector: ${selector}`, styles)
    })
  }, [])

  return (
    <CSSExercisePageContext.Provider
      value={{
        actualIFrameRef,
        expectedIFrameRef,
        expectedReferenceIFrameRef,
        htmlEditorRef: htmlEditorViewRef,
        cssEditorRef: cssEditorViewRef,
        handleCssEditorDidMount,
        handleHtmlEditorDidMount,
        setEditorCodeLocalStorage,
        resetEditors,
        handleCompare,
        exercise: data.exercise,
        code: data.code,
        links: data.links,
        solution: data.solution,
      }}
    >
      <div id="bootcamp-frontend-training-page">
        <Header />
        <div className="page-body">
          <LHS defaultCode={defaultCode} getEditorValues={getEditorValues} />
          <Resizer
            direction="vertical"
            handleMouseDown={handleWidthChangeMouseDown}
          />
          <RHS />
        </div>
      </div>
      <Toaster />
    </CSSExercisePageContext.Provider>
  )
}

const DUMMY_CSS = `#flag {
    background: white;
    display: flex;
    flex-direction: column;
}

#top,
#bottom {
    flex-basis: 0;
    min-height: 0;
}
#top {
    display: flex;
    flex-grow: 5;
    align-items: stretch;
}
#star {
    aspect-ratio: 1;
    background: #002868;
    display: flex;
    justify-content: center;
    align-items: center;
    svg {
        width: 60%;
    }
}
#rhs,
#bottom {
    flex-grow: 1;
    display: flex;
    flex-direction: column;
}
#bottom {
    flex-grow: 6;
}

#rhs, #bottom {
   div {
      flex-grow: 1;
  }
}
#rhs div:nth-child(odd),
#bottom div:nth-child(even) {
    background: #BF0A30;
}`
