import type { Task } from "../store/types";
import type { Config } from "../config";

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

// Phase 1 keeps the frontend deliberately simple: Tailwind via the Play CDN, no
// build pipeline. The focus of this project is the DevOps path, not frontend tooling.
// (A later phase can swap to a compiled stylesheet if we want a production-grade build.)
export function renderPage(tasks: Task[], cfg: Config): string {
  const rows = tasks
    .map(
      (t) => `
      <li class="flex items-center justify-between gap-3 rounded-lg border border-slate-200 bg-white px-4 py-3 shadow-sm">
        <form method="post" action="/tasks/${t.id}/toggle" class="flex items-center gap-3 flex-1">
          <button type="submit" aria-label="toggle" class="h-5 w-5 rounded border ${t.done ? "bg-emerald-500 border-emerald-500" : "border-slate-300"}"></button>
          <span class="${t.done ? "line-through text-slate-400" : "text-slate-800"}">${escapeHtml(t.title)}</span>
        </form>
        <form method="post" action="/tasks/${t.id}/delete">
          <button type="submit" class="text-slate-400 hover:text-rose-500 text-sm">delete</button>
        </form>
      </li>`,
    )
    .join("");

  const empty = `<li class="text-center text-slate-400 py-8">No tasks yet — add one above.</li>`;

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Tasklet</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100 text-slate-900">
  <main class="mx-auto max-w-xl px-4 py-12">
    <header class="mb-8 text-center">
      <h1 class="text-3xl font-bold tracking-tight">Tasklet</h1>
      <p class="mt-1 text-sm text-slate-500">aws-devops-dojo demo app</p>
    </header>

    <form method="post" action="/tasks" class="mb-6 flex gap-2">
      <input name="title" required placeholder="What needs doing?"
        class="flex-1 rounded-lg border border-slate-300 px-4 py-2 focus:border-indigo-500 focus:outline-none" />
      <button type="submit"
        class="rounded-lg bg-indigo-600 px-4 py-2 font-medium text-white hover:bg-indigo-700">Add</button>
    </form>

    <ul class="space-y-2">${tasks.length ? rows : empty}</ul>

    <footer class="mt-10 text-center text-xs text-slate-400">
      served by <code class="font-mono">${escapeHtml(cfg.instanceId)}</code>
      · version <code class="font-mono">${escapeHtml(cfg.version)}</code>
      · env <code class="font-mono">${escapeHtml(cfg.env)}</code>
    </footer>
  </main>
</body>
</html>`;
}
