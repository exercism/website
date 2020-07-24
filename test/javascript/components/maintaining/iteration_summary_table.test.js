// Deps
import React from "react";

// Test deps
import { render } from "@testing-library/react";
import "@testing-library/jest-dom/extend-expect";

// Component
import { MaintainingIterationsSummaryTable } from "../../../../app/javascript/components/maintaining/iterations_summary_table.jsx";

test("renders component", () => {
  const { container, getByText } = render(
    <MaintainingIterationsSummaryTable
      iterations={[{ id: 1, testsStatus: "passed", representationStatus: "pending", "analysisStatus": "approved" }]}
    />
  );

  expect(getByText("passed")).toBeInTheDocument();
  expect(getByText("pending")).toBeInTheDocument();
  expect(getByText("approved")).toBeInTheDocument();
});
