import { ChartConfiguration, ChartData } from 'chart.js'
import { FILL_COLOR } from './plugins'

type Milestone = { date: string; text: string; emoji: string }

export function createChartConfig(
  data: number[],
  labels: string[],
  milestones: Milestone[]
): ChartConfiguration<'line'> & { milestones: Milestone[] } {
  const GRID_COLOR = '#3c364a'
  const Y_AXIS_OFFSET = 1.3
  const Y_AXIS_MAX = data[data.length - 1] * Y_AXIS_OFFSET

  console.log('DATA:', data)
  const DATA: ChartData<'line'> = {
    // labels: new Array(data.length).fill(''),
    labels,
    datasets: [
      {
        label: '',
        data: data,
        borderColor: 'rgba(0,0,0,0)',
        backgroundColor: FILL_COLOR,
        tension: 0.2,
        fill: true,
      },
    ],
  }

  const CONFIG: ChartConfiguration<'line'> & { milestones: Milestone[] } = {
    type: 'line',
    data: DATA,
    milestones: milestones,
    options: {
      onHover: () => null,
      animation: false,
      borderColor: GRID_COLOR,
      responsive: true,
      maintainAspectRatio: false,
      layout: {
        padding: -10,
      },
      scales: {
        x: {
          type: 'category',
          offset: false,
          ticks: {
            display: false,
          },
          grid: {
            lineWidth(ctx) {
              const lineWidth = ctx.index % 12 === 0 ? 1 : 0
              return lineWidth
            },
            color: GRID_COLOR,
            drawBorder: false,
            borderWidth: 0,
          },
        },
        y: {
          offset: false,
          beginAtZero: true,
          max: Y_AXIS_MAX,
          ticks: {
            display: false,
          },
          grid: {
            display: true,
            color: GRID_COLOR,
            borderWidth: 0,
          },
          labels: [],
        },
      },
      elements: {
        point: {
          radius: 0,
        },
      },
      plugins: {
        tooltip: {
          enabled: false,
        },
        legend: {
          display: false,
        },

        title: {
          display: false,
        },
      },
    },
  }

  return CONFIG
}
