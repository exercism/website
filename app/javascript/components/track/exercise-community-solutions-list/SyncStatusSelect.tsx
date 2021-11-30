import React from 'react'
import { SingleSelect } from '../../common/SingleSelect'
import { SyncStatus } from '../ExerciseCommunitySolutionsList'

const OptionComponent = ({ option: syncStatus }: { option: SyncStatus }) => {
  switch (syncStatus) {
    case undefined:
      return <>Sync status</>
    case 'up_to_date':
      return <>Up-to-date</>
    case 'out_of_date':
      return <>Out-of-date</>
  }
}

export const SyncStatusSelect = ({
  value,
  setValue,
}: {
  value: SyncStatus
  setValue: (value: SyncStatus) => void
}): JSX.Element => {
  return (
    <SingleSelect<SyncStatus>
      options={[undefined, 'up_to_date', 'out_of_date']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
