import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../TracksList'

const OptionComponent = ({ option: order }: { option: Order }) => {
  switch (order) {
    case 'last_touched_first':
      return <React.Fragment>Sort by last touched</React.Fragment>
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
