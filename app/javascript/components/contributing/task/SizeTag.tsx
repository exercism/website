import React from 'react'
import { TaskSize } from '../../types'

export const SizeTag = ({ size }: { size?: TaskSize }): JSX.Element => {
  switch (size) {
    case 'tiny':
      return <div className="size">xs</div>
    case 'small':
      return <div className="size">s</div>
    case 'medium':
      return <div className="size">m</div>
    case 'large':
      return <div className="size">l</div>
    case 'massive':
      return <div className="size">xl</div>
    default:
      return <div className="size blank" />
  }
}
