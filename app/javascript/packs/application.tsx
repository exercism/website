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
import '../../css/components/combo-button'
import '../../css/components/exercise-header'
import '../../css/components/flash'
import '../../css/components/icon'
import '../../css/components/iteration-summary'
import '../../css/components/accordion-section'

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
import '../../css/components/radio'
import '../../css/components/checkbox'
import '../../css/components/select'
import '../../css/components/tooltips/concept'
import '../../css/components/tooltips/user'
import '../../css/components/user_activity'
import '../../css/components/search-bar'
import '../../css/components/published-solution'

import '../../css/components/mentor/nav'
import '../../css/components/mentor/inbox'
import '../../css/components/mentor/solution-row'
import '../../css/components/mentor/discussion'

import '../../css/components/track/generic-nav'
import '../../css/components/track/top-level-nav'
import '../../css/components/track/concept-nav'
import '../../css/components/track/concept-map'
import '../../css/components/iteration-pane'
import '../../css/components/explainer'
import '../../css/components/markdown-editor'
import '../../css/components/mentor-discussion-summary'
import '../../css/components/tag'

import '../../css/components/widgets/exercise'

import '../../css/modals/completed-exercise'
import '../../css/modals/publish-exercise'
import '../../css/modals/mentoring-sessions'
import '../../css/modals/finish-mentor-discussion'
import '../../css/modals/welcome-to-v3'
import '../../css/modals/become-mentor'

import '../../css/dropdowns/notifications'
import '../../css/dropdowns/reputation'
import '../../css/dropdowns/mentoring'

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
import '../../css/pages/track-index'
import '../../css/pages/track-show-joined'
import '../../css/pages/track-show-unjoined'
import '../../css/pages/mentoring/external'
import '../../css/pages/mentoring/dashboard'
import '../../css/pages/mentoring/testimonials'
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
import { Links as TryMentoringButtonLinks } from '../components/mentoring/TryMentoringButton'
import { Track as MentoringQueueTrack } from '../components/mentoring/queue/TrackFilterList'
import { Exercise as MentoringQueueExercise } from '../components/mentoring/queue/ExerciseFilterList'
import * as Student from '../components/student'
import { SolutionSummaryLinks } from '../components/student/SolutionSummary'
import * as Track from '../components/track'
import * as Journey from '../components/journey'
import { Editor } from '../components/Editor'
import { ConceptMap } from '../components/concept-map/ConceptMap'
import { IConceptMap } from '../components/concept-map/concept-map-types'
import { camelizeKeys } from 'humps'
import { Iteration } from '../components/types'
import { Assignment, Submission } from '../components/editor/types'
import {
  Iteration as MentoringSessionIteration,
  Student as MentoringSessionStudent,
  Track as MentoringSessionTrack,
  Exercise as MentoringSessionExercise,
  Links as MentoringSessionLinks,
  MentorSolution as MentoringSessionMentorSolution,
  Discussion as MentoringSessionDiscussion,
  StudentMentorRelationship,
  MentoringRequest,
} from '../components/mentoring/Session'
import { Mentor as StudentMentoringSessionMentor } from '../components/student/MentoringSession'
import * as Tooltips from '../components/tooltips'
import * as Dropdowns from '../components/dropdowns'

function camelizeKeysAs<T>(object: any): T {
  return (camelizeKeys(object) as unknown) as T
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  'maintaining-submissions-summary-table': (data: any) => (
    <Maintaining.SubmissionsSummaryTable
      submissions={data.submissions.map((s: any) => {
        return camelizeKeys(s)
      })}
    />
  ),
  'journey-solutions-list': (data: any) => (
    <Journey.SolutionsList endpoint={data.endpoint} />
  ),
  'journey-contributions-list': (data: any) => (
    <Journey.ContributionsList endpoint={data.endpoint} />
  ),
  'common-markdown-editor': (data: any) => (
    <Common.MarkdownEditor contextId={data.context_id} />
  ),
  'common-modal': (data: any) => <Common.Modal html={data.html} />,
  'mentoring-inbox': (data: any) => (
    <Mentoring.Inbox
      discussionsRequest={data.discussions_request}
      tracksRequest={data.tracks_request}
      sortOptions={data.sort_options}
    />
  ),
  'mentoring-queue': (data: any) => (
    <Mentoring.Queue
      request={camelizeKeys(data.request)}
      sortOptions={data.sort_options}
      tracks={camelizeKeysAs<MentoringQueueTrack[]>(data.tracks)}
      exercises={camelizeKeysAs<MentoringQueueExercise[]>(data.exercises)}
    />
  ),
  'mentoring-session': (data: any) => (
    <Mentoring.Session
      userId={data.user_id}
      discussion={camelizeKeysAs<MentoringSessionDiscussion>(data.discussion)}
      mentorSolution={camelizeKeysAs<MentoringSessionMentorSolution>(
        data.mentor_solution
      )}
      student={camelizeKeysAs<MentoringSessionStudent>(data.student)}
      track={camelizeKeysAs<MentoringSessionTrack>(data.track)}
      exercise={camelizeKeysAs<MentoringSessionExercise>(data.exercise)}
      iterations={camelizeKeysAs<MentoringSessionIteration[]>(data.iterations)}
      links={camelizeKeysAs<MentoringSessionLinks>(data.links)}
      request={camelizeKeysAs<MentoringRequest>(data.request)}
      relationship={camelizeKeysAs<StudentMentorRelationship>(
        data.relationship
      )}
      notes={data.notes}
    />
  ),
  'mentoring-try-mentoring-button': (data: any) => (
    <Mentoring.TryMentoringButton
      links={camelizeKeysAs<TryMentoringButtonLinks>(data.links)}
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
  'student-solution-summary': (data: any) => (
    <Student.SolutionSummary
      iteration={camelizeKeysAs<Iteration>(data.iteration)}
      links={camelizeKeysAs<SolutionSummaryLinks>(data.links)}
      isPracticeExercise={data.is_practice_exercise}
    />
  ),
  'student-mentoring-session': (data: any) => (
    <Student.MentoringSession
      id={data.id}
      isFinished={data.is_finished}
      mentor={camelizeKeysAs<StudentMentoringSessionMentor>(data.mentor)}
      iterations={camelizeKeysAs<MentoringSessionIteration[]>(data.iterations)}
      track={camelizeKeysAs<MentoringSessionTrack>(data.track)}
      exercise={camelizeKeysAs<MentoringSessionExercise>(data.exercise)}
      links={data.links}
      userId={data.user_id}
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
      className={data.class_name}
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
      assignment={camelizeKeysAs<Assignment>(data.assignment)}
      exampleFiles={data.example_files}
      storageKey={data.storage_key}
      debuggingInstructions={data.debugging_instructions}
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
  'dropdowns-dropdown': (data: any) => (
    <Dropdowns.Dropdown
      menuButton={data.menu_button}
      menuItems={data.menu_items}
    />
  ),
  'dropdowns-notifications': (data: any) => (
    <Dropdowns.Notifications endpoint={data.endpoint} />
  ),
  'dropdowns-reputation': (data: any) => (
    <Dropdowns.Reputation
      endpoint={data.endpoint}
      defaultIsSeen={data.is_seen}
      defaultReputation={data.reputation}
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
