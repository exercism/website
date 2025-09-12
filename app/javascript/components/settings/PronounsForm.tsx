// i18n-key-prefix: pronounsForm
// i18n-namespace: components/settings/PronounsForm.tsx
import React, { useState, useCallback } from 'react'
import { Icon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

type Links = {
  update: string
  info: string
}

type RequestBody = {
  user: {
    pronoun_parts: readonly string[]
  }
}

const DEFAULT_ERROR = new Error('Unable to update pronouns')

export default function PronounsForm({
  handle,
  defaultPronounParts,
  links,
}: {
  handle: string
  defaultPronounParts: readonly string[]
  links: Links
}): JSX.Element {
  const { t } = useAppTranslation()
  const [pronounParts, setPronounParts] = useState<readonly string[]>(
    defaultPronounParts || ['', '', '']
  )

  const setPronounPart = useCallback(
    (part: string, index: number) => {
      const newPronounParts = [...pronounParts]
      newPronounParts[index] = part

      setPronounParts(newPronounParts)
    },
    [pronounParts]
  )

  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: { user: { pronoun_parts: pronounParts } },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      <h2>{t('pronounsForm.howWouldYouLikeToBeAddressedOptional')}</h2>
      <hr className="c-divider --small" />
      <div className="instructions">
        <Trans
          i18nKey="pronounsForm.instructions"
          components={[
            <strong />,
            <a href={links.info} target="_blank" rel="noreferrer" />,
          ]}
        />
      </div>
      <div className="testimonial">
        <div className="text">
          {t('pronounsForm.testimonialText', { handle })}
          <input
            type="text"
            value={pronounParts[0] || ''}
            pattern="^[^\s]{0,255}$"
            title="Pronoun cannot contain whitespace and must be no longer than 255 characters"
            placeholder="e.g. They"
            onChange={(e) => setPronounPart(e.target.value, 0)}
          />
          {t('pronounsForm.testimonialAnswered')}
          <input
            type="text"
            value={pronounParts[1] || ''}
            pattern="^[^\s]{0,255}$"
            title="Pronoun cannot contain whitespace and must be no longer than 255 characters"
            placeholder="e.g. them"
            onChange={(e) => setPronounPart(e.target.value, 1)}
          />
          {t('pronounsForm.testimonialToOthersBecause')}
          <input
            type="text"
            value={pronounParts[2] || ''}
            pattern="^[^\s]{0,255}$"
            title="Pronoun cannot contain whitespace and must be no longer than 255 characters"
            placeholder="e.g. their"
            onChange={(e) => setPronounPart(e.target.value, 2)}
          />
          {t('pronounsForm.testimonialAdviceHelpful')}
        </div>
        <div className="commonly-used">
          <div className="info">{t('pronounsForm.frequentlyUsed')}</div>
          <button
            type="button"
            onClick={() => setPronounParts(['She', 'her', 'her'])}
          >
            {t('pronounsForm.sheHerHer')}
          </button>
          <button
            type="button"
            onClick={() => setPronounParts(['He', 'him', 'his'])}
          >
            {t('pronounsForm.heHimHis')}
          </button>
          <button
            type="button"
            onClick={() => setPronounParts(['They', 'them', 'their'])}
          >
            {t('pronounsForm.theyThemTheir')}
          </button>
          <button
            type="button"
            onClick={() => setPronounParts([handle, handle, handle])}
          >
            {t('pronounsForm.useHandle')}
          </button>
          <button type="button" onClick={() => setPronounParts(['', '', ''])}>
            {t('pronounsForm.leaveBlank')}
          </button>
        </div>
      </div>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          {t('pronounsForm.savePronouns')}
        </FormButton>
        <FormMessage
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
          SuccessMessage={SuccessMessage}
        />
      </div>
    </form>
  )
}

const SuccessMessage = () => {
  const { t } = useAppTranslation()
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      {t('pronounsForm.yourPronounsHaveBeenUpdated')}
    </div>
  )
}
