import { defineConfig } from "@playwright/test";

const grepInvert: RegExp[] = [];

// https://playwright.dev/docs/test-configuration
export default defineConfig({
  globalTimeout: 600000,
  grepInvert,
  projects: [
    {
      name: "Desktop",
      use: {
        viewport: { height: 768, width: 1250 },
      },
    },
    {
      name: "Laptop",
      use: {
        viewport: { height: 768, width: 1026 },
      },
    },
    {
      name: "Tablet",
      use: {
        viewport: { height: 768, width: 780 },
      },
    },
    {
      name: "Mobile",
      use: {
        viewport: { height: 812, width: 375 },
      },
    },
  ],
  testDir: "./e2e",
  timeout: 30000,
  use: {
    baseURL: "http://localhost:3000",
    trace: "retain-on-failure",
  },
});
