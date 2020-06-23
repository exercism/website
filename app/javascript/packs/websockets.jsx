import React, { useState, useEffect } from "react";
import ReactDOM from "react-dom";
import actionCable from "actioncable";

import consumer from "../channels/consumer";

function IterationSummary({ id }) {
  const [time, setTime] = useState(0);

  useEffect(() => {
    const received = data => setTime(data.time);

    const subscription = consumer.subscriptions.create(
      { channel: "IterationChannel", iteration_id: id },
      {
        received
      }
    );
    return () => subscription.unsubscribe();
  }, [id]);

  return (
    <div>
      {id}: {time}
    </div>
  );
}

document.addEventListener("turbolinks:load", () => {
  document.querySelectorAll("[data-react-iteration-summary]").forEach(elem => {
    const reactDataId = elem.dataset.reactDataId;
    ReactDOM.render(<IterationSummary id={reactDataId} />, elem);
  });
});

//  ReactDOM.unmountComponentAtNode(domContainerNode)
