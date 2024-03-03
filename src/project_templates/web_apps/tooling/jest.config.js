module.exports = {
  moduleNameMapper: {
    "\\.(css)$": "<rootDir>/src/tests/styleMock.ts",
    "\\.(scss)$": "<rootDir>/src/tests/styleMock.ts",
    "^@src/(.*)$": "<rootDir>/src/$1",
  },
  preset: "ts-jest",
  testEnvironment: "node",
  transform: {
    "\\.(ts|tsx)$": "ts-jest",
  },
};
