import React from 'react'
import { SingleSelect } from '../../../common/SingleSelect'
import { ReportReason } from '../FinishMentorDiscussionModal'

const OptionComponent = ({ option: reason }: { option: ReportReason }) => {
  switch (reason) {
    case 'coc':
      return <React.Fragment>Code of Conduct violation</React.Fragment>
    case 'incorrect':
      return <React.Fragment>Wrong or misleading information</React.Fragment>
    case 'other':
      return <React.Fragment>Other</React.Fragment>
  }
}

export const ReasonSelect = ({
  value,
  setValue,
}: {
  value: ReportReason
  setValue: (value: ReportReason) => void
}): JSX.Element => {
  return (
    <SingleSelect<ReportReason>
      options={['coc', 'incorrect', 'other']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
