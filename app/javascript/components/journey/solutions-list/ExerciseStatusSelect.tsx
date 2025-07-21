import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type ExerciseStatus =
  | undefined
  | 'started'
  | 'iterated'
  | 'completed'
  | 'published'

const OptionComponent = ({
  option: status,
}: {
  option: ExerciseStatus
}): JSX.Element => {
  const { t } = useAppTranslation('components/journey/solutions-list')
  switch (status) {
    case 'started':
      return <>{t('exerciseStatusSelect.started')}</>
    case 'iterated':
      return <>{t('exerciseStatusSelect.iterated')}</>
    case 'completed':
      return <>{t('exerciseStatusSelect.completed')}</>
    case 'published':
      return <>{t('exerciseStatusSelect.published')}</>
    case undefined:
      return <>{t('exerciseStatusSelect.all')}</>
  }
}

const SelectedComponent = ({ option }: { option: ExerciseStatus }) => {
  const { t } = useAppTranslation('components/journey/solutions-list')

  switch (option) {
    case undefined:
      return <>{t('exerciseStatusSelect.exerciseStatus')}</>
    default:
      return <OptionComponent option={option} />
  }
}

export const ExerciseStatusSelect = ({
  value,
  setValue,
}: {
  value: ExerciseStatus
  setValue: (value: ExerciseStatus) => void
}): JSX.Element => {
  return (
    <SingleSelect<ExerciseStatus>
      options={[undefined, 'started', 'iterated', 'completed', 'published']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
