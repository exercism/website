import React, { useEffect, useState } from 'react'
import {
  CategoryScale,
  Chart,
  Filler,
  LinearScale,
  LineController,
  LineElement,
  PointElement,
} from 'chart.js'
import { generateAccumulatedData } from './chart-elements/data'
import { CANVAS_CUSTOM_POINTS } from './chart-elements'
import { createChartConfig } from './chart-elements/chart-config'

export type ChartData = { usersPerMonth: string; milestones: string }

export default function ImpactChart({
  data,
}: {
  data: ChartData
}): JSX.Element {
  const [canvas, setCanvas] = useState<HTMLCanvasElement | null>(null)
  const [chart, setChart] = useState<Chart<'line'> | null>(null)

  Chart.register(
    LineController,
    LineElement,
    PointElement,
    CategoryScale,
    LinearScale,
    Filler,
    CANVAS_CUSTOM_POINTS
  )

  useEffect(() => {
    if (!canvas) return

    const { dataArray, keys, dateMap } = generateAccumulatedData(
      JSON.parse(data.usersPerMonth)
    )
    const chart = new Chart<'line'>(
      canvas,
      createChartConfig(dataArray, keys, JSON.parse(data.milestones), dateMap)
    )
    setChart(chart)

    return () => chart.destroy()
  }, [canvas, data.milestones, data.usersPerMonth])

  useEffect(() => {
    if (!chart) return

    chart.update()
  }, [chart])

  return (
    <div className="relative">
      {/* <NumberOfStudentsLabel /> */}
      <canvas height={480} ref={setCanvas} />
    </div>
  )
}
