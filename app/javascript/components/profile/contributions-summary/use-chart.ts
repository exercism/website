import { useEffect, useState } from 'react'
import Chart from 'chart.js/auto'
import { ChartConfiguration, ChartDataset } from 'chart.js'

const createBluePurpleGradient = (
  chart: Chart<'radar'>,
  opacity: number
): CanvasGradient | string => {
  const { ctx, chartArea } = chart

  if (!chartArea) {
    return '#FFFFFF'
  }

  const gradient = ctx.createLinearGradient(
    0,
    chartArea.bottom,
    0,
    chartArea.top
  )
  gradient.addColorStop(0, `rgba(34, 0, 255, ${opacity})`)
  gradient.addColorStop(1, `rgba(158, 0, 255, ${opacity})`)

  return gradient
}

const padReputation = (reputation: number[]): number[] => {
  const max = reputation.reduce((a, b) => a + b, 0)
  const min = max / 8

  return reputation.map((r) => min + r)
}

const generateConfig = (
  canvas: HTMLCanvasElement
): ChartConfiguration<'radar'> => {
  const borderColor = getComputedStyle(canvas).getPropertyValue(
    '--chartBorderColor'
  )

  return {
    type: 'radar',
    data: {
      labels: [],
      datasets: [],
    },
    options: {
      aspectRatio: 1,
      elements: {
        line: { borderWidth: 3 },
      },
      scales: {
        r: {
          beginAtZero: true,
          ticks: { display: false, callback: (val) => `${val}` },
          angleLines: { color: borderColor },
          grid: { color: borderColor },
        },
      },
      plugins: {
        legend: { display: false },
        tooltip: { enabled: false },
      },
    },
  }
}

export const useChart = (
  canvas: HTMLCanvasElement | null,
  reputation: number[],
  trackColor?: string
): Chart<'radar'> => {
  const [chart, setChart] = useState<Chart<'radar'> | null>(null)
  const paddedReputation = padReputation(reputation)

  useEffect(() => {
    if (!canvas) {
      return
    }

    const chart = new Chart<'radar'>(canvas, generateConfig(canvas))

    setChart(chart)

    return () => chart.destroy()
  }, [canvas])

  useEffect(() => {
    if (!chart) {
      return
    }

    const dataset: ChartDataset<'radar'> = {
      label: '',
      data: paddedReputation,
      backgroundColor: (context) =>
        trackColor
          ? `rgba(${trackColor}, 0.3)`
          : createBluePurpleGradient(context.chart, 0.3),
      borderColor: (context) =>
        trackColor
          ? `rgba(${trackColor}, 1)`
          : createBluePurpleGradient(context.chart, 1),
      pointBorderColor: (context) =>
        trackColor ? '#FFFFFF' : createBluePurpleGradient(context.chart, 1),
      pointBackgroundColor: (context) =>
        trackColor
          ? `rgba(${trackColor}, 1)`
          : createBluePurpleGradient(context.chart, 1),
      pointHoverBackgroundColor: (context) =>
        trackColor
          ? `rgba(${trackColor}, 1)`
          : createBluePurpleGradient(context.chart, 1),
      pointHoverBorderColor: (context) =>
        trackColor
          ? `rgba(${trackColor}, 1)`
          : createBluePurpleGradient(context.chart, 1),
      pointRadius: 5,
      pointHoverRadius: 5,
    }
    chart.data.labels = paddedReputation.map(() => '')
    chart.data.datasets = [dataset]

    chart.update()
  }, [chart, JSON.stringify(paddedReputation), trackColor])

  return { chart }
}
