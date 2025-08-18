// i18n-key-prefix: codeRun
// i18n-namespace: components/bootcamp/JikiscriptExercisePage/TestResultsView
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CodeRun({ codeRun }: { codeRun: string }) {
  const { t } = useAppTranslation(
    'components/bootcamp/JikiscriptExercisePage/TestResultsView'
  )
  if (!codeRun || codeRun.length === 0) return null
  return (
    <tr>
      <th>{t('codeRun.codeRun')}</th>
      <td>{codeRun}</td>
    </tr>
  )
}
