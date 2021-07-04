import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../ContributionResults'

const OptionComponent = ({ option: order }: { option: Order }) => {
  switch (order) {
    case 'oldest_first':
      return <React.Fragment>Sort by Oldest First</React.Fragment>
    case 'newest_first':
      return <React.Fragment>Sort by Newest First</React.Fragment>
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
