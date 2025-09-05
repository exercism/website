// i18n-key-prefix: rightPane.automationRules
// i18n-namespace: components/training-data/code-tagger
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export default function AutomationRules(): JSX.Element | null {
  const { t } = useAppTranslation()

  return (
    <>
      <p className="text-p-base mb-12">
        {t('rightPane.automationRules.theseTagsUsedToTrain')}
      </p>
      <p className="text-p-base mb-4">
        {t('rightPane.automationRules.heresSomeNotes')}
      </p>
      <ul className="text-p-base list-disc ml-20">
        <li className="mb-2">
          <Trans
            i18nKey="rightPane.automationRules.ifUnclearAskOnForum"
            ns="components/training-data/code-tagger"
            components={[<a href="https://forum.exercism.org" />]}
          />
        </li>
        <li>
          <Trans
            i18nKey="rightPane.automationRules.stickToOfficialList"
            ns="components/training-data/code-tagger"
            components={[<a href="https://forum.exercism.org" />]}
          />
        </li>
      </ul>
    </>
  )
}
