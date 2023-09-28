module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:jest/recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:@typescript-eslint/eslint-recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:testing-library/react',
    'prettier',
    'prettier/@typescript-eslint',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 12,
    sourceType: 'module',
  },
  plugins: ['jest', 'react', '@typescript-eslint', 'testing-library'],
  rules: {},
  settings: {
    react: {
      version: 'detect',
    },
  },
  ignorePatterns: ['**/*.config.js', '.eslintrc.js'],
  overrides: [
    {
      files: ['*.ts', '*.tsx'],
      rules: {
        'react/prop-types': 'off',
        'no-console': ['warn'],
        'react/display-name': 'off',
      },
    },
    {
      files: ['*.test.ts', '*.test.tsx'],
      rules: {
        '@typescript-eslint/no-empty-function': 'off',
        '@typescript-eslint/no-unused-vars': 'off',
        'testing-library/no-node-access': [
          'error',
          { allowContainerFirstChild: true },
        ],
      },
    },
    {
      files: ['*.test.tsx'],
      rules: {
        'jest/expect-expect': 'off', // testing-library's getBy___ queries are in themselves assertions
      },
    },
  ],
}
