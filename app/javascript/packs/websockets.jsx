import React from "react";
import ReactDOM from "react-dom";

import { IterationsSummaryTable } from "../components/iteration_summary.jsx";

const render = (elem, component) => {
  ReactDOM.render(component, elem);

  const unloadOnce = () => {
    ReactDOM.unmountComponentAtNode(elem);
    document.removeEventListener("turbolinks:before-render", unloadOnce);
  };
  document.addEventListener("turbolinks:before-render", unloadOnce);
};

document.addEventListener("turbolinks:load", () => {
  document
    .querySelectorAll("[data-react-iterations-summary-table]")
    .forEach(elem => {
      const data = JSON.parse(elem.dataset.reactData);
      const component = (
        <IterationsSummaryTable
          solutionId={data.solution_id}
          iterations={data.iterations}
        />
      );
      render(elem, component);
    });
});
