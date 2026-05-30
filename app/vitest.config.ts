import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    include: ["tests/**/*.test.ts"],
    coverage: {
      provider: "v8",
      include: ["src/**/*.ts"],
      // server.ts is the process entrypoint (listen + signal wiring), exercised by
      // running the container, not by unit tests. types.ts is type-only (no runtime).
      exclude: ["src/server.ts", "src/store/types.ts"],
      thresholds: { statements: 100, branches: 100, functions: 100, lines: 100 },
    },
  },
});
