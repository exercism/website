// Deps
import React from "react";

// Test deps
import { render } from "@testing-library/react";
import "@testing-library/jest-dom/extend-expect";

// Component
import { ExampleIterationsSummaryTable } from "../../../../app/javascript/components/example/iterations_summary_table.jsx";

test("renders component", () => {
  const { container, getByText } = render(
    <ExampleIterationsSummaryTable
      solutionId={1}
      iterations={[{ id: 1, testsStatus: "passed" }]}
    />
  );

  expect(getByText("1: passed")).toBeInTheDocument();
});
