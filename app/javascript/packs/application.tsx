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
import '../../css/application'
import '../../css/layout'

import '../../css/components/badge'
import '../../css/components/bg-img'
import '../../css/components/concept'
import '../../css/components/concept-icon'
import '../../css/components/concept-progress-bar'
import '../../css/components/copy-text-to-clipboard'
import '../../css/components/details'
import '../../css/components/flash'
import '../../css/components/icon'
import '../../css/components/iteration-summary'

import '../../css/components/heading-with-count'
import '../../css/components/notification'
import '../../css/components/prominent-link'
import '../../css/components/reputation'
import '../../css/components/primary-reputation'
import '../../css/components/site-header'
import '../../css/components/tab'
import '../../css/components/textual-content'
import '../../css/components/tracks-list'
import '../../css/components/pagination'
import '../../css/components/modal'
import '../../css/components/radio-button'
import '../../css/components/checkbox'
import '../../css/components/select'
import '../../css/components/tooltips/concept'
import '../../css/components/tooltips/user'
import '../../css/components/user_activity'
import '../../css/components/search-bar'
import '../../css/components/published-solution'

import '../../css/components/mentor/nav'
import '../../css/components/mentor/inbox'
import '../../css/components/mentor/queue'
import '../../css/components/mentor/solution-row'
import '../../css/components/mentor/discussion'

import '../../css/components/track/generic-nav'
import '../../css/components/track/top-level-nav'
import '../../css/components/track/concept-nav'
import '../../css/components/track/exercise-nav'
import '../../css/components/track/icon'
import '../../css/components/track/concept-map'
import '../../css/components/iteration-pane'

import '../../css/components/widgets/exercise'

import '../../css/modals/completed-exercise'
import '../../css/modals/publish-exercise'
import '../../css/modals/mentoring-sessions'
import '../../css/modals/welcome-to-v3'

import '../../css/pages/auth'
import '../../css/pages/dashboard'
import '../../css/pages/editor'
import '../../css/pages/onboarding'
import '../../css/pages/profile'
import '../../css/pages/staging' // TODO: Remove for launch
import '../../css/pages/track-shared-index'
import '../../css/pages/concepts-index'
import '../../css/pages/concept-show'
import '../../css/pages/exercise-show'
import '../../css/pages/exercises-index'
import '../../css/pages/iterations-index'
import '../../css/pages/track-show-joined'
import '../../css/pages/track-show-unjoined'
import '../../css/pages/mentor/dashboard'
import '../../css/pages/mentor/testimonials'
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
import * as Journey from '../components/journey'
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
import * as Dropdowns from '../components/dropdowns'

function camelizeKeysAs<T>(object: any): T {
  return (camelizeKeys(object) as unknown) as T
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  'maintaining-submissions-summary-table': (data: any) => (
    <Maintaining.SubmissionsSummaryTable submissions={data.submissions} />
  ),
  'journey-solutions-list': (data: any) => (
    <Journey.SolutionsList endpoint={data.endpoint} />
  ),
  'journey-contributions-list': (data: any) => (
    <Journey.ContributionsList endpoint={data.endpoint} />
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
      userId={data.user_id}
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
  'student-complete-exercise-button': (data: any) => (
    <Student.CompleteExerciseButton endpoint={data.endpoint} />
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
  'dropdowns-prerendered-dropdown': (data: any) => (
    <Dropdowns.PrerenderedDropdown
      menuButton={data.menu_button}
      menuItems={data.menu_items}
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

import { highlightAll } from '../utils/highlight'

document.addEventListener('turbolinks:load', () => {
  highlightAll()
})

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.

const images = require.context('../images', true)
const imagePath = (name: any) => images(name)
