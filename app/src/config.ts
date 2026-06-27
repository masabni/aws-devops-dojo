export interface Config {
  port: number;
  env: string;
  // Which store backend to use. Phase 1 = memory. Later phases add "dynamodb" | "aurora".
  storeBackend: "memory";
  // Surfaced on the UI + /healthz so we can SEE which task/version answered a request
  // (useful when watching rolling deploys and autoscaling spread traffic across tasks).
  instanceId: string;
  version: string;
  // /loadtest deliberately burns CPU — handy for the autoscaling lab, but a DoS
  // foot-gun once the service is internet-facing. OFF by default; flip ENABLE_LOADTEST
  // on only when you're actively running a scaling test.
  enableLoadtest: boolean;
}

export function loadConfig(): Config {
  return {
    port: Number(process.env.PORT ?? 3000),
    env: process.env.NODE_ENV ?? "development",
    storeBackend: "memory",
    instanceId: process.env.INSTANCE_ID ?? process.env.HOSTNAME ?? "local",
    version: process.env.APP_VERSION ?? "dev",
    enableLoadtest: process.env.ENABLE_LOADTEST === "true",
  };
}
