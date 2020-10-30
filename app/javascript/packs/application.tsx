// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require('@rails/ujs').start()
require('turbolinks').start()
require('@rails/activestorage').start()
require('channels')

// TODO: Let's get all of these loading automatically
// without needing to be specified individually here.
import '../../css/application.css'
import '../../css/layout.css'
import '../../css/site-header.css'

import '../../css/components/bg-img.css'
import '../../css/components/reputation.css'
import '../../css/components/tab.css'
import '../../css/components/textual-content.css'
import '../../css/components/tracks-list.css'
import '../../css/components/tracks-list.css'
import '../../css/components/track.css'
import '../../css/components/tooltips/tooltip.css'
import '../../css/components/tooltips/user-summary.css'

import '../../css/components/widgets/exercise.css'

import '../../css/components/track/generic-nav.css'
import '../../css/components/track/top-level-nav.css'
import '../../css/components/track/concept-nav.css'
import '../../css/components/track/exercise-nav.css'
import '../../css/components/track/icon.css'

import '../../css/pages/concept-show.css'
import '../../css/pages/exercise-show.css'
import '../../css/pages/exercises-index.css'
import '../../css/pages/iterations-index.css'
import '../../css/pages/track-show-joined.css'
import '../../css/pages/track-show-unjoined.css'

import 'components/concept-map/ConceptMap.css'

import React from 'react'
import { initReact } from './react-bootloader.jsx'
import * as Example from '../components/example'
import * as Maintaining from '../components/maintaining'
import * as Notifications from '../components/notifications'
import * as Mentoring from '../components/mentoring'
import * as Student from '../components/student'
import * as Track from '../components/track'
import { ConceptMap } from '../components/concept-map/ConceptMap'
import { camelizeKeys } from 'humps'
import { Iteration } from '../components/track/IterationSummary'
import { Submission, File } from '../components/student/Editor'
import * as Tooltips from '../components/tooltips'

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  'example-submissions-summary-table': (data: any) => (
    <Example.SubmissionsSummaryTable
      solutionId={data.solution_id}
      submissions={data.submissions}
    />
  ),
  'maintaining-submissions-summary-table': (data: any) => (
    <Maintaining.SubmissionsSummaryTable submissions={data.submissions} />
  ),
  'notifications-icon': (data: any) => (
    <Notifications.Icon count={data.count} />
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
  'student-tracks-list': (data: any) => (
    <Student.TracksList
      request={data.request}
      statusOptions={data.status_options}
      tagOptions={data.tag_options}
    />
  ),
  'concept-map': (data: any) => (
    <ConceptMap
      concepts={data.graph.concepts}
      levels={data.graph.levels}
      connections={data.graph.connections}
      status={data.graph.status}
    />
  ),
  'track-iteration-summary': (data: any) => (
    <Track.IterationSummary
      iteration={(camelizeKeys(data.iteration) as unknown) as Iteration}
    />
  ),
  'student-editor': (data: any) => (
    <Student.Editor
      endpoint={data.endpoint}
      initialSubmission={
        (camelizeKeys(data.submission) as unknown) as Submission
      }
      files={data.files}
    />
  ),
  'mentored-student-tooltip': (data: any) => (
    <Tooltips.MentoredStudent endpoint={data.endpoint} />
  ),
  'user-summary-tooltip': (data: any) => (
    <Tooltips.UserSummary endpoint={data.endpoint} />
  ),
})

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
//const images = require.context('../images', true)
//const imagePath = (name: any) => images(name)
