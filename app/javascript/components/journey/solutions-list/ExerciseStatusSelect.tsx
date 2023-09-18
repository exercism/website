import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'

export type ExerciseStatus =
  | undefined
  | 'started'
  | 'iterated'
  | 'completed'
  | 'published'

const OptionComponent = ({
  option: status,
}: {
  option: ExerciseStatus
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

const SelectedComponent = ({ option }: { option: ExerciseStatus }) => {
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
  value: ExerciseStatus
  setValue: (value: ExerciseStatus) => void
}): JSX.Element => {
  return (
    <SingleSelect<ExerciseStatus>
      options={[undefined, 'started', 'iterated', 'completed', 'published']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
