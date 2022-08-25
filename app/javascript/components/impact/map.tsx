import React, { useEffect, useState } from 'react'
import { GraphicalIcon, TrackIcon } from '../../components/common'
import { MetricsChannel } from '../../channels/metricsChannel'
import { Metric } from '../../types'

const coordinatesToPosition = (latitude, longitude) => {
  const map_width = 724
  const map_height = 421

  let x = (longitude + 180) * (map_width / 360)
  let last_rad = (latitude * Math.PI) / 180
  let merc_north = Math.log(Math.tan(Math.PI / 4 + last_rad / 2))
  let y = map_height / 2 - (map_width * merc_north) / (2 * Math.PI)

  // First bit is because we have a terrible map.
  // Second bit scales it to a percentage
  const left = ((x - 15) / map_width) * 100
  const top = ((y + 62) / map_height) * 100
  return [left, top]
}

const MetricPointInner = ({ metric }: { metric: Metric }): JSX.Element => {
  if (metric.track) {
    return (
      <TrackIcon
        iconUrl={metric.track.iconUrl}
        title={metric.track.title}
        className="w-[32px] h-[32px] translate-y-[-50%] translate-x-[-50%]"
      />
    )
  } else {
    return <>Wut</>
  }
}

const MetricPoint = ({ metric }: { metric: Metric }): JSX.Element => {
  const [left, top] = coordinatesToPosition(
    metric.coordinates[0],
    metric.coordinates[1]
  )

  return (
    <div
      style={{ left: `${left}%`, top: `${top}%` }}
      className="map-point absolute"
    >
      <MetricPointInner metric={metric} />
    </div>
  )

  // = track_icon data[:track], css_class: 'w-[32px] h-[32px] translate-y-[-50%] translate-x-[-50%]'
}

export default ({
  initialMetrics,
}: {
  initialMetrics: Metric[]
}): JSX.Element => {
  const [metrics, setMetrics] = useState(initialMetrics)

  useEffect(() => {
    const connection = new MetricsChannel((metric: Metric) => {
      setMetrics((oldMetrics) => [...oldMetrics, metric])
    })

    return () => connection.disconnect()
  }, [metrics])

  return (
    <div className="relative">
      <GraphicalIcon icon="world-map" category="graphics" class_name="w-fill" />
      {metrics.map((metric) => (
        <MetricPoint key={metric.id} metric={metric} />
      ))}
    </div>
  )
}
