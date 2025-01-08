import React from 'react'
import { diffWords, type Change } from 'diff'
import { useRef, useEffect, useMemo } from 'react'
import useEditorStore from '../store/editorStore'
import useTestStore from '../store/testStore'

export type ProcessedExpect = {
  diff: Change[]
  testsType: TestsType
  actual: any
  pass: boolean
  label?: string
  errorHtml?: string
  note?: string
  expected?: any
}

export type ProcessedExpects = ProcessedExpect[]

export function useInspectedTestResultView() {
  const { inspectedTestResult: result } = useTestStore()
  const viewContainerRef = useRef<HTMLDivElement | null>(null)

  useEffect(() => {
    if (!result) return

    if (!viewContainerRef.current) return

    if (result.view) {
      if (viewContainerRef.current.children.length > 0) {
        const oldView = viewContainerRef.current.children[0] as HTMLElement
        document.body.appendChild(oldView)
        oldView.style.display = 'none'
      }

      // on each result change, clear out view-container
      viewContainerRef.current.innerHTML = ''
      viewContainerRef.current.appendChild(result.view)
      result.view.style.display = 'block'
    } else {
      let img
      if (viewContainerRef.current.children.length > 0) {
        img = viewContainerRef.current.children[0] as HTMLElement
      } else {
        img = document.createElement('div')
        img.style.width = '100%'
        img.style.height = '100%'
        img.style.backgroundSize = '90%'
        img.style.backgroundRepeat = 'no-repeat'
        img.style.backgroundColor = 'white'
        img.style.backgroundPosition = 'center'
        viewContainerRef.current.appendChild(img)
      }
      img.style.backgroundImage = `url('/exercise-images/${result.imageSlug}')`
    }
  }, [result])

  const processedExpects = useMemo(
    () => processExpects(result),
    [result?.expects]
  )
  const firstFailingExpect = useMemo(
    () => getfirstFailingExpect(result),
    [result?.expects]
  )

  return { processedExpects, firstFailingExpect, viewContainerRef, result }
}

function getfirstFailingExpect(
  result: NewTestResult | null
): ProcessedExpect | null {
  if (!result) return null
  for (const expect of result.expects) {
    if (expect.pass === false) {
      if (expect.testsType === 'state') {
        return {
          errorHtml: expect.errorHtml,
          testsType: expect.testsType,
          actual: expect.actual,
          pass: expect.pass,
          diff: [],
        }
      }
      // io expect
      const { expected, actual } = expect
      return {
        ...expect,
        diff: getDiffOfExpectedAndActual(expected, actual),
      }
    }
  }
  return null
}

function processExpects(result: NewTestResult | null): ProcessedExpects {
  if (!result) return []
  return result.expects.map((expect) => {
    if (expect.testsType === 'state') {
      // state expect
      return {
        errorHtml: expect.errorHtml,
        testsType: 'state',
        actual: expect.actual,
        pass: expect.pass,
        diff: [],
      }
    }

    // io expect
    const { expected, actual } = expect
    return {
      ...expect,
      diff: getDiffOfExpectedAndActual(expected, actual),
    }
  })
}

export function getDiffOfExpectedAndActual(
  expected: any,
  actual: any
): Change[] {
  expected = expected ?? '[null]'
  actual = actual ?? "[Your function didn't return anything]"
  return diffWords(expected.toString(), actual.toString())
}
