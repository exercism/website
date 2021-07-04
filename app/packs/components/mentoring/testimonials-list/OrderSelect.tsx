import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../TestimonialsList'

const OptionComponent = ({ option: order }: { option: Order }) => {
  switch (order) {
    case 'unrevealed':
      return <React.Fragment>Sort by Unrevealed First</React.Fragment>
    case 'newest':
      return <React.Fragment>Sort by Newest First</React.Fragment>
    case 'oldest':
      return <React.Fragment>Sort by Oldest First</React.Fragment>
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
      options={['unrevealed', 'newest', 'oldest']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
