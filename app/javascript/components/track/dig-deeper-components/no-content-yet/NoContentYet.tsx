import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type NoContentYetProps = {
  exerciseTitle: string
  contentType: string
  children: React.ReactNode
}
export function NoContentYet({
  exerciseTitle,
  contentType,
  children,
}: NoContentYetProps): JSX.Element {
  const { t } = useAppTranslation(
    'components/track/dig-deeper-components/no-content-yet'
  )
  return (
    <div className="text-textColor6 flex flex-col items-left bg-backgroundColorB rounded-8">
      <div className="text-label-timestamp text-16 mb-4 font-semibold">
        {t('noContentYet.thereAreNoContentTypeForExerciseTitle', {
          contentType,
          exerciseTitle,
        })}
      </div>
      <div className="flex md:flex-row flex-col text-15 leading-150">
        {children}
      </div>
    </div>
  )
}
