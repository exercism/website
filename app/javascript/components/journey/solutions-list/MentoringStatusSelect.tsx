import React from 'react'
import { SingleSelect } from '../../common'

type Status = undefined | 'none' | 'requested' | 'in_progress' | 'completed'

const OptionComponent = ({
  option: status,
}: {
  option: Status
}): JSX.Element => {
  switch (status) {
    case 'none':
      return (
        <div className="info">
          <div className="title">None</div>
        </div>
      )
    case 'requested':
      return (
        <div className="info">
          <div className="title">Requested</div>
        </div>
      )
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
    case undefined:
      return (
        <div className="info">
          <div className="title">All</div>
        </div>
      )
  }
}

const SelectedComponent = () => {
  return <>Mentoring status</>
}

export const MentoringStatusSelect = ({
  value,
  setValue,
}: {
  value: Status
  setValue: (value: Status) => void
}): JSX.Element => {
  return (
    <SingleSelect<Status>
      options={[undefined, 'none', 'requested', 'in_progress', 'completed']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
