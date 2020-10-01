import React, { useState, useEffect, Fragment } from "react";
import "actioncable";

import consumer from "../../utils/action-cable-consumer";

type Iteration = {
  id: string;
  testsStatus: unknown;
};

function IterationSummary({
  id,
  testsStatus,
  idx,
}: Iteration & { idx: number }) {
  return (
    <div>
      {id}: {testsStatus}
    </div>
  );
}

export function IterationsSummaryTable({
  solutionId,
  iterations,
}: {
  solutionId: string;
  iterations: readonly Iteration[];
}) {
  const [stateIterations, setIterations] = useState(iterations);

  useEffect(() => {
    const received = (data: { iterations: readonly Iteration[] }) =>
      setIterations(data.iterations);

    const subscription = consumer.subscriptions.create(
      { channel: "IterationsChannel", solution_id: solutionId },
      {
        received,
      }
    );
    return () => subscription.unsubscribe();
  }, [solutionId]);

  return (
    <Fragment>
      {stateIterations.map((iteration, idx) => {
        return (
          <IterationSummary
            key={iteration.id}
            id={iteration.id}
            testsStatus={iteration.testsStatus}
            idx={idx}
          />
        );
      })}
    </Fragment>
  );
}
