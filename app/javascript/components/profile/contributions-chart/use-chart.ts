import { useEffect, useState, useMemo } from 'react'
import Chart from 'chart.js/auto'
import { ChartConfiguration, ChartData } from 'chart.js'

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
  const min = max / 15

  return reputation.map((r) => (r > min ? r : min))
}

export const useChart = (
  canvas: HTMLCanvasElement | null,
  reputation: number[],
  trackColor?: string
): Chart<'radar'> => {
  const [chart, setChart] = useState<Chart<'radar'> | null>(null)
  const paddedReputation = padReputation(reputation)
  const data: ChartData<'radar'> = useMemo(() => {
    return {
      labels: paddedReputation.map(() => ''),
      datasets: [
        {
          label: '',
          data: paddedReputation,
          backgroundColor: (context) => {
            return trackColor
              ? `rgba(${trackColor}, 0.3)`
              : createBluePurpleGradient(context.chart, 0.3)
          },
          borderColor: (context) => {
            return trackColor
              ? `rgba(${trackColor}, 1)`
              : createBluePurpleGradient(context.chart, 1)
          },
          pointBorderColor: (context) => {
            return trackColor
              ? '#FFFFFF'
              : createBluePurpleGradient(context.chart, 1)
          },
          pointBackgroundColor: (context) => {
            return trackColor
              ? `rgba(${trackColor}, 1)`
              : createBluePurpleGradient(context.chart, 1)
          },
          pointHoverBackgroundColor: (context) => {
            return trackColor
              ? `rgba(${trackColor}, 1)`
              : createBluePurpleGradient(context.chart, 1)
          },
          pointHoverBorderColor: (context) => {
            return trackColor
              ? `rgba(${trackColor}, 1)`
              : createBluePurpleGradient(context.chart, 1)
          },
          pointRadius: 5,
          pointHoverRadius: 5,
        },
      ],
    }
  }, [JSON.stringify(paddedReputation)])
  const config: ChartConfiguration<'radar'> = useMemo(() => {
    return {
      type: 'radar',
      data: data,
      options: {
        aspectRatio: 1,
        elements: {
          line: { borderWidth: 3 },
        },
        scales: {
          r: {
            beginAtZero: true,
            ticks: { display: false, color: 'red' },
            angleLines: { color: '#D5D8E4' },
            grid: { color: '#D5D8E4' },
          },
        },
        plugins: {
          legend: { display: false },
          tooltip: { enabled: false },
        },
      },
    }
  }, [data])

  useEffect(() => {
    if (!canvas) {
      return
    }
    const chart = new Chart<'radar'>(canvas, config)

    setChart(chart)

    return () => chart.destroy()
  }, [canvas, config])

  return { chart }
}
