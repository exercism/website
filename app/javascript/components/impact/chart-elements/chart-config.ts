import { ChartConfiguration, ChartData } from 'chart.js'
import { FILL_COLOR } from './plugins'

type Milestone = { date: string; text: string; emoji: string }

export function createChartConfig(
  data: number[],
  labels: string[],
  milestones: Milestone[],
  dateMap: { [key: string]: number }
): ChartConfiguration<'line'> & { milestones: Milestone[] } {
  const GRID_COLOR = '#3c364a'

  // constants for responsive grid
  const Y_AXIS_MIN_OFFSET = 1.5
  // this can be set as a max offset if needed
  const Y_AXIS_MAX_OFFSET = Number.MAX_SAFE_INTEGER
  const SCREEN_BREAKPOINT = 1400 // plus the width of scrollbar, which is 15px on a mac by default, so the real breakpoint is 1415px
  const HIGHEST_VALUE = data[data.length - 1]

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

  const CONFIG: ChartConfiguration<'line'> & {
    milestones: Milestone[]
    dateMap: { [key: string]: number }
  } = {
    type: 'line',
    data: DATA,
    milestones: milestones,
    dateMap,
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
          // eslint-disable-next-line @typescript-eslint/ban-ts-comment
          // @ts-ignore
          max: (ctx) => {
            /* 
            make sure the chart doesn't go out of the screen, 
            so there is a minimum fixed offset 1.5 offset, which makes sure the chart will at most take 2/3 of the canvas. 
            */
            return (
              HIGHEST_VALUE *
              Math.min(
                Y_AXIS_MAX_OFFSET,
                Math.max(
                  Y_AXIS_MIN_OFFSET,
                  1 /
                    (ctx.chart.width / (SCREEN_BREAKPOINT * Y_AXIS_MIN_OFFSET))
                )
              )
            )
          },
          ticks: {
            display: false,
          },
          grid: {
            display: true,
            color: GRID_COLOR,
            borderWidth: 0,
          },
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
