// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require('@rails/ujs').start()
require('turbolinks').start()
require('@rails/activestorage').start()
require('channels')

import 'css/application.css'

import React from 'react'
import { initReact } from './react_bootloader.jsx'
import { ExampleIterationsSummaryTable } from '../components/example/iterations_summary_table.jsx'
import { MaintainingIterationsSummaryTable } from '../components/maintaining/iterations_summary_table.jsx'
import { NotificationIcon } from '../components/notifications/icon.jsx'
import { MentorInbox } from '../components/mentoring/mentor_inbox.jsx'

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  'example-iterations-summary-table': (data) => (
    <ExampleIterationsSummaryTable
      solutionId={data.solution_id}
      iterations={data.iterations}
    />
  ),
  'maintaining-iterations-summary-table': (data) => (
    <MaintainingIterationsSummaryTable iterations={data.iterations} />
  ),
  'notification-icon': (data) => <NotificationIcon count={data.count} />,
  'mentor-inbox': (data) => (
    <MentorInbox
      conversationsRequest={data.conversations_request}
      tracksRequest={data.tracks_request}
    />
  ),
})

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
