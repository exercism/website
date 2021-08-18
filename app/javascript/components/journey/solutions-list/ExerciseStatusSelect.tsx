import React from 'react'
import { SingleSelect } from '../../common'

type Status =
  | undefined
  | 'in_progress'
  | 'completed'
  | 'published'
  | 'not_published'

const OptionComponent = ({
  option: status,
}: {
  option: Status
}): JSX.Element => {
  switch (status) {
    case 'in_progress':
      return <>In progress</>
    case 'completed':
      return <>Completed</>
    case 'published':
      return <>Published</>
    case 'not_published':
      return <>Not published (completed)</>
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
      options={[
        undefined,
        'in_progress',
        'completed',
        'published',
        'not_published',
      ]}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
