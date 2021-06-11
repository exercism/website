import React from 'react'
import { TaskSize } from '../../../types'

export const SizeTag = ({ size }: { size?: TaskSize }): JSX.Element => {
  switch (size) {
    case 'tiny':
      return <div className="size-tag">xs</div>
    case 'small':
      return <div className="size-tag">s</div>
    case 'medium':
      return <div className="size-tag">m</div>
    case 'large':
      return <div className="size-tag">l</div>
    case 'massive':
      return <div className="size-tag">xl</div>
    default:
      return <div className="size-tag blank" />
  }
}
