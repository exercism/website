import React from 'react'
import { CompleteRepresentationData } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export default function Considerations({
  guidance,
}: Pick<CompleteRepresentationData, 'guidance'>): JSX.Element | null {
  const { t } = useAppTranslation(
    'components/mentoring/representation/right-pane'
  )

  return (
    <p className="flex items-center justify-center font-medium text-16 leading-[24px] py-8 px-16 border-2 border-orange rounded-8 bg-bgCAlert text-textCAlert whitespace-nowrap my-16 mx-24">
      <Trans
        i18nKey="considerations.readThisBeforeGivingFeedback"
        ns="components/mentoring/representation/right-pane"
        components={[
          <a
            href={guidance.links.representationFeedbackGuide}
            target="_blank"
            rel="noreferrer"
            className="!text-textCAlertLabel underline"
          />,
        ]}
      />
    </p>
  )
}
