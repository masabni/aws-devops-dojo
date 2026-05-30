import { describe, it, expect, beforeEach } from "vitest";
import request from "supertest";
import { createApp } from "../src/app";
import { MemoryStore } from "../src/store/memoryStore";
import { loadConfig } from "../src/config";

function makeApp() {
  return createApp(loadConfig(), new MemoryStore());
}

describe("tasks API", () => {
  let app: ReturnType<typeof makeApp>;

  beforeEach(() => {
    app = makeApp();
  });

  it("starts with an empty list", async () => {
    const res = await request(app).get("/tasks");
    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
  });

  it("creates a task", async () => {
    const res = await request(app)
      .post("/tasks")
      .set("Accept", "application/json")
      .send({ title: "buy milk" });
    expect(res.status).toBe(201);
    expect(res.body.title).toBe("buy milk");
    expect(res.body.done).toBe(false);
    expect(res.body.id).toBeTruthy();
  });

  it("rejects an empty title", async () => {
    const res = await request(app)
      .post("/tasks")
      .set("Accept", "application/json")
      .send({ title: "   " });
    expect(res.status).toBe(400);
  });

  it("rejects a missing title field", async () => {
    const res = await request(app)
      .post("/tasks")
      .set("Accept", "application/json")
      .send({});
    expect(res.status).toBe(400);
  });

  it("toggles a task done/undone", async () => {
    const created = await request(app)
      .post("/tasks")
      .set("Accept", "application/json")
      .send({ title: "task" });
    const id = created.body.id;

    const toggled = await request(app)
      .post(`/tasks/${id}/toggle`)
      .set("Accept", "application/json");
    expect(toggled.status).toBe(200);
    expect(toggled.body.done).toBe(true);
  });

  it("returns 404 toggling a missing task", async () => {
    const res = await request(app)
      .post("/tasks/does-not-exist/toggle")
      .set("Accept", "application/json");
    expect(res.status).toBe(404);
  });

  it("returns 404 deleting a missing task", async () => {
    const res = await request(app)
      .post("/tasks/does-not-exist/delete")
      .set("Accept", "application/json");
    expect(res.status).toBe(404);
  });

  it("deletes a task", async () => {
    const created = await request(app)
      .post("/tasks")
      .set("Accept", "application/json")
      .send({ title: "delete me" });
    const id = created.body.id;

    const del = await request(app)
      .post(`/tasks/${id}/delete`)
      .set("Accept", "application/json");
    expect(del.status).toBe(204);

    const list = await request(app).get("/tasks");
    expect(list.body).toEqual([]);
  });

  it("serves the empty HTML page with Tailwind", async () => {
    const res = await request(app).get("/");
    expect(res.status).toBe(200);
    expect(res.text).toContain("Tasklet");
    expect(res.text).toContain("cdn.tailwindcss.com");
    expect(res.text).toContain("No tasks yet");
  });

  // The HTML <form> posts (Accept: text/html) take the redirect-back-to-"/" branch,
  // distinct from the JSON API branch above.
  describe("HTML form flow (redirects)", () => {
    it("redirects to / after creating via a form post", async () => {
      const res = await request(app)
        .post("/tasks")
        .set("Accept", "text/html")
        .type("form")
        .send({ title: "from form" });
      expect(res.status).toBe(302);
      expect(res.headers.location).toBe("/");
    });

    it("redirects to / after toggling via a form post", async () => {
      const created = await request(app)
        .post("/tasks")
        .set("Accept", "application/json")
        .send({ title: "t" });
      const res = await request(app)
        .post(`/tasks/${created.body.id}/toggle`)
        .set("Accept", "text/html");
      expect(res.status).toBe(302);
      expect(res.headers.location).toBe("/");
    });

    it("redirects to / after deleting via a form post", async () => {
      const created = await request(app)
        .post("/tasks")
        .set("Accept", "application/json")
        .send({ title: "t" });
      const res = await request(app)
        .post(`/tasks/${created.body.id}/delete`)
        .set("Accept", "text/html");
      expect(res.status).toBe(302);
      expect(res.headers.location).toBe("/");
    });

    it("renders a populated list with done + open tasks", async () => {
      const open = await request(app)
        .post("/tasks")
        .set("Accept", "application/json")
        .send({ title: "<open> task" });
      const done = await request(app)
        .post("/tasks")
        .set("Accept", "application/json")
        .send({ title: "done task" });
      await request(app)
        .post(`/tasks/${done.body.id}/toggle`)
        .set("Accept", "application/json");

      const page = await request(app).get("/");
      expect(page.text).toContain("done task");
      expect(page.text).toContain("line-through"); // the done branch
      expect(page.text).toContain("&lt;open&gt; task"); // HTML-escaped, not raw
      expect(page.text).not.toContain("No tasks yet");
      void open;
    });
  });
});
