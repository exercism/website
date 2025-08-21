import React from 'react'
import { diffChars, diffWords, type Change } from 'diff'
import { useRef, useEffect, useMemo } from 'react'
import useTestStore from '../store/testStore'
import { formatJikiObject } from '@/interpreter/helpers'

export type ProcessedExpect = {
  diff: Change[]
  type: TestsType
  actual: any
  pass: boolean
  codeRun?: string
  errorHtml?: string
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
      if (result.type === 'state') {
        return {
          errorHtml: expect.errorHtml,
          type: result.type,
          actual: expect.actual,
          pass: expect.pass,
          diff: [],
        }
      }
      // io expect
      const { expected, actual } = expect
      return {
        ...expect,
        type: result.type,
        diff: getDiffOfExpectedAndActual(false, expected, actual),
      }
    }
  }
  return null
}

function processExpects(result: NewTestResult | null): ProcessedExpects {
  if (!result) return []
  return result.expects.map((expect) => {
    if (result.type === 'state') {
      // state expect
      return {
        errorHtml: expect.errorHtml,
        type: 'state',
        actual: expect.actual,
        pass: expect.pass,
        diff: [],
      }
    }

    // io expect
    const { expected, actual } = expect
    return {
      ...expect,
      type: result.type,
      diff: getDiffOfExpectedAndActual(expect.pass, expected, actual),
    }
  })
}

export function getDiffOfExpectedAndActual(
  passed: boolean,
  expected: any,
  actual: any
): Change[] {
  if (passed) {
    return diffChars(formatJikiObject(expected), formatJikiObject(actual))
  }

  if (actual === null || actual === undefined) {
    return [
      {
        added: false,
        count: 1,
        removed: true,
        value: formatJikiObject(expected),
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
    return diffChars(formatJikiObject(expected), formatJikiObject(actual))
  }
  if (typeof expected == 'boolean' && typeof actual == 'boolean') {
    return diffWords(formatJikiObject(expected), formatJikiObject(actual))
  }

  return [
    {
      added: false,
      count: 1,
      removed: true,
      value: formatJikiObject(expected),
    },
    {
      added: true,
      count: 1,
      removed: false,
      value: formatJikiObject(actual),
    },
  ]
}
