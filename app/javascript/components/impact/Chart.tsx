import React, { useEffect, useState } from 'react'
import Chart from 'chart.js/auto'
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
    Chart.register(CANVAS_CUSTOM_POINTS)

    chart.update()
  }, [chart])

  return (
    <div className="relative">
      {/* <NumberOfStudentsLabel /> */}
      <canvas height={480} ref={setCanvas} />
    </div>
  )
}
