import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../ExerciseCommunitySolutionsList'

const OptionComponent = ({ option: order }: { option: Order }) => {
  switch (order) {
    case 'most_starred':
      return <React.Fragment>Sort by Most Starred</React.Fragment>
    case 'newest':
      return <React.Fragment>Sort by Newest</React.Fragment>
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
      options={['most_starred', 'newest']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
