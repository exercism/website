import React, { forwardRef } from 'react'
import { GenericTooltip } from '../misc/ExercismTippy'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Props = React.ButtonHTMLAttributes<HTMLButtonElement>

export const SubmitButton = forwardRef<HTMLButtonElement, Props>(
  ({ disabled, ...props }, ref) => {
    const { t } = useAppTranslation('components/editor/SubmitButton.tsx')
    return (
      <GenericTooltip
        disabled={!disabled}
        content={t('submitButton.testsPassingRequired')}
      >
        <div className="submit-btn">
          <button
            type="button"
            disabled={disabled}
            className="btn-primary btn-s"
            ref={ref}
            {...props}
          >
            <span>{t('submitButton.submit')}</span>
          </button>
        </div>
      </GenericTooltip>
    )
  }
)
