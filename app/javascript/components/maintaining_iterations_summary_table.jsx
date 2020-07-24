import React, { useState, useEffect } from "react";
import "actioncable";

import consumer from "../application/action_cable_consumer";

function MaintainingIterationsSummaryTableRow({ id, testsStatus, representationStatus, analysisStatus }) {
  return (
    <tr>
      <th>{id}</th>
      <th>{testsStatus}</th>
      <th>{representationStatus}</th>
      <th>{analysisStatus}</th>
    </tr>
  );
}

export function MaintainingIterationsSummaryTable({ iterations }) {
  const [stateIterations, setIterations] = useState(iterations);

  useEffect(() => {
    const received = data => setIterations([data.iteration, ...stateIterations]);

    const subscription = consumer.subscriptions.create(
      { channel: "IterationChannel" }, { received }
    );
    return () => subscription.unsubscribe();
  });

  return (
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Test status</th>
          <th>Representation status</th>
          <th>Analyses status</th>
        </tr>
      </thead>
      <tbody>
        {stateIterations.map((iteration, idx) =>
          <MaintainingIterationsSummaryTableRow
            key={iteration.id}
            id={iteration.id}
            testsStatus={iteration.testsStatus}
            representationStatus={iteration.representationStatus}
            analysisStatus={iteration.analysisStatus}
            idx={idx}
          />)}
      </tbody>
    </table>
  );
}
