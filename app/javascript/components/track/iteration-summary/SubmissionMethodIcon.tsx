// i18n-key-prefix: submissionMethodIcon
// i18n-namespace: components/track/iteration-summary
import React from 'react'
import { SubmissionMethod } from '../../types'
import { Icon } from '../../common/Icon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function SubmissionMethodIcon({
  submissionMethod,
}: {
  submissionMethod: SubmissionMethod
}) {
  const { t } = useAppTranslation('components/track/iteration-summary')
  switch (submissionMethod) {
    case SubmissionMethod.CLI:
      return (
        <Icon
          icon="cli"
          alt={t('submissionMethodIcon.submittedViaCLI')}
          className="--icon --upload-method-icon"
        />
      )
    case SubmissionMethod.API:
      return (
        <Icon
          icon="editor"
          alt={t('submissionMethodIcon.submittedViaEditor')}
          className="--icon --upload-method-icon"
        />
      )
    default:
      return null
  }
}
