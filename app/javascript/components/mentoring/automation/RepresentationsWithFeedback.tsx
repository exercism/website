import React, { useCallback, useState } from 'react'
import { Pagination } from '../../common/Pagination'
import { TrackFilterList } from '../queue/TrackFilterList'
import { useTrackList } from '../queue/useTrackList'
import { Request } from '../../../hooks/request-query'
import { Links } from '../Queue'
import {
  AutomationStatus,
  MentoredTrack,
  MentoredTrackExercise,
} from '../../types'
import { useMentoringQueue } from '../queue/useMentoringQueue'
import { Sorter } from '../Sorter'
import { SortOption } from '../Inbox'
import { MOCK_DEFAULT_TRACK, MOCK_TRACKS, MOCK_LIST_ELEMENT } from './mock-data'
import { StatusTab } from '../inbox/StatusTab'
import { GraphicalIcon, Introducer } from '../../common'
import { AutomationListElement } from './AutomationListElement'
import SearchInput from '../../common/SearchInput'

const TRACKS_LIST_CACHE_KEY = 'mentored-tracks'

const resolvedData = true

const MOCK_LIST = new Array(24).fill(MOCK_LIST_ELEMENT)

type AutomationProps = {
  tracksRequest: Request
  links: Links
  // defaultTrack: MentoredTrack
  queueRequest: Request
  defaultExercise: MentoredTrackExercise | null
  sortOptions: SortOption[]
}

export function RepresentationsWithFeedback({
  tracksRequest,
  sortOptions,
  links,
  defaultExercise,
  queueRequest,
}: AutomationProps): JSX.Element {
  const [selectedTrack, setSelectedTrack] =
    useState<MentoredTrack>(MOCK_DEFAULT_TRACK)

  const [checked, setChecked] = useState(false)

  const [status, setStatus] = useState<AutomationStatus>('need_feedback')
  const [selectedExercise] = useState<MentoredTrackExercise | null>(
    defaultExercise
  )
  const [searchText, setSearchText] = useState('')

  const { setCriteria, order, setOrder, setPage } = useMentoringQueue({
    request: queueRequest,
    track: selectedTrack,
    exercise: selectedExercise,
  })

  const handleTrackChange = useCallback(
    (track) => {
      setPage(1)
      setCriteria('')
      setSelectedTrack(track)
    },
    [setPage, setCriteria]
  )

  const {
    // tracks,
    status: trackListStatus,
    error: trackListError,
    isFetching: isTrackListFetching,
  } = useTrackList({
    cacheKey: TRACKS_LIST_CACHE_KEY,
    request: tracksRequest,
  })

  return (
    <div className="c-mentor-inbox">
      <AutomationIntroducer />
      <div className="flex justify-between">
        <div className="tabs">
          <StatusTab<AutomationStatus>
            status="need_feedback"
            currentStatus={status}
            setStatus={() => setStatus('need_feedback')}
          >
            Need feedback
            {resolvedData ? <div className="count">{12}</div> : null}
          </StatusTab>
          <StatusTab<AutomationStatus>
            status="feedback_submitted"
            currentStatus={status}
            setStatus={() => setStatus('feedback_submitted')}
          >
            Feedback submitted
            {resolvedData ? <div className="count">{15}</div> : null}
          </StatusTab>
        </div>
        <Checkbox
          onCheck={() => setChecked((c) => !c)}
          text="Only show solutions I've mentored before"
          checked={checked}
        />
      </div>
      <div className="container">
        <header className="c-search-bar automation-header">
          <TrackFilterList
            countText={'requests'}
            status={trackListStatus}
            error={trackListError}
            tracks={MOCK_TRACKS}
            isFetching={isTrackListFetching}
            cacheKey={TRACKS_LIST_CACHE_KEY}
            links={links}
            value={selectedTrack}
            setValue={handleTrackChange}
            sizeVariant={'automation'}
          />

          <SearchInput
            onChange={(e) => setSearchText(e.target.value)}
            value={searchText}
            placeholder="Filter by exercise"
          />
          <Sorter
            componentClassName="ml-auto automation-sorter"
            sortOptions={sortOptions}
            order={order}
            setOrder={setOrder}
          />
        </header>
        <AutomationList />
        <footer>
          <Pagination
            setPage={() => console.log('page is set')}
            total={10}
            current={2}
          />
        </footer>
      </div>
    </div>
  )
}

type CheckboxProps = {
  checked: boolean
  onCheck: () => void
  text: string
}

function Checkbox({ text, checked, onCheck }: CheckboxProps): JSX.Element {
  return (
    <label className="c-checkbox-wrapper text-textColor6 filter mb-20">
      <input type="checkbox" checked={checked} onChange={onCheck} />
      <div className="row">
        <div className="c-checkbox">
          <GraphicalIcon icon="checkmark" />
        </div>
        {text}
      </div>
    </label>
  )
}

function AutomationIntroducer(): JSX.Element {
  return (
    <Introducer
      endpoint="some string"
      additionalClassNames="mb-24"
      icon="automation"
    >
      <h2>Initiate feedback automation...Beep boop bop...</h2>
      <p>
        Automation is a space that allows you to see common solutions to
        exercises and write feedback once for all students with that particular
        solution.
      </p>
    </Introducer>
  )
}

function AutomationList() {
  return (
    <>
      {MOCK_LIST.map((i, k) => {
        return <AutomationListElement representer={i} key={k} />
      })}
    </>
  )
}
