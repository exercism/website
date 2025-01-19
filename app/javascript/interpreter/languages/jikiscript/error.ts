export type SyntaxErrorType =
  | 'UnknownCharacter'
  | 'MissingCommaAfterParameters'
  | 'MissingDoToStartBlock'
  | 'MissingEndAfterBlock'
  | 'MissingConditionAfterIf'
  | 'MissingDoubleQuoteToStartString'
  | 'MissingDoubleQuoteToTerminateString'
  | 'MissingFieldNameOrIndexAfterLeftBracket'
  | 'MissingRightParenthesisAfterExpression'
  | 'MissingRightBraceToTerminatePlaceholder'
  | 'MissingBacktickToTerminateTemplateLiteral'
  | 'MissingExpression'
  | 'InvalidAssignmentTarget'
  | 'ExceededMaximumNumberOfParameters'
  | 'MissingEndOfLine'
  | 'MissingFunctionName'
  | 'MissingLeftParenthesisAfterFunctionName'
  | 'MissingLeftParenthesisAfterFunctionCall'
  | 'MissingParameterName'
  | 'MissingRightParenthesisAfterParameters'
  | 'MissingLeftParenthesisAfterWhile'
  | 'MissingRightParenthesisAfterWhileCondition'
  | 'MissingWhileBeforeDoWhileCondition'
  | 'MissingLeftParenthesisAfterDoWhile'
  | 'MissingRightParenthesisAfterDoWhileCondition'
  | 'MissingVariableName'
  | 'InvalidNumericVariableName'
  | 'MissingConstantName'
  | 'MissingToAfterVariableNameToInitializeValue'
  | 'MissingToAfterVariableNameToChangeValue'
  | 'MissingLeftParenthesisBeforeIfCondition'
  | 'MissingRightParenthesisAfterIfCondition'
  | 'MissingDoToStartFunctionBody'
  | 'MissingDoToStartFunctionBody'
  | 'MissingDoToStartIfBody'
  | 'MissingDoToStartElseBody'
  | 'MissingDoAfterRepeatStatementCondition'
  | 'MissingDoAfterWhileStatementCondition'
  | 'MissingLeftParenthesisAfterForeach'
  | 'MissingLetInForeachCondition'
  | 'MissingElementNameAfterForeach'
  | 'MissingOfAfterElementNameInForeach'
  | 'MissingRightParenthesisAfterForeachElement'
  | 'MissingRightBracketAfterFieldNameOrIndex'
  | 'MissingRightParenthesisAfterFunctionCall'
  | 'MissingRightParenthesisAfterExpression'
  | 'MissingRightParenthesisAfterExpressionWithPotentialTypo'
  | 'MissingRightBracketAfterListElements'
  | 'MissingRightBraceAfterMapElements'
  | 'MissingWithBeforeParameters'
  | 'MissingStringAsKey'
  | 'MissingColonAfterKey'
  | 'MissingFieldNameOrIndexAfterOpeningBracket'
  | 'InvalidTemplateLiteral'
  | 'MissingColonAfterThenBranchOfTernaryOperator'
  | 'NumberEndsWithDecimalPoint'
  | 'NumberWithMultipleDecimalPoints'
  | 'NumberContainsAlpha'
  | 'NumberStartsWithZero'
  | 'UnexpectedElseWithoutIf'
  | 'UnexpectedLiteralExpressionAfterIf'
  | 'UnexpectedSpaceInIdentifier'
  | 'UnexpectedVariableExpressionAfterIf'
  | 'UnexpectedVariableExpressionAfterIfWithPotentialTypo'
  | 'DuplicateParameterName'
  | 'MissingTimesInRepeat'
  | 'UnexpectedEqualsForAssignment'
  | 'UnexpectedEqualsForEquality'
