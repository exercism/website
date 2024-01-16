import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'
import { ContributionCategoryId } from '@/components/types'

const OptionComponent = ({
  option: category,
}: {
  option: ContributionCategoryId | undefined
}): JSX.Element => {
  switch (category) {
    case 'authoring':
      return (
        <div className="info">
          <div className="title">Contributing to Exercises</div>
        </div>
      )
    case 'building':
      return (
        <div className="info">
          <div className="title">Building Exercism</div>
        </div>
      )
    case 'maintaining':
      return (
        <div className="info">
          <div className="title">Maintaining</div>
        </div>
      )
    case 'mentoring':
      return (
        <div className="info">
          <div className="title">Mentoring</div>
        </div>
      )
    case 'publishing':
      return (
        <div className="info">
          <div className="title">Publishing</div>
        </div>
      )
    case 'other':
      return (
        <div className="info">
          <div className="title">Other</div>
        </div>
      )
    case undefined:
      return (
        <div className="info">
          <div className="title">Any category</div>
        </div>
      )
  }
}

const SelectedComponent = () => {
  return <>Category</>
}

export const CategorySelect = ({
  value,
  setValue,
}: {
  value: ContributionCategoryId | undefined
  setValue: (value: ContributionCategoryId | undefined) => void
}): JSX.Element => {
  return (
    <SingleSelect<ContributionCategoryId | undefined>
      options={[
        undefined,
        'building',
        'authoring',
        'maintaining',
        'mentoring',
        'publishing',
        'other',
      ]}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
