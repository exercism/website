// Deps
import React from "react";

// Test deps
import { render } from "@testing-library/react";
import "@testing-library/jest-dom/extend-expect";

// Component
import { TestIterationsSummaryTable } from "../../../app/javascript/components/test_iterations_summary_table.jsx";

test("renders component", () => {
  const { container, getByText } = render(
    <TestIterationsSummaryTable
      solutionId={1}
      iterations={[{ id: 1, testsStatus: "passed" }]}
    />
  );

  expect(getByText("1: passed")).toBeInTheDocument();
});
