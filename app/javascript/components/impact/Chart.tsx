import React, { useEffect, useState } from 'react'
import { Chart } from 'chart.js'
import { generateAccumulatedData } from './chart-elements/data'
import {
  NumberOfStudentsLabel,
  CANVAS_BACKGROUND,
  CANVAS_CUSTOM_POINTS,
} from './chart-elements'
import { createChartConfig } from './chart-elements/chart-config'

type ChartData = { usersPerMonth: string; milestones: string }

export default function ImpactChart({
  data,
}: {
  data: ChartData
}): JSX.Element {
  const [canvas, setCanvas] = useState<HTMLCanvasElement | null>(null)
  const [chart, setChart] = useState<Chart<'line'> | null>(null)

  useEffect(() => {
    if (!canvas) {
      return
    }

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
    if (!chart) {
      return
    }
    Chart.register(CANVAS_BACKGROUND)
    Chart.register(CANVAS_CUSTOM_POINTS)

    chart.update()
  }, [chart])

  return (
    <div className="h-[900px]">
      <NumberOfStudentsLabel />
      <canvas ref={setCanvas}></canvas>
    </div>
  )
}
