// i18n-key-prefix: orderSelect
// i18n-namespace: components/student/tracks-list
import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../TracksList'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const OptionComponent = ({ option: order }: { option: Order }) => {
  const { t } = useAppTranslation()
  switch (order) {
    case 'last_touched_first':
      return (
        <React.Fragment>{t('orderSelect.sortByLastTouched')}</React.Fragment>
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
      options={['last_touched_first']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
