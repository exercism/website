// i18n-namespace: components/editor/testComponents
import React from 'react'
import pluralize from 'pluralize'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TestRunSummaryByStatusHeaderMessage = ({
  version,
  numFailedTests,
}: {
  version: number
  numFailedTests: number
}): JSX.Element => {
  const { t } = useAppTranslation('components/editor/testComponents')

  return version === 2 || version === 3 ? (
    <span>
      {numFailedTests}{' '}
      {t(
        `testRunSummaryByStatusHeaderMessage.${pluralize(
          'testFailure',
          numFailedTests
        )}`
      )}
    </span>
  ) : (
    <span>{t('testRunSummaryByStatusHeaderMessage.testsFailed')}</span>
  )
}
