import React from "react";
import ReactDOM from "react-dom";

import { IterationsSummaryTable } from '../components/iteration_summary.jsx'

document.addEventListener("turbolinks:load", () => {
  document.querySelectorAll("[data-react-iterations-summary-table]").forEach(elem => {
    const reactDataSolutionId = elem.dataset.reactDataSolutionId;
    const reactDataIterations = JSON.parse(elem.dataset.reactDataIterations);
    ReactDOM.render(<IterationsSummaryTable solutionId={reactDataSolutionId} iterations={reactDataIterations} />, elem);

    const unloadOnce = () => {
      ReactDOM.unmountComponentAtNode(elem);
      document.removeEventListener("turbolinks:before-render", unloadOnce);
    };
  });
});
