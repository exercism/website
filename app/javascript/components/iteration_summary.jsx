import React, { useState, useEffect } from "react";
import actionCable from "actioncable";

import consumer from "../application/action_cable_consumer";

function IterationSummary({ id, testsStatus }) {
  return (
    <div>
      {id}: {testsStatus}
    </div>
  );
}

export function IterationsSummaryTable({ solutionId, iterations }) {
  const [stateIterations, setIterations] = useState(iterations);

  useEffect(() => {
    const received = data => setIterations(data.iterations);

    const subscription = consumer.subscriptions.create(
      { channel: "IterationsChannel", solution_id: solutionId },
      {
        received
      }
    );
    //console.log(subscription.consumer)
    return () => subscription.unsubscribe();
  }, [solutionId]);

  return stateIterations.map((iteration, idx) => {
    return (
      <IterationSummary
        key={iteration.id}
        id={iteration.id}
        testsStatus={iteration.testsStatus}
        idx={idx}
      />
    );
  });
}
