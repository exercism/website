import React from 'react'
import type { Change } from 'diff'

export function IOTestResultView({ diff }: { diff: Change[] }) {
  return (
    <div className="border border-slate-600 rounded-md p-4 mb-4">
      <h5>Expected:</h5>
      <p>
        {diff.map((part, index) =>
          !part.added ? (
            <span
              key={`expected-${index}`}
              style={{
                // green
                background: part.removed ? '#4ade80' : 'transparent',
              }}
            >
              {part.value}
            </span>
          ) : null
        )}
      </p>
      <h5>Actual:</h5>
      <p>
        {diff.map((part, index) =>
          !part.removed ? (
            <span
              key={`actual-${index}`}
              style={{
                // red
                background: part.added ? '#f87171' : 'transparent',
              }}
            >
              {part.value}
            </span>
          ) : null
        )}
      </p>
    </div>
  )
}
