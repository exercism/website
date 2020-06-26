// Deps
import React from "react";

// Test deps
import { render } from "@testing-library/react";
import "@testing-library/jest-dom/extend-expect";
import { WebSocket as MockWebSocket, Server as MockServer } from "mock-socket";
//import { Server } from 'mock-socket';

// Component
import { IterationsSummaryTable } from "../../app/javascript/components/iteration_summary.jsx";

test("renders component", () => {
  const { container, getByText } = render(
    <IterationsSummaryTable
      solutionId={1}
      iterations={[{ id: 1, time: 123 }]}
    />
  );
  expect(getByText("1: 123")).toBeInTheDocument();
});

test("updates from websocket", () => {
  const mockServer = new MockServer("ws://localhost:3334/cable");
  mockServer.on("connection", socket => {
    console.log("HERE")
    socket.on("message", data => {
      t.is(
        data,
        "test message from app",
        "we have intercepted the message and can assert on it"
      );
      socket.send("test message from mock server");
    });
  });

  const { container, getByText } = render(
    <IterationsSummaryTable
      solutionId={1}
      iterations={[{ id: 1, time: 123 }]}
    />
  );

  mockServer.emit('1', JSON.stringify({ foo: "bar" }));
  //expect(getByText('1: 456')).toBeInTheDocument()
});
