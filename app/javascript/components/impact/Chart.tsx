import React, { useEffect, useState } from 'react'
import { Chart } from 'chart.js'
import {
  NumberOfStudentsLabel,
  CONFIG,
  CANVAS_BACKGROUND,
} from './chart-elements'
import { CANVAS_CUSTOM_POINTS } from './chart-elements/chart-config'

export default function ImpactChart({ data }: { data: any }): JSX.Element {
  const [canvas, setCanvas] = useState<HTMLCanvasElement | null>(null)
  const [chart, setChart] = useState<Chart<'line'> | null>(null)
  useEffect(() => {
    if (!canvas) {
      return
    }
    const chart = new Chart<'line'>(canvas, CONFIG)
    setChart(chart)

    return () => chart.destroy()
  }, [canvas])

  useEffect(() => {
    if (!chart) {
      return
    }
    Chart.register(CANVAS_BACKGROUND)
    Chart.register(CANVAS_CUSTOM_POINTS)

    const customPointStyle = ['', '', '', '', '', '', '', '']

    chart.data.labels = CONFIG.data.labels
    chart.data.datasets = CONFIG.data.datasets
    chart.data.datasets[0].pointStyle = customPointStyle

    chart.update()
  }, [chart])

  return (
    <>
      <NumberOfStudentsLabel />
      <canvas height={900} ref={setCanvas} />
    </>
  )
}
