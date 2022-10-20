/** @type {import(\'ts-jest/dist/types\').InitialOptionsTsJest} */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testRegex: "(tests/.*|(\.|/)(test|spec))\.(ts|js)x?$",
  collectCoverage: true,
  coverageReporters: [
    "text-summary"
  ]
}
