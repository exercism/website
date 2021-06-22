import React from 'react'
import { TrackProgress } from '../../../types'

{
  /* TODO */
}
export const TimeGraph = ({ track }: { track: TrackProgress }): JSX.Element => {
  return (
    <svg viewBox="0 0 300 100">
      <polyline
        fill="none"
        stroke="url(#paint0_linear)"
        strokeWidth="3.5"
        points="0,95, 20,93, 40,85, 60,70, 80,64, 100,59, 120,55, 140,48, 160,40, 180,32, 200,22, 220,20, 240,15, 260,13, 280,10, 300,4"
      />
      <defs>
        <linearGradient
          id="paint0_linear"
          x1="66"
          y1="2.5"
          x2="66"
          y2="50.5"
          gradientUnits="userSpaceOnUse"
        >
          <stop stopColor="#2200FF" />
          <stop offset="1" stopColor="#9E00FF" />
        </linearGradient>
      </defs>
    </svg>
  )
}
