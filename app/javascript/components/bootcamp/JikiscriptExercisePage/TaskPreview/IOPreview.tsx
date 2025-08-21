// i18n-key-prefix: iOPreview
// i18n-namespace: components/bootcamp/JikiscriptExercisePage/TaskPreview
import React from 'react'
import { CodeRun } from '../TestResultsView/CodeRun'
import { generateCodeRunString } from '../utils/generateCodeRunString'
import { formatJikiObject } from '@/interpreter/helpers'
import { useAppTranslation } from '@/i18n/useAppTranslation'
export function IOPreview({
  inspectedPreviewTaskTest,
}: {
  inspectedPreviewTaskTest: TaskTest
}) {
  const { t } = useAppTranslation(
    'components/bootcamp/JikiscriptExercisePage/TaskPreview'
  )
  const expected = inspectedPreviewTaskTest.checks?.[0].value
  return (
    <div className="scenario-lhs">
      <div className="scenario-lhs-content">
        <h3>
          <strong>{t('iOPreview.scenario')}</strong>
          {inspectedPreviewTaskTest.name}
        </h3>
        <table className="io-test-result-info">
          <tbody>
            <CodeRun
              codeRun={generateCodeRunString(
                inspectedPreviewTaskTest.function,
                inspectedPreviewTaskTest.args || []
              )}
            />
            <tr>
              <th>{t('iOPreview.expected')}</th>
              <td>{formatJikiObject(expected)}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  )
}
