import React from 'react'
import { diffWords, type Change } from 'diff'
import { useRef, useEffect, useMemo } from 'react'
import useEditorStore from '../store/editorStore'
import useTestStore from '../store/testStore'
import { formatLiteral } from '@/interpreter/helpers'

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
        img.classList.add('io-image')

        viewContainerRef.current.appendChild(img)
      }
      img.style.backgroundImage = `url('https://assets.exercism.org/bootcamp/scenarios/${result.imageSlug}')`

      const viewDisplay = result.imageSlug === undefined ? 'none' : 'block'
      viewContainerRef.current.style.display = viewDisplay
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

  return {
    processedExpects,
    firstFailingExpect,
    viewContainerRef,
    result,
    firstExpect: firstFailingExpect || processedExpects[0],
  }
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
  if (expected === actual) {
    return diffWords(formatLiteral(expected), formatLiteral(actual))
  }

  if (actual == null) {
    return [
      {
        added: false,
        count: 1,
        removed: true,
        value: formatLiteral(expected),
      },
      {
        added: true,
        count: 1,
        removed: false,
        value: "[Your function didn't return anything]",
      },
    ]
  }

  if (typeof expected == 'string' && typeof actual == 'string') {
    return diffWords(formatLiteral(expected), formatLiteral(actual))
  }
  return [
    {
      added: false,
      count: 1,
      removed: true,
      value: formatLiteral(expected),
    },
    {
      added: true,
      count: 1,
      removed: false,
      value: formatLiteral(actual),
    },
  ]
}
