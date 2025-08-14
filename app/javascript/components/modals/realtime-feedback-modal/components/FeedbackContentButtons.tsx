// i18n-key-prefix: feedbackContentButtons
// i18n-namespace: components/modals/realtime-feedback-modal/components
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { assembleClassNames } from '@/utils/assemble-classnames'
import React from 'react'

type ReactButton = React.ButtonHTMLAttributes<HTMLButtonElement>

export function GoBackToExercise({ ...props }: ReactButton): JSX.Element {
  const { t } = useAppTranslation(
    'components/modals/realtime-feedback-modal/components'
  )
  return (
    <button {...props} className="btn-s btn-primary">
      {t('feedbackContentButtons.goBackToEditor')}
    </button>
  )
}

export function ContinueButton({
  text = 'Continue',
  className,
  ...props
}: {
  text?: string
  className?: string
} & ReactButton): JSX.Element {
  return (
    <button
      {...props}
      className={assembleClassNames('btn-primary btn-s', className)}
    >
      {text}
    </button>
  )
}
