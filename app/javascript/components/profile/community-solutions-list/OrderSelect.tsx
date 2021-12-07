import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../CommunitySolutionsList'

const OptionComponent = ({ option: order }: { option: Order }) => {
  switch (order) {
    case 'newest_first':
      return <React.Fragment>Sort by Newest First</React.Fragment>
    case 'oldest_first':
      return <React.Fragment>Sort by Oldest First</React.Fragment>
    case 'most_starred':
      return <React.Fragment>Sort by Most Starred</React.Fragment>
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
