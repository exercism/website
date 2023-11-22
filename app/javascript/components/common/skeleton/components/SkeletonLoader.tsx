import React from 'react'
import { SkeletonCircle } from './SkeletonCircle'
import { SkeletonText } from './SkeletonText'
import { SkeletonRect } from './SkeletonRect'

type SkeletonShapeElement = {
  type: 'circle' | 'rect'
  width: string | number
  height: string | number
}

type SkeletonTextElement = {
  type: 'text'
  lines?: number
}

type SkeletonElement = SkeletonShapeElement | SkeletonTextElement

type SkeletonLoaderProps = {
  blocks: SkeletonElement[][]
  gap: string | number
}

export function SkeletonLoader({ blocks, gap }: SkeletonLoaderProps) {
  const renderElement = (element: SkeletonElement) => {
    switch (element.type) {
      case 'circle':
        return <SkeletonCircle height={element.height} width={element.width} />
      case 'rect':
        return <SkeletonRect height={element.height} width={element.width} />
      case 'text':
        return <SkeletonText lines={element.lines || 1} />
      default:
        return null
    }
  }

  const renderRows = () => {
    return blocks.map((row, rowIndex) => (
      <div key={rowIndex} className="flex flex-row w-100 gap-16">
        {row.map((element) => renderElement(element))}
      </div>
    ))
  }

  return (
    <div className="c-skeleton-loader" style={{ gap }}>
      {renderRows()}
    </div>
  )
}
