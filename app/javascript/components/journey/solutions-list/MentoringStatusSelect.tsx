import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type MentoringStatus =
  | undefined
  | 'none'
  | 'requested'
  | 'in_progress'
  | 'finished'

const OptionComponent = ({
  option: status,
}: {
  option: MentoringStatus
}): JSX.Element => {
  const { t } = useAppTranslation('components/journey/solutions-list')

  switch (status) {
    case 'none':
      return <>{t('mentoringStatusSelect.noMentoring')}</>
    case 'requested':
      return <>{t('mentoringStatusSelect.mentoringRequested')}</>
    case 'in_progress':
      return <>{t('mentoringStatusSelect.mentoringInProgress')}</>
    case 'finished':
      return <>{t('mentoringStatusSelect.mentoringCompleted')}</>
    case undefined:
      return <>{t('mentoringStatusSelect.any')}</>
  }
}

const SelectedComponent = ({ option }: { option: MentoringStatus }) => {
  const { t } = useAppTranslation('components/journey/solutions-list')
  switch (option) {
    case undefined:
      return <>{t('mentoringStatusSelect.mentoringStatus')}</>
    default:
      return <OptionComponent option={option} />
  }
}

export const MentoringStatusSelect = ({
  value,
  setValue,
}: {
  value: MentoringStatus
  setValue: (value: MentoringStatus) => void
}): JSX.Element => {
  return (
    <SingleSelect<MentoringStatus>
      options={[undefined, 'none', 'requested', 'in_progress', 'finished']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
