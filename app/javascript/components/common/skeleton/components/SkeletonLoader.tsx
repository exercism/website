import React from 'react'

// Assuming SkeletonCircle, SkeletonRect, and SkeletonText are updated to accept a `style` prop
import { SkeletonShape } from './SkeletonCircle'
import { SkeletonText } from './SkeletonText'

type DivProps = React.HTMLProps<HTMLDivElement>

type SkeletonShapeElement = {
  type: 'circle' | 'rect'
  props: DivProps & {
    style: { width: number | string; height: number | string }
  }
}

type SkeletonTextElement = {
  type: 'text'
  props: { lines: number }
}

type SkeletonElement = SkeletonShapeElement | SkeletonTextElement

type SkeletonBlock = React.HTMLProps<HTMLDivElement> & {
  elements: SkeletonElement[]
}

type SkeletonLoaderProps = {
  blocks: SkeletonBlock[]
  style?: React.CSSProperties
}

export function SkeletonLoader({ blocks, style }: SkeletonLoaderProps) {
  const renderElement = (element: SkeletonElement) => {
    switch (element.type) {
      case 'circle':
      case 'rect':
        return <SkeletonShape shape={element.type} {...element.props} />
      case 'text':
        return <SkeletonText {...element.props} />
      default:
        return null
    }
  }

  return (
    <div className="c-skeleton-loader" style={style}>
      {blocks.map((block, blockIndex) => (
        <div
          key={blockIndex}
          {...block}
          className={`flex flex-row ${block.className || ''}`}
        >
          {block.elements.map((element, elementIdx) => (
            <div key={elementIdx} className="flex flex-row">
              {renderElement(element)}
            </div>
          ))}
        </div>
      ))}
    </div>
  )
}
