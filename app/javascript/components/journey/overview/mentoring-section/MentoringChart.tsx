// i18n-key-prefix: mentoringChart
// i18n-namespace: components/journey/overview/mentoring-section
import React, { useState, useEffect } from 'react'
import Chart from 'chart.js/auto'
import { ChartConfiguration, ChartDataset } from 'chart.js'
import { MentoredTrackProgressList } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const CONFIG: ChartConfiguration<'doughnut'> = {
  type: 'doughnut',
  data: {
    labels: [],
    datasets: [],
  },
  options: {
    cutout: 150,
    plugins: {
      legend: { display: false },
    },
  },
}

export const MentoringChart = ({
  tracks,
}: {
  tracks: MentoredTrackProgressList
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/mentoring-section'
  )
  const [canvas, setCanvas] = useState<HTMLCanvasElement | null>(null)
  const [chart, setChart] = useState<Chart<'doughnut'> | null>(null)

  useEffect(() => {
    if (!canvas) {
      return
    }
    const chart = new Chart<'doughnut'>(canvas, CONFIG)

    setChart(chart)

    return () => chart.destroy()
  }, [canvas])

  useEffect(() => {
    if (!chart) {
      return
    }

    const dataset: ChartDataset<'doughnut'> = {
      label: t('mentoringChart.sessionsMentoredPerTrack'),
      data: tracks.items.map((track) => track.numDiscussions),
      backgroundColor: tracks.items.map(
        (track) =>
          `rgb(${getComputedStyle(document.documentElement).getPropertyValue(
            `--track-color-${track.slug}`
          )})`
      ),
      borderWidth: 0,
      hoverOffset: 4,
    }
    chart.data.labels = tracks.items.map((track) => track.title)
    chart.data.datasets = [dataset]

    chart.update()
  }, [chart, tracks.items, t])

  return (
    <div className="chart">
      <canvas id="mentoring-chart" width="350" height="350" ref={setCanvas} />
    </div>
  )
}
