import React, { useEffect, useState, useRef } from 'react'
import { GraphicalIcon, TrackIcon, Avatar } from '../../components/common'
import { GenericTooltip } from '../../components/misc/ExercismTippy'
import { MetricsChannel } from '../../channels/metricsChannel'
import { Metric } from '../types'

const coordinatesToPosition = (latitude: number, longitude: number) => {
  const map_width = 724
  const map_height = 421

  const x = (longitude + 180) * (map_width / 360)
  const last_rad = (latitude * Math.PI) / 180
  const merc_north = Math.log(Math.tan(Math.PI / 4 + last_rad / 2))
  const y = map_height / 2 - (map_width * merc_north) / (2 * Math.PI)

  // First bit is because we have a terrible map.
  // Second bit scales it to a percentage
  const left = ((x - 15) / map_width) * 100
  const top = ((y + 62) / map_height) * 100
  return [left, top]
}

const MetricPointWithTooltip = ({
  metric,
  text,
  duration,
  content,
}: {
  metric: Metric
  text: string
  duration: number
  content: JSX.Element
}): JSX.Element => {
  const avatarRef = useRef(null)
  return (
    <GenericTooltip
      content={<strong className="font-semibold">{text}</strong>}
      placement="top"
      showOnCreate={true}
      followCursor={false}
      hideOnClick={false}
      trigger="manual"
      delay={[0, 0]}
      onShow={(i) => {
        setTimeout(() => {
          i.hide()
        }, duration - 50) // Make sure this aligns to the CSS animation.
      }}
    >
      {content}
    </GenericTooltip>
  )
}

const MetricPointUserWithTooltip = ({
  metric,
  text,
}: {
  metric: Metric
  text: string
}): JSX.Element => {
  const avatarRef = useRef(null)
  const content = (
    <div
      ref={avatarRef}
      className="relative border-2 border-gradient rounded-circle translate-y-[-50%] translate-x-[-50%]"
    >
      <Avatar
        src={metric.user.avatarUrl}
        handle={metric.user.handle}
        className=" w-[32px] h-[32px]"
      />
    </div>
  )
  return (
    <MetricPointWithTooltip
      metric={metric}
      text={text}
      duration={6000}
      content={content}
    />
  )
}

const MetricPointInner = ({ metric }: { metric: Metric }): JSX.Element => {
  switch (metric.type) {
    case 'sign_up_metric':
      const iconRef = useRef(null)
      const content = (
        <div
          ref={iconRef}
          className="relative border-2 border-gradient rounded-circle translate-y-[-50%] translate-x-[-50%]"
        >
          <GraphicalIcon
            icon="avatar-placeholder"
            className="w-[32px] h-[32px]"
          />
        </div>
      )
      return (
        <MetricPointWithTooltip
          metric={metric}
          text={`Someone joined Exercism`}
          duration={2000}
          content={content}
        />
      )
    case 'start_solution_metric':
      return (
        <TrackIcon
          iconUrl={metric.track.iconUrl}
          title={metric.track.title}
          className="w-[32px] h-[32px] translate-y-[-50%] translate-x-[-50%]"
        />
      )
    case 'submit_submission_metric':
      return (
        <TrackIcon
          iconUrl={metric.track.iconUrl}
          title={metric.track.title}
          className="w-[24px] h-[24px] translate-y-[-50%] translate-x-[-50%]"
        />
      )
    case 'publish_solution_metric':
      return (
        <MetricPointUserWithTooltip
          metric={metric}
          text={`@${metric.user.handle} published a new solution`}
        />
      )
    case 'open_issue_metric':
      return (
        <MetricPointUserWithTooltip
          metric={metric}
          text={`@${metric.user.handle} opened an issue on Exercism's GitHub`}
        />
      )
    case 'open_pull_request_metric':
      return (
        <MetricPointUserWithTooltip
          metric={metric}
          text={`@${metric.user.handle} submitted a Pull Request on Exercism's GitHub`}
        />
      )
    case 'merge_pull_request_metric':
      return (
        <MetricPointUserWithTooltip
          metric={metric}
          text={`@${metric.user.handle} had a Pull Request merged on Exercism's GitHub`}
        />
      )
    default:
      return <></>
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
      className={`map-point absolute metric-${metric.type}`}
    >
      <MetricPointInner metric={metric} />
    </div>
  )

  // = track_icon data[:track], css_class: 'w-[32px] h-[32px] translate-y-[-50%] translate-x-[-50%]'
}

export default ({
  initialMetrics,
  trackTitle,
}: {
  initialMetrics: Metric[]
  trackTitle?: string
}): JSX.Element => {
  const [metrics, setMetrics] = useState(initialMetrics)

  useEffect(() => {
    const connection = new MetricsChannel((metric: Metric) => {
      if (trackTitle && trackTitle !== metric.track?.title) {
        return
      }

      setMetrics((oldMetrics) => [...oldMetrics, metric])

      // Remove the metric again after 1 minute
      setTimeout(() => {
        setMetrics((oldMetrics) => oldMetrics.filter((m) => m !== metric))
      }, 60000)
    })

    return () => connection.disconnect()
  }, [metrics])

  return (
    /* TODO: Remove this height */
    <div>
      <div className="relative">
        <GraphicalIcon
          icon="world-map"
          category="graphics"
          width={680}
          height={400}
          className="w-fill mb-36 "
        />
        {metrics.map((metric) => (
          <MetricPoint key={metric.id} metric={metric} />
        ))}
      </div>
      {/*<TopLearningCountries data={TOP_LEARNING_DATA} />*/}
    </div>
  )
}
