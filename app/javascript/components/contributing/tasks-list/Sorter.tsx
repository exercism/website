import React from 'react'
import { TasksListOrder } from '../TasksList'
import { SingleSelect } from '../../common/SingleSelect'

const OptionComponent = ({
  option: order,
}: {
  option: TasksListOrder
}): JSX.Element => {
  switch (order) {
    case 'newest':
      return <div>Sort by most recent</div>
    case 'oldest':
      return <div>Sort by oldest</div>
    case 'track':
      return <div>Sort by track</div>
  }
}

export const Sorter = ({
  value,
  setValue,
}: {
  value: TasksListOrder
  setValue: (value: TasksListOrder) => void
}): JSX.Element => {
  return (
    <SingleSelect<TasksListOrder>
      options={['newest', 'oldest', 'track']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
