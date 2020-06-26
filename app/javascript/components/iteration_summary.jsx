import React, { useState, useEffect } from "react";
import actionCable from "actioncable";

import consumer from "../channels/consumer";

function IterationSummary({ id, time }) {
  return (
    <div>
      {id}: {time}
    </div>
  );
}

export function IterationsSummaryTable({ solutionId, iterations }) {
  const [stateIterations, setIterations] = useState(iterations);

  useEffect(() => {
    const received = data => {
      console.log(data);
      setIterations(data.iterations);
    }

    const subscription = consumer.subscriptions.create(
      { channel: "IterationsChannel", solution_id: solutionId },
      {
        received
      }
    );
    return () => subscription.unsubscribe();
  }, [solutionId]);

  return (
    stateIterations.map((iteration, idx) => {
      return (
        <IterationSummary 
          key={iteration.id} 
          id={iteration.id} 
          time={iteration.time} 
          idx={idx}
        />
      );
    })
  )
}
