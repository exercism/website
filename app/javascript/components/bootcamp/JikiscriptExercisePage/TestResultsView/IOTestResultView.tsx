import React from 'react'
import type { Change } from 'diff'

export function IOTestResultView({ diff }: { diff: Change[] }) {
  return (
    <>
      <tr>
        <th>Expected:</th>
        <td style={{ whiteSpace: 'pre-wrap' }}>
          {diff.map((part, index) =>
            !part.added ? (
              <span
                key={`expected-${index}`}
                className={part.removed ? 'added-part' : ''}
              >
                {part.added || part.removed
                  ? part.value
                  : part.value.split('\\n').map((line, i, arr) => (
                      <React.Fragment key={i}>
                        {line}
                        {i < arr.length - 1 && <br />}
                      </React.Fragment>
                    ))}
              </span>
            ) : null
          )}
        </td>
      </tr>
      <tr>
        <th>Actual:</th>
        <td style={{ whiteSpace: 'pre-wrap' }}>
          {diff.map((part, index) =>
            !part.removed ? (
              <span
                key={`actual-${index}`}
                className={part.added ? 'removed-part' : ''}
              >
                {part.added || part.removed
                  ? part.value
                  : part.value.split('\\n').map((line, i, arr) => (
                      <React.Fragment key={i}>
                        {line}
                        {i < arr.length - 1 && <br />}
                      </React.Fragment>
                    ))}
              </span>
            ) : null
          )}
        </td>
      </tr>
    </>
  )
}
