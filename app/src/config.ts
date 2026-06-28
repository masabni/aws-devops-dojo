export interface Config {
  port: number;
  env: string;
  // Which store backend to use. Phase 1 = memory; Phase 5 adds "dynamodb".
  storeBackend: "memory" | "dynamodb";
  // DynamoDB table name (from TASKS_TABLE_NAME) — only used when storeBackend = "dynamodb".
  tableName: string;
  // AWS region for the SDK clients (Fargate also injects AWS_REGION at runtime).
  region: string;
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
    storeBackend: process.env.STORE_BACKEND === "dynamodb" ? "dynamodb" : "memory",
    tableName: process.env.TASKS_TABLE_NAME ?? "",
    region: process.env.AWS_REGION ?? "eu-central-1",
    instanceId: process.env.INSTANCE_ID ?? process.env.HOSTNAME ?? "local",
    version: process.env.APP_VERSION ?? "dev",
    enableLoadtest: process.env.ENABLE_LOADTEST === "true",
  };
}
