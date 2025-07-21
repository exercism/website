import React, { SetStateAction } from 'react'
import { RepresentationFeedbackType } from '../../../types'
import RadioGroup from './RadioGroup'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type HowImportantProps = {
  feedbackType: RepresentationFeedbackType
  setFeedbackType: React.Dispatch<SetStateAction<RepresentationFeedbackType>>
}

export default function HowImportant({
  feedbackType,
  setFeedbackType,
}: HowImportantProps): JSX.Element {
  const { t } = useAppTranslation(
    'components/mentoring/representation/right-pane'
  )
  return (
    <div className="mb-4">
      <h2 className="text-h6 mb-8">{t('howImportant.howImportantIsThis')}</h2>
      <RadioGroup
        feedbackType={feedbackType}
        setFeedbackType={setFeedbackType}
      />
    </div>
  )
}
