import React, { useRef, useEffect } from 'react'
import useTestStore from '../../store/testStore'
import { useHighlighting } from '@/hooks/use-syntax-highlighting'
import { renderLog } from './renderLog'

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
