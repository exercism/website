import React, {
  useState,
  useEffect,
  useRef,
  forwardRef,
  createRef,
} from 'react'
import { GraphicalIcon, ProminentLink } from '../common'
import { useChart } from './contributions-chart/use-chart'

const leftMargin = 100
const topMargin = 150
const buffer = 8

type CategoryId =
  | 'publishing'
  | 'mentoring'
  | 'authoring'
  | 'building'
  | 'maintaining'
  | 'other'

type Category = {
  id: CategoryId
  reputation: number
  metric?: string
}

export type Track = {
  id: string
  title: string
  iconUrl: string
  categories: readonly Category[]
}

const CATEGORY_TITLES = {
  publishing: 'Publishing',
  mentoring: 'Mentoring',
  authoring: 'Authoring',
  building: 'Building',
  maintaining: 'Maintaining',
  other: 'Other',
}

const CATEGORY_ICONS = {
  publishing: 'maintaining',
  mentoring: 'mentoring',
  authoring: 'concepts',
  building: 'maintaining',
  maintaining: 'maintaining',
  other: 'maintaining',
}

export const ContributionsSummary = ({
  tracks,
}: {
  tracks: readonly Track[]
}): JSX.Element => {
  const [canvas, setCanvas] = useState<HTMLCanvasElement | null>(null)
  const [currentTrack, setCurentTrack] = useState(tracks[0])
  const labelRefs = useRef(
    currentTrack.categories.map(() => createRef<HTMLDivElement>())
  )
  const trackColor =
    currentTrack.id !== 'all'
      ? getComputedStyle(document.documentElement).getPropertyValue(
          `--track-color-${currentTrack.id}`
        )
      : undefined

  const { chart } = useChart(
    canvas,
    currentTrack.categories.map((category) => category.reputation),
    trackColor
  )

  useEffect(() => {
    if (!canvas || !chart) {
      return
    }

    const containerHeight = (canvas.parentNode as HTMLElement).offsetHeight

    const point0 = chart.getDatasetMeta(0).iScale.getPointLabelPosition(0)
    const label0 = labelRefs.current[0].current
    if (!label0) {
      return
    }
    label0.style.left = `${point0.left + leftMargin}px`
    label0.style.marginLeft = `${-(label0.offsetWidth / 2)}px`
    label0.style.bottom = `${containerHeight - point0.bottom + topMargin}px`
    label0.style.visibility = 'visible'

    const point1 = chart.getDatasetMeta(0).iScale.getPointLabelPosition(1)
    const label1 = labelRefs.current[1].current
    if (!label1) {
      return
    }
    label1.style.left = `${point1.left + leftMargin + buffer}px`
    label1.style.bottom = `${
      containerHeight - point1.bottom + topMargin - label1.offsetHeight / 2
    }px`
    label1.style.visibility = 'visible'

    const point2 = chart.getDatasetMeta(0).iScale.getPointLabelPosition(2)
    const label2 = labelRefs.current[2].current
    if (!label2) {
      return
    }
    label2.style.left = `${point2.left + leftMargin + buffer}px`
    label2.style.bottom = `${
      containerHeight - point2.bottom + topMargin - label2.offsetHeight / 2
    }px`
    label2.style.visibility = 'visible'

    const point3 = chart.getDatasetMeta(0).iScale.getPointLabelPosition(3)
    const label3 = labelRefs.current[3].current
    if (!label3) {
      return
    }
    label3.style.left = `${point3.left + leftMargin}px`
    label3.style.marginLeft = `${-(label3.offsetWidth / 2)}px`
    label3.style.bottom = `${
      containerHeight - point3.bottom + topMargin - label3.offsetHeight
    }px`
    label3.style.visibility = 'visible'

    const point4 = chart.getDatasetMeta(0).iScale.getPointLabelPosition(4)
    const label4 = labelRefs.current[4].current
    if (!label4) {
      return
    }
    label4.style.left = `${
      point4.left + leftMargin - label4.offsetWidth - buffer
    }px`
    label4.style.bottom = `${
      containerHeight - point4.bottom + topMargin - label4.offsetHeight / 2
    }px`
    label4.style.visibility = 'visible'

    const point5 = chart.getDatasetMeta(0).iScale.getPointLabelPosition(5)
    const label5 = labelRefs.current[5].current
    if (!label5) {
      return
    }
    label5.style.left = `${
      point5.left + leftMargin - label5.offsetWidth - buffer
    }px`
    label5.style.bottom = `${
      containerHeight - point5.bottom + topMargin - label5.offsetHeight / 2
    }px`
    label5.style.visibility = 'visible'
  }, [canvas, chart])

  return (
    <section className="contributions-section">
      <div className="lg-container container">
        <div className="summary">
          <header className="section-header">
            <GraphicalIcon icon="contribute" hex={true} />
            <h2>Contributions</h2>
          </header>
          <div className="c-primary-reputation">
            <div className="--inner">
              erikschierboom has
              <GraphicalIcon icon="reputation" />
              667,133 Reputation
            </div>
          </div>
          {/* This is the same as on the Mentor Queue */}
          <div className="c-track-switcher">
            <div className="current-track">
              <GraphicalIcon icon="logo" />
              <div className="track-title">All</div>
              <div className="count">100 rep</div>
              <GraphicalIcon icon="chevron-down" className="action-icon" />
            </div>
          </div>

          {/* This works in the same way as the labels. The HTML is slightly different but logic is the same */}
          <div className="category">
            <GraphicalIcon icon="maintaining" hex />
            <div className="info">
              <div className="title">Maintaining</div>
              <div className="subtitle">5,239 PRs merged</div>
            </div>
            <div className="reputation">123,123 rep</div>
          </div>
          <div className="category">
            <GraphicalIcon icon="concepts" hex />
            <div className="info">
              <div className="title">Building</div>
              <div className="subtitle">5,239 PRs created</div>
            </div>
            <div className="reputation">13,456 rep</div>
          </div>

          {/* This is the link to the contributions tab */}
          <ProminentLink link="#" text="See erikschierboom’s contributions" />
        </div>

        <div className="chart-container">
          {currentTrack.categories.map((category, i) => {
            return (
              <CategoryLabel
                key={category.id}
                ref={labelRefs.current[i]}
                category={category}
              />
            )
          })}
          <div className="chart">
            <canvas id="contributions-chart" ref={setCanvas} />
          </div>
        </div>
      </div>
    </section>
  )
}

const CategoryLabel = forwardRef<HTMLDivElement, { category: Category }>(
  ({ category }, ref) => {
    return (
      <div className="label" ref={ref}>
        <GraphicalIcon icon={CATEGORY_ICONS[category.id]} hex />
        <div className="title">{CATEGORY_TITLES[category.id]}</div>
        {category.metric ? (
          <div className="subtitle">{category.metric}</div>
        ) : null}
      </div>
    )
  }
)
CategoryLabel.displayName = 'CategoryLabel'
