import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'

export type MentoringStatus =
  | undefined
  | 'none'
  | 'requested'
  | 'in_progress'
  | 'finished'

const OptionComponent = ({
  option: status,
}: {
  option: MentoringStatus
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

const SelectedComponent = ({ option }: { option: MentoringStatus }) => {
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
  value: MentoringStatus
  setValue: (value: MentoringStatus) => void
}): JSX.Element => {
  return (
    <SingleSelect<MentoringStatus>
      options={[undefined, 'none', 'requested', 'in_progress', 'finished']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
