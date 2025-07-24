import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../BadgeResults'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({ option: order }: { option: Order }) => {
  const { t } = useAppTranslation('components/journey/badges-list')

  switch (order) {
    case 'unrevealed_first':
      return (
        <React.Fragment>
          {t('orderSwitcher.sortByUnrevealedFirst')}
        </React.Fragment>
      )
    case 'newest_first':
      return (
        <React.Fragment>{t('orderSwitcher.sortByNewestFirst')}</React.Fragment>
      )
    case 'oldest_first':
      return (
        <React.Fragment>{t('orderSwitcher.sortByOldestFirst')}</React.Fragment>
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
      options={['unrevealed_first', 'newest_first', 'oldest_first']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
