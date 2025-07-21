import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type SyncStatus = undefined | 'up_to_date' | 'out_of_date'

const OptionComponent = ({
  option: status,
}: {
  option: SyncStatus
}): JSX.Element => {
  const { t } = useAppTranslation('components/journey/solutions-list')
  switch (status) {
    case 'up_to_date':
      return <>{t('syncStatusSelect.upToDate')}</>
    case 'out_of_date':
      return <>{t('syncStatusSelect.outOfDate')}</>
    case undefined:
      return <>{t('syncStatusSelect.all')}</>
  }
}

const SelectedComponent = ({ option }: { option: SyncStatus }) => {
  const { t } = useAppTranslation('components/journey/solutions-list')
  switch (option) {
    case undefined:
      return <>{t('syncStatusSelect.syncStatus')}</>
    default:
      return <OptionComponent option={option} />
  }
}

export const SyncStatusSelect = ({
  value,
  setValue,
}: {
  value: SyncStatus
  setValue: (value: SyncStatus) => void
}): JSX.Element => {
  return (
    <SingleSelect<SyncStatus>
      options={[undefined, 'up_to_date', 'out_of_date']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
