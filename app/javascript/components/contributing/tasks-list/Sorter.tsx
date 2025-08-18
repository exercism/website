// i18n-key-prefix: tasksList.sorter
// i18n-namespace: components/contributing
import React from 'react'
import { TasksListOrder } from '../TasksList'
import { SingleSelect } from '../../common/SingleSelect'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({
  option: order,
}: {
  option: TasksListOrder
}): JSX.Element => {
  const { t } = useAppTranslation('components/contributing')
  switch (order) {
    case 'newest':
      return <div>{t('tasksList.sorter.sortByMostRecent')}</div>
    case 'oldest':
      return <div>{t('tasksList.sorter.sortByOldest')}</div>
    case 'track':
      return <div>{t('tasksList.sorter.sortByTrack')}</div>
  }
}

export const Sorter = ({
  value,
  setValue,
}: {
  value: TasksListOrder
  setValue: (value: TasksListOrder) => void
}): JSX.Element => {
  return (
    <SingleSelect<TasksListOrder>
      options={['newest', 'oldest', 'track']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
