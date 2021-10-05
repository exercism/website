import React from 'react'
import { SingleSelect } from '../../common'

type Status = undefined | 'started' | 'iterated' | 'completed' | 'published'

const OptionComponent = ({
  option: status,
}: {
  option: Status
}): JSX.Element => {
  switch (status) {
    case 'started':
      return <>Started</>
    case 'iterated':
      return <>Iterated</>
    case 'completed':
      return <>Completed</>
    case 'published':
      return <>Published</>
    case undefined:
      return <>All</>
  }
}

const SelectedComponent = ({ option }: { option: Status }) => {
  switch (option) {
    case undefined:
      return <>Exercise status</>
    default:
      return <OptionComponent option={option} />
  }
}

export const ExerciseStatusSelect = ({
  value,
  setValue,
}: {
  value: Status
  setValue: (value: Status) => void
}): JSX.Element => {
  return (
    <SingleSelect<Status>
      options={[undefined, 'started', 'iterated', 'completed', 'published']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
