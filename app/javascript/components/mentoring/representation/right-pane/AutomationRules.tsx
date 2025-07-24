import React from 'react'
import { CompleteRepresentationData } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export default function AutomationRules({
  guidance,
}: Pick<CompleteRepresentationData, 'guidance'>): JSX.Element | null {
  const { t } = useAppTranslation(
    'components/mentoring/representation/right-pane'
  )

  if (!guidance.representations) {
    return (
      <p className="px-24 mb-16 text-p-base">
        <Trans
          ns="components/mentoring/representation/right-pane"
          i18nKey="automationRules.noGuidance"
          components={[
            <a
              href={guidance.links.improveRepresenterGuidance}
              target="_blank"
              rel="noreferrer"
            />,
          ]}
        />
      </p>
    )
  }

  return (
    <div className="px-24 shadow-xsZ1v2 pt-12 pb-24">
      <h2 className="text-h4 mb-12">
        {t('automationRules.pleaseReadBeforeGivingFeedback')}
      </h2>
      <div
        dangerouslySetInnerHTML={{
          __html: `<div class="c-textual-content --base">${guidance.representations}</div>`,
        }}
      />
    </div>
  )
}
