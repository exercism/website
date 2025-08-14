import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../ContributionResults'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({ option: order }: { option: Order }) => {
  const { t } = useAppTranslation('components/journey/contribution-results')
  switch (order) {
    case 'oldest_first':
      return (
        <React.Fragment>{t('orderSwitcher.sortByOldestFirst')}</React.Fragment>
      )
    case 'newest_first':
      return (
        <React.Fragment>{t('orderSwitcher.sortByNewestFirst')}</React.Fragment>
      )
  }
}

export const OrderSwitcher = ({
  value,
  setValue,
}: {
  value: Order
  setValue: (value: Order) => void
}): JSX.Element => {
  return (
    <SingleSelect<Order>
      options={['newest_first', 'oldest_first']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
