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
      return (
        <div className="info">
          <div className="title">In progress</div>
        </div>
      )
    case 'completed':
      return (
        <div className="info">
          <div className="title">Completed</div>
        </div>
      )
    case 'published':
      return (
        <div className="info">
          <div className="title">Completed and published</div>
        </div>
      )
    case 'not_published':
      return (
        <div className="info">
          <div className="title">Completed and not published</div>
        </div>
      )
    case undefined:
      return (
        <div className="info">
          <div className="title">All</div>
        </div>
      )
  }
}

const SelectedComponent = () => {
  return <>Exercise status</>
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
