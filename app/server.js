// A tiny web service. You don't need to change it: your job is to containerise it.
const http = require("node:http");

const port = Number(process.env.PORT || 3000);
const started = new Date().toISOString();

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "content-type": "application/json" });
    return res.end(JSON.stringify({ status: "ok", started }));
  }
  res.writeHead(200, { "content-type": "text/plain" });
  res.end(`Hello from ${process.env.APP_NAME || "akops-app"} running as uid ${process.getuid()}\n`);
});

server.listen(port, () => console.log(`listening on :${port}`));
process.on("SIGTERM", () => server.close(() => process.exit(0)));
