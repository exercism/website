import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Order } from '../ExerciseCommunitySolutionsList'

const OptionComponent = ({ option: order }: { option: Order }) => {
  switch (order) {
    case 'most_popular':
      return <React.Fragment>Sort by Most Submitted</React.Fragment>
    case 'newest':
      return <React.Fragment>Sort by Newest</React.Fragment>
    case 'oldest':
      return <React.Fragment>Sort by Oldest</React.Fragment>
    case 'fewest_loc':
      return <React.Fragment>Sort by Fewest Lines</React.Fragment>
    case 'highest_reputation':
      return <React.Fragment>Sort by Highest Rep User</React.Fragment>
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
      options={[
        'most_popular',
        'newest',
        'oldest',
        'fewest_loc',
        'highest_reputation',
      ]}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
      className="md:w-[290px] w-100"
    />
  )
}
