import React from 'react'
import * as Skeleton from '../components'
import { repeatComponents } from '@/utils/repeatComponents'

export function ExerciseStatusChartSkeleton() {
  return (
    <Skeleton.Wrapper className="exercises">
      {repeatComponents({
        times: 100,
        render: (index) => (
          <Skeleton.Shape
            key={index}
            shape="circle"
            style={{ width: 24, height: 24 }}
          />
        ),
      })}
    </Skeleton.Wrapper>
  )
}
