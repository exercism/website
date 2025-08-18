import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

type ManageExistingSolutionProps = {
  numPublished: number
  numCommentsEnabled: number
  commentStatusPhrase: string
  enableAllMutation: () => void
  disableAllMutation: () => void
}

export function ManageExistingSolution({
  numPublished,
  commentStatusPhrase,
  disableAllMutation,
  enableAllMutation,
  numCommentsEnabled,
}: ManageExistingSolutionProps): JSX.Element | null {
  const { t } = useAppTranslation(
    'components/settings/comments-preference-form'
  )
  if (numPublished === 0) return null
  return (
    <div className="form-footer">
      <div className="flex flex-col items-start">
        <h3 className="text-h5 mb-4">
          {t('manageExistingSolutions.manageExistingSolutions')}
        </h3>
        <p className="text-p-base mb-12">
          <Trans
            ns="components/settings/comments-preference-form"
            i18nKey="manageExistingSolutions.canCommentOnPublishedSolutions"
            values={{ commentStatusPhrase }}
            components={[<span className="font-medium" />]}
          />
        </p>
        <div className="flex gap-12">
          <button
            onClick={() => enableAllMutation()}
            disabled={numCommentsEnabled === numPublished}
            className="btn-m btn-enhanced"
          >
            {t('manageExistingSolutions.allowCommentsOnExistingSolutions')}
          </button>

          <button
            onClick={() => disableAllMutation()}
            disabled={numCommentsEnabled === 0}
            className="btn-m btn-enhanced"
          >
            {t('manageExistingSolutions.disableCommentsOnExistingSolutions')}
          </button>
        </div>
      </div>
    </div>
  )
}
