// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
require("channels");

import "css/application.css";
import "css/styles.css";
import "css/layout.css";
import "css/components/track.css";

import * as React from "react";
import { initReact } from "./react-bootloader";
import * as Example from "../components/example";
import * as Maintaining from "../components/maintaining";
import * as Notifications from "../components/notifications";
import * as Mentoring from "../components/mentoring";

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  "example-iterations-summary-table": (data: any) => (
    <Example.IterationsSummaryTable
      solutionId={data.solution_id}
      iterations={data.iterations}
    />
  ),
  "maintaining-iterations-summary-table": (data: any) => (
    <Maintaining.IterationsSummaryTable iterations={data.iterations} />
  ),
  "notifications-icon": (data: any) => (
    <Notifications.Icon count={data.count} />
  ),
  "mentoring-inbox": (data: any) => (
    <Mentoring.Inbox
      conversationsRequest={data.conversations_request}
      tracksRequest={data.tracks_request}
      sortOptions={data.sort_options}
    />
  ),
  "mentoring-queue": (data: any) => (
    <Mentoring.Queue request={data.request} sortOptions={data.sort_options} />
  ),
});

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
