import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../SolutionsList'

const OptionComponent = ({ option: order }: { option: Order }) => {
  switch (order) {
    case 'oldest_first':
      return <>Oldest First</>
    case 'newest_first':
      return <>Newest First</>
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
