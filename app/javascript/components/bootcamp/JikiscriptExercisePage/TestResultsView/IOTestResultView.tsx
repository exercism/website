// i18n-key-prefix: iOTestResultView
// i18n-namespace: components/bootcamp/JikiscriptExercisePage/TestResultsView
import React from 'react'
import type { Change } from 'diff'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function IOTestResultView({ diff }: { diff: Change[] }) {
  const { t } = useAppTranslation(
    'components/bootcamp/JikiscriptExercisePage/TestResultsView'
  )
  return (
    <>
      <tr>
        <th>{t('iOTestResultView.expected')}</th>
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
        <th>{t('iOTestResultView.actual')}</th>
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
