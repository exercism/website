// i18n-key-prefix: testList
// i18n-namespace: components/editor/testComponents
import React from 'react'
import { Test } from '../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function TestsList({ tests }: { tests: Test[] }) {
  const { t } = useAppTranslation('components/editor/testComponents')

  return (
    <div>
      {tests.map((test: Test) => (
        <p key={test.name}>
          {t('testsList.name')}: {test.name}, status: {test.status}, output:{' '}
          {test.output}
        </p>
      ))}
    </div>
  )
}
