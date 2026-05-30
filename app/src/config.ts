export interface Config {
  port: number;
  env: string;
  // Which store backend to use. Phase 1 = memory. Later phases add "dynamodb" | "aurora".
  storeBackend: "memory";
  // Surfaced on the UI + /healthz so we can SEE which task/version answered a request
  // (useful when watching rolling deploys and autoscaling spread traffic across tasks).
  instanceId: string;
  version: string;
}

export function loadConfig(): Config {
  return {
    port: Number(process.env.PORT ?? 3000),
    env: process.env.NODE_ENV ?? "development",
    storeBackend: "memory",
    instanceId: process.env.INSTANCE_ID ?? process.env.HOSTNAME ?? "local",
    version: process.env.APP_VERSION ?? "dev",
  };
}
