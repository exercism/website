import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function NumberOfStudentsLabel(): JSX.Element {
  const { t } = useAppTranslation('components/impact/chart-elements')

  return (
    <div className="absolute text-18 text-gray font-semibold -rotate-90 left-[-40px] md:bottom-[45%] bottom-[25%]">
      {t('numberOfStudentsLabel.noOfStudents')}
    </div>
  )
}
