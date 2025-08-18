import React, { ChangeEvent } from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TestimonialField = ({
  id,
  min,
  max,
  value,
  onChange,
}: {
  id: string
  min: number
  max: number
  value: string
  onChange: (e: ChangeEvent) => void
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/modals/student/finish-mentor-discussion-modal'
  )
  return (
    <>
      <textarea
        value={value}
        onChange={onChange}
        id={id}
        placeholder={t('testimonialField.writeTestimonial')}
        minLength={min}
        maxLength={max}
      />
      <div className="counter">
        <div>
          {value.length} / {max}
        </div>
        <div>
          {min} {t('testimonialField.minimum')}
        </div>
      </div>
    </>
  )
}
