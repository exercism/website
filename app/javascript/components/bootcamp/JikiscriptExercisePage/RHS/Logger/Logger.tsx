import React, { useRef, useEffect } from 'react'
import useTestStore from '../../store/testStore'
import { useHighlighting } from '@/hooks/use-syntax-highlighting'
import { useLogger } from '@/components/bootcamp/common/hooks/useLogger'

export function Logger({ height }: { height: number | string }) {
  const { inspectedTestResult } = useTestStore()

  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const el = containerRef.current
    if (el) {
      el.scrollTop = el.scrollHeight
    }
  }, [inspectedTestResult?.logMessages])

  // rerun on inspected testresult change
  const ref = useHighlighting<HTMLDivElement>(inspectedTestResult?.name)

  return (
    <div style={{ height }} className="c-logger" ref={ref}>
      <h2>Log Messages</h2>
      {!inspectedTestResult ||
      inspectedTestResult?.logMessages?.length === 0 ? (
        <div className="info-message">
          <p>
            Use the <code>log</code> function to log messages to the console.
            e.g.
          </p>
          <pre className="hljs language-javascript">
            <code>log("Hello World")</code>
          </pre>
        </div>
      ) : (
        <>
          <div className="info-message">
            <p>
              These are the log messages for scenario{' '}
              {inspectedTestResult.testIndex + 1}:
            </p>
          </div>
          <div className="log-container">
            {inspectedTestResult?.logMessages?.map((log, index) => (
              <pre key={index} className="log ">
                {renderLog(log)}
              </pre>
            ))}
          </div>
        </>
      )}
    </div>
  )
}

function renderLog(logArgs: unknown[]) {
  let line = logArgs
    .map((arg) => {
      const type = typeof arg

      if (arg === null) return 'null'
      if (arg === undefined) return 'undefined'

      if (type === 'string') return `"${arg}"`
      if (type === 'number' || type === 'boolean') return String(arg)
      if (type === 'bigint') return `${arg.toString()}n`
      if (type === 'symbol') return arg.toString()
      if (type === 'function') {
        const name = (arg as Function).name
        return `[Function${name ? `: ${name}` : ''}]`
      }

      if (arg instanceof Date) {
        return arg.toISOString()
      }

      if (arg instanceof Error) {
        return `Error: ${(arg as Error).message}`
      }

      if (arg instanceof RegExp) {
        return arg.toString()
      }

      if (arg instanceof Promise) {
        return `[Promise]`
      }

      if (typeof HTMLElement !== 'undefined' && arg instanceof HTMLElement) {
        return `<${arg.tagName.toLowerCase()}>`
      }

      try {
        return verboseStringify(arg)
      } catch {
        return '[Unrenderable object]'
      }
    })
    .join(' ')

  return <code className="language-javascript hljs">{line}</code>
}

function verboseStringify(obj) {
  return JSON.stringify(
    obj,
    (key, value) => {
      return value === undefined ? '__undefined__' : value
    },
    2
  ).replace(/"__undefined__"/g, 'undefined')
}
