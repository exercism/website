// i18n-key-prefix: orderSelect
// i18n-namespace: components/profile/community-solutions-list
import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../CommunitySolutionsList'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({ option: order }: { option: Order }) => {
  const { t } = useAppTranslation('components/profile/community-solutions-list')

  switch (order) {
    case 'newest_first':
      return (
        <React.Fragment>{t('orderSelect.sortByNewestFirst')}</React.Fragment>
      )
    case 'oldest_first':
      return (
        <React.Fragment>{t('orderSelect.sortByOldestFirst')}</React.Fragment>
      )
    case 'most_starred':
      return (
        <React.Fragment>{t('orderSelect.sortByMostStarred')}</React.Fragment>
      )
  }
}

export const OrderSelect = ({
  value,
  setValue,
}: {
  value: Order
  setValue: (value: Order) => void
}): JSX.Element => {
  return (
    <SingleSelect<Order>
      options={['most_starred', 'newest_first', 'oldest_first']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
