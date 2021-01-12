// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require('@rails/ujs').start()
require('turbolinks').start()
require('@rails/activestorage').start()
require('channels')

import 'focus-visible'

// TODO: Let's get all of these loading automatically
// without needing to be specified individually here.
import '../../css/application.css'
import '../../css/layout.css'

import '../../css/components/badge.css'
import '../../css/components/bg-img.css'
import '../../css/components/concept.css'
import '../../css/components/concept-icon.css'
import '../../css/components/concept-progress-bar.css'
import '../../css/components/copy-text-to-clipboard.css'
import '../../css/components/details.css'
import '../../css/components/flash.css'
import '../../css/components/icon.css'
import '../../css/components/iteration-summary.css'

import '../../css/components/heading-with-count.css'
import '../../css/components/notification.css'
import '../../css/components/prominent-link'
import '../../css/components/reputation.css'
import '../../css/components/primary-reputation.css'
import '../../css/components/site-header.css'
import '../../css/components/tab.css'
import '../../css/components/textual-content.css'
import '../../css/components/tracks-list.css'
import '../../css/components/pagination.css'
import '../../css/components/modal.css'
import '../../css/components/select.css'
import '../../css/components/tooltips/concept.css'
import '../../css/components/tooltips/user.css'
import '../../css/components/user_activity.css'
import '../../css/components/search-bar.css'

import '../../css/components/mentor/nav.css'
import '../../css/components/mentor/inbox.css'
import '../../css/components/mentor/queue.css'
import '../../css/components/mentor/solution-row.css'
import '../../css/components/mentor/sorter.css'
import '../../css/components/mentor/text-filter.css'
import '../../css/components/mentor/discussion.css'

import '../../css/components/track/generic-nav.css'
import '../../css/components/track/top-level-nav.css'
import '../../css/components/track/concept-nav.css'
import '../../css/components/track/exercise-nav.css'
import '../../css/components/track/icon.css'
import '../../css/components/track/concept-map.css'

import '../../css/components/widgets/exercise.css'

import '../../css/pages/auth.css'
import '../../css/pages/dashboard.css'
import '../../css/pages/editor.css'
import '../../css/pages/profile.css'
import '../../css/pages/staging.css' // TODO: Remove for launch
import '../../css/pages/track-shared-index.css'
import '../../css/pages/concepts-index.css'
import '../../css/pages/concept-show.css'
import '../../css/pages/exercise-show.css'
import '../../css/pages/exercises-index.css'
import '../../css/pages/iterations-index.css'
import '../../css/pages/track-show-joined.css'
import '../../css/pages/track-show-unjoined.css'
import '../../css/pages/mentor/dashboard'
import '../../css/pages/maintaining/dashboard'
import '../../css/pages/maintaining/track'
import '../../css/pages/journey'

import 'easymde/dist/easymde.min.css'
import '../../css/highlighters/highlightjs-light'

import React from 'react'
import { initReact } from './react-bootloader.jsx'
import * as Common from '../components/common'
import * as Maintaining from '../components/maintaining'
import * as Mentoring from '../components/mentoring'
import * as Student from '../components/student'
import * as Track from '../components/track'
import { Editor } from '../components/Editor'
import { ConceptMap } from '../components/concept-map/ConceptMap'
import { IConceptMap } from '../components/concept-map/concept-map-types'
import { camelizeKeys } from 'humps'
import { Iteration } from '../components/track/IterationSummary'
import { ExerciseInstructions, Submission } from '../components/editor/types'
import {
  Iteration as MentorDiscussionIteration,
  Student as MentorDiscussionStudent,
  Track as MentorDiscussionTrack,
  Exercise as MentorDiscussionExercise,
  Links as MentorDiscussionLinks,
} from '../components/mentoring/Discussion'
import * as Tooltips from '../components/tooltips'

function camelizeKeysAs<T>(object: any): T {
  return (camelizeKeys(object) as unknown) as T
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  'maintaining-submissions-summary-table': (data: any) => (
    <Maintaining.SubmissionsSummaryTable submissions={data.submissions} />
  ),
  'common-notifications-icon': (data: any) => (
    <Common.NotificationsIcon count={data.count} />
  ),
  'common-markdown-editor': (data: any) => (
    <Common.MarkdownEditor contextId={data.context_id} />
  ),
  'mentoring-inbox': (data: any) => (
    <Mentoring.Inbox
      conversationsRequest={data.conversations_request}
      tracksRequest={data.tracks_request}
      sortOptions={data.sort_options}
    />
  ),
  'mentoring-queue': (data: any) => (
    <Mentoring.Queue request={data.request} sortOptions={data.sort_options} />
  ),
  'mentoring-discussion': (data: any) => (
    <Mentoring.Discussion
      discussionId={data.discussion_id}
      student={camelizeKeysAs<MentorDiscussionStudent>(data.student)}
      track={camelizeKeysAs<MentorDiscussionTrack>(data.track)}
      exercise={camelizeKeysAs<MentorDiscussionExercise>(data.exercise)}
      iterations={camelizeKeysAs<MentorDiscussionIteration[]>(data.iterations)}
      links={camelizeKeysAs<MentorDiscussionLinks>(data.links)}
    />
  ),
  'student-tracks-list': (data: any) => (
    <Student.TracksList
      request={data.request}
      statusOptions={data.status_options}
      tagOptions={data.tag_options}
    />
  ),
  'concept-map': (data: any) => {
    const mapData: IConceptMap = camelizeKeysAs<IConceptMap>(data.graph)
    return (
      <ConceptMap
        concepts={mapData.concepts}
        levels={mapData.levels}
        connections={mapData.connections}
        status={mapData.status}
        exerciseCounts={mapData.exerciseCounts}
      />
    )
  },
  'track-iteration-summary': (data: any) => (
    <Track.IterationSummary
      iteration={camelizeKeysAs<Iteration>(data.iteration)}
    />
  ),
  editor: (data: any) => (
    <Editor
      endpoint={data.endpoint}
      initialSubmission={camelizeKeysAs<Submission>(data.submission)}
      files={data.files}
      language={data.language}
      exercisePath={data.exercise_path}
      trackTitle={data.track_title}
      exerciseTitle={data.exercise_title}
      introduction={data.introduction}
      instructions={camelizeKeysAs<ExerciseInstructions>(data.instructions)}
      exampleSolution={data.example_solution}
      storageKey={data.storage_key}
    />
  ),
  'mentored-student-tooltip': (data: any) => (
    <Tooltips.MentoredStudent endpoint={data.endpoint} />
  ),
  'user-tooltip': (data: any, elem: HTMLElement) => (
    <Tooltips.UserTooltip
      contentEndpoint={data.endpoint}
      referenceElement={elem}
      referenceUserHandle={data.handle}
      hoverRequestToShow={true}
      focusRequestToShow={true}
    />
  ),
  'common-copy-to-clipboard-button': (data: any) => (
    <Common.CopyToClipboardButton textToCopy={data.text_to_copy} />
  ),
  'common-icon': (data: any) => <Common.Icon icon={data.icon} alt={data.alt} />,
  'common-graphical-icon': (data: any) => (
    <Common.GraphicalIcon icon={data.icon} />
  ),
})

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
//const images = require.context('../images', true)
//const imagePath = (name: any) => images(name)
