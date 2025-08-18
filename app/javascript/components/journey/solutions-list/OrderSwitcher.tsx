import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../SolutionsList'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({ option: order }: { option: Order }) => {
  const { t } = useAppTranslation('components/journey/solutions-list')
  switch (order) {
    case 'oldest_first':
      return <>{t('orderSwitcher.oldestFirst')}</>
    case 'newest_first':
      return <>{t('orderSwitcher.newestFirst')}</>
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
