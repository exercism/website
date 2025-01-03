import React from 'react'
import type { Change } from 'diff'

export function IOTestResultView({ diff }: { diff: Change[] }) {
  return (
    <>
      <tr>
        <th>Expected:</th>
        <td>
          {diff.map((part, index) =>
            !part.added ? (
              <span
                key={`expected-${index}`}
                className={part.removed ? 'added-part' : ''}
              >
                {part.value}
              </span>
            ) : null
          )}
        </td>
      </tr>
      <tr>
        <th>Actual:</th>
        <td>
          {diff.map((part, index) =>
            !part.removed ? (
              <span
                key={`actual-${index}`}
                className={part.added ? 'removed-part' : ''}
              >
                {part.value}
              </span>
            ) : null
          )}
        </td>
      </tr>
    </>
  )
}
