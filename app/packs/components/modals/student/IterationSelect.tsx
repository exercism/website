import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { Iteration } from '../../types'

const OptionComponent = ({ option: idx }: { option: number }) => {
  return <React.Fragment>Iteration {idx}</React.Fragment>
}

export const IterationSelect = ({
  iterations,
  value,
  setValue,
}: {
  iterations: readonly Iteration[]
  value: number | null
  setValue: (value: number) => void
}): JSX.Element => {
  return (
    <SingleSelect<number>
      options={iterations.map((i) => i.idx)}
      value={value || iterations[0].idx}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
