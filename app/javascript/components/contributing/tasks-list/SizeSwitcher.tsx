import React from 'react'
import { TaskSize } from '@/components/types'
import { GraphicalIcon } from '@/components/common'
import { MultipleSelect } from '@/components/common/MultipleSelect'
import { SizeTag } from './task/SizeTag'

const SizeOption = ({ option: size }: { option: TaskSize }): JSX.Element => {
  switch (size) {
    case 'tiny':
      return (
        <React.Fragment>
          <SizeTag size={size} />
          <div className="info">
            <div className="title">Tiny</div>
            <div className="description">A quick amount of work</div>
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
            <div className="title">Massive</div>
            <div className="description">Massive amount of work</div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ value: sizes }: { value: TaskSize[] }) => {
  if (sizes.length > 1) {
    return <>Multiple</>
  }

  switch (sizes[0]) {
    case 'tiny':
      return <>Extra Small</>
    case 'small':
      return <>Small</>
    case 'medium':
      return <>Medium</>
    case 'large':
      return <>Large</>
    case 'massive':
      return <>Massive</>
    case undefined:
      return <>All</>
  }
}

const ResetComponent = () => {
  return (
    <React.Fragment>
      <GraphicalIcon icon="task-size" className="task-icon" />
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
    <MultipleSelect<TaskSize>
      options={['tiny', 'small', 'medium', 'large', 'massive']}
      value={value}
      setValue={setValue}
      label="Size"
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={SizeOption}
      className="size-switcher"
    />
  )
}
