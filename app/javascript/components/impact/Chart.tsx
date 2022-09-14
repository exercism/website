import React, { useEffect, useState } from 'react'
import { Chart } from 'chart.js'
import { generateAccumulatedData, MOCK_DATA } from './chart-elements/data'
import {
  NumberOfStudentsLabel,
  CANVAS_BACKGROUND,
  CANVAS_CUSTOM_POINTS,
} from './chart-elements'
import { createChartConfig } from './chart-elements/chart-config'

const MILESTONES = [
  // send it probably in this format
  { date: '202006', text: 'See if this emoji is centered', emoji: '\u{1f600}' },
  { date: '202206', text: 'Reached 1M users!!', emoji: '⭐' },
  { date: '201907', text: 'Exercism V2 launched', emoji: '🚀' },
  { date: '201411', text: 'Exercism V1 launched', emoji: '🚀' },
  { date: '201305', text: 'Exercism got launched', emoji: '🤯' },
]

export default function ImpactChart({ data }: { data: any }): JSX.Element {
  const [canvas, setCanvas] = useState<HTMLCanvasElement | null>(null)
  const [chart, setChart] = useState<Chart<'line'> | null>(null)
  useEffect(() => {
    if (!canvas) {
      return
    }

    const {
      dataArray: data,
      keys,
      dateMap,
    } = generateAccumulatedData(MOCK_DATA)
    const chart = new Chart<'line'>(
      canvas,
      createChartConfig(data, keys, MILESTONES, dateMap)
    )
    setChart(chart)

    return () => chart.destroy()
  }, [canvas])

  useEffect(() => {
    if (!chart) {
      return
    }
    Chart.register(CANVAS_BACKGROUND)
    Chart.register(CANVAS_CUSTOM_POINTS)

    chart.update()
  }, [chart])

  return (
    <>
      <NumberOfStudentsLabel />
      <canvas height={900} ref={setCanvas} />
    </>
  )
}
