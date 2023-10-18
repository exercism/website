import React, { useCallback } from 'react'
import { SortOption } from './Inbox'
import { SingleSelect } from '../common/SingleSelect'

const OptionComponent = ({ option }: { option: SortOption }) => {
  return <React.Fragment>{option.label}</React.Fragment>
}

export const Sorter = ({
  setOrder,
  setPage,
  order,
  sortOptions,
  className,
}: {
  setOrder: (order: string) => void
  setPage: (page: number) => void
  order: string
  sortOptions: readonly SortOption[]
  className?: string
}): JSX.Element => {
  const value = sortOptions.find((o) => o.value === order) || sortOptions[0]
  const setValue = useCallback(
    (option) => {
      setOrder(option.value)
      setPage(1)
    },
    [setOrder, setPage]
  )

  return (
    <SingleSelect<SortOption>
      options={sortOptions}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
      className={className}
    />
  )
}
