import { Hono } from "hono";

const app = new Hono();
app.get("/", (c) => c.text("hello"));
app.get("/json", (c) => c.json({ message: "hello" }));

console.log("ready");
process.exit(0);
