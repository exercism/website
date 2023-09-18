import React from 'react'
import { SingleSelect } from '@/components/common/SingleSelect'
import { Category } from '../ContributorsList'

const OptionComponent = ({
  option: category,
}: {
  option: Category
}): JSX.Element => {
  switch (category) {
    case 'authoring':
      return (
        <React.Fragment>
          <div className="info">
            <div className="title">Authoring</div>
          </div>
        </React.Fragment>
      )
    case 'building':
      return (
        <React.Fragment>
          <div className="info">
            <div className="title">Building</div>
          </div>
        </React.Fragment>
      )
    case 'maintaining':
      return (
        <React.Fragment>
          <div className="info">
            <div className="title">Maintaining</div>
          </div>
        </React.Fragment>
      )
    case 'mentoring':
      return (
        <React.Fragment>
          <div className="info">
            <div className="title">Mentoring</div>
          </div>
        </React.Fragment>
      )
    case undefined:
      return (
        <React.Fragment>
          <div className="info">
            <div className="title">All categories</div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ option: category }: { option: Category }) => {
  switch (category) {
    case 'authoring':
      return <>Authoring</>
    case 'building':
      return <>Building</>
    case 'mentoring':
      return <>Mentoring</>
    case 'maintaining':
      return <>Maintaining</>
    case undefined:
      return <>All categories</>
  }
}
export const CategorySwitcher = ({
  value,
  setValue,
}: {
  value: Category
  setValue: (value: Category) => void
}): JSX.Element => {
  return (
    <SingleSelect<Category>
      options={[undefined, 'building', 'authoring', 'maintaining', 'mentoring']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      OptionComponent={OptionComponent}
    />
  )
}
