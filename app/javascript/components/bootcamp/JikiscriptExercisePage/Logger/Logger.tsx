import React, { useRef, useEffect } from 'react'
import useTestStore from '../store/testStore'

export function Logger() {
  const { inspectedTestResult } = useTestStore()

  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    console.log('logMessages', inspectedTestResult?.logMessages)
  }, [inspectedTestResult?.logMessages])

  useEffect(() => {
    const el = containerRef.current
    if (el) {
      el.scrollTop = el.scrollHeight
    }
  }, [inspectedTestResult?.logMessages])

  return (
    <div className="logger">
      <div className="log-container" ref={containerRef}>
        {inspectedTestResult?.logMessages?.map((log, index) => (
          <div key={index} className="log">
            {renderLog(log)}
          </div>
        ))}
      </div>
    </div>
  )
}

function renderLog(logArgs: unknown[]) {
  return (
    <pre>
      {logArgs.map((arg, index) => {
        const type = typeof arg

        if (arg === null) return <code key={index}>null </code>
        if (arg === undefined) return <code key={index}>undefined </code>

        if (type === 'string')
          return <code key={index}>"{arg as string}" </code>
        if (type === 'number' || type === 'boolean')
          return <code key={index}>{String(arg)} </code>
        if (type === 'bigint')
          return <code key={index}>{arg.toString()}n </code>
        if (type === 'symbol') return <code key={index}>{arg.toString()} </code>
        if (type === 'function') {
          const name = (arg as Function).name
          return <code key={index}>[Function{name ? `: ${name}` : ''}] </code>
        }

        if (arg instanceof Date) {
          return <code key={index}>{arg.toISOString()} </code>
        }

        if (arg instanceof Error) {
          return <code key={index}>Error: {(arg as Error).message} </code>
        }

        if (arg instanceof RegExp) {
          return <code key={index}>{arg.toString()} </code>
        }

        if (arg instanceof Promise) {
          return <code key={index}>[Promise] </code>
        }

        if (typeof HTMLElement !== 'undefined' && arg instanceof HTMLElement) {
          return <code key={index}>&lt;{arg.tagName.toLowerCase()}&gt; </code>
        }

        try {
          // fallback for objects like Math, globalThis, etc.
          return (
            <pre key={index} style={{ display: 'inline' }}>
              {JSON.stringify(arg)}{' '}
            </pre>
          )
        } catch (error) {
          return <code key={index}>[Unrenderable object] </code>
        }
      })}
    </pre>
  )
}
