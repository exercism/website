import React from 'react'
import { TaskSize } from '../../types'
import { ExercismMultipleSelect } from '../../common/ExercismMultipleSelect'
import { SizeTag } from './task/SizeTag'

const SizeOption = ({ option: size }: { option: TaskSize }): JSX.Element => {
  switch (size) {
    case 'tiny':
      return (
        <React.Fragment>
          <SizeTag size={size} />
          <div className="info">
            <div className="title">Extra Small</div>
            <div className="description">Trivial amount of work</div>
          </div>
        </React.Fragment>
      )
    case 'small':
      return (
        <React.Fragment>
          <SizeTag size={size} />
          <div className="info">
            <div className="title">Small</div>
            <div className="description">Small amount of work</div>
          </div>
        </React.Fragment>
      )
    case 'medium':
      return (
        <React.Fragment>
          <SizeTag size={size} />
          <div className="info">
            <div className="title">Medium</div>
            <div className="description">Average amount of work</div>
          </div>
        </React.Fragment>
      )
    case 'large':
      return (
        <React.Fragment>
          <SizeTag size={size} />
          <div className="info">
            <div className="title">Large</div>
            <div className="description">Large amount of work</div>
          </div>
        </React.Fragment>
      )
    case 'massive':
      return (
        <React.Fragment>
          <SizeTag size={size} />
          <div className="info">
            <div className="title">Extra Large</div>
            <div className="description">Massive amount of work</div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ value: sizes }: { value: TaskSize[] }) => {
  if (sizes.length > 1) {
    return <div>Multiple</div>
  }

  switch (sizes[0]) {
    case 'tiny':
      return <div>Extra Small</div>
    case 'small':
      return <div>Small</div>
    case 'medium':
      return <div>Medium</div>
    case 'large':
      return <div>Large</div>
    case 'massive':
      return <div>Massive</div>
    case undefined:
      return <div>All sizes</div>
  }
}

const ResetComponent = () => {
  return (
    <React.Fragment>
      <div className="info">
        <div className="title">All sizes</div>
      </div>
    </React.Fragment>
  )
}

export const SizeSwitcher = ({
  value,
  setValue,
}: {
  value: TaskSize[]
  setValue: (sizes: TaskSize[]) => void
}): JSX.Element => {
  return (
    <ExercismMultipleSelect<TaskSize>
      options={['tiny', 'small', 'medium', 'large', 'massive']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={SizeOption}
      // TODO: Change these class names
      componentClassName="c-track-switcher --small"
      buttonClassName="current-track"
      panelClassName="c-track-switcher-dropdown"
    />
  )
}
