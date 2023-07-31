import { ChartConfiguration, ChartData } from 'chart.js'
import { FILL_COLOR, GRID_COLOR } from './plugins'

type Milestone = { date: string; text: string; emoji: string }

export function createChartConfig(
  data: number[],
  labels: string[],
  milestones: Milestone[],
  dateMap: { [key: string]: number }
): ChartConfiguration<'line'> & { milestones: Milestone[] } {
  // constants for responsive grid
  // offsets are the reciprocal of the height of graphicon.
  // eg. 3/2 offset -> graphicon takes the 2/3 of canvas height
  const Y_AXIS_MIN_OFFSET = 1.2
  // this can be set as a max offset if needed
  const Y_AXIS_MAX_OFFSET = 1.2
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
            display: false,
          },
        },
        y: {
          offset: false,
          beginAtZero: true,
          // eslint-disable-next-line @typescript-eslint/ban-ts-comment
          // @ts-ignore
          max: (ctx) => {
            // max height of linechart
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
            display: false,
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
