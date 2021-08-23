import React from 'react'
import { SingleSelect } from '../../common'

type Status = undefined | 'none' | 'requested' | 'in_progress' | 'finished'

const OptionComponent = ({
  option: status,
}: {
  option: Status
}): JSX.Element => {
  switch (status) {
    case 'none':
      return <>No mentoring</>
    case 'requested':
      return <>Mentoring Requested</>
    case 'in_progress':
      return <>Mentoring in progress</>
    case 'finished':
      return <>Mentoring Completed</>
    case undefined:
      return <>Any</>
  }
}

const SelectedComponent = ({ option }: { option: Status }) => {
  switch (option) {
    case undefined:
      return <>Mentoring status</>
    default:
      return <OptionComponent option={option} />
  }
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
      options={[undefined, 'none', 'requested', 'in_progress', 'finished']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
