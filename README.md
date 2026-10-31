# Containerise a web app (AkOps Labs build project)

A small Node.js service lives in `app/`. Package it into a **small, secure Docker image** that a team could run in production.

**Level:** Beginner to Intermediate · **Time:** about 1 hour · **Skills:** Dockerfile, image size, non-root containers, health checks, GitHub Actions

## How this works

1. This is your own copy of the project: made with **Use this template** on GitHub, or pushed from the AkOps Labs browser terminal.
2. Work in **GitHub Codespaces** (Docker is already installed there) or on your own machine with Docker.
3. Every push runs the **AkOps check**. When it is green, your project is done.
4. Go back to your project page on AkOps Labs, paste your repository link and press **Check my project**. Then share your badge on LinkedIn.

> Don't edit `.github/workflows/akops-check.yml`, `tests/` or `app/`.

## Your task

Create a `Dockerfile` and a `.dockerignore` in the root of the repository.

| Requirement | Why it matters |
|---|---|
| Base image `node:20-alpine` (or a newer Node, alpine or slim) | Small images pull faster and have fewer vulnerabilities |
| Copy only the app (`app/`) into the image | Keep secrets, `.git` and docs out of the image |
| `EXPOSE 3000` and start with `node server.js` | The app listens on port 3000 |
| Run as a **non-root** user (`USER node` exists in the Node images) | A break-in gets fewer powers |
| A `HEALTHCHECK` that calls `/health` | Docker and orchestrators know when the app is really up |
| Final image under **250 MB** | |

Hints: Alpine images have `wget` but not `curl`. `.dockerignore` works like `.gitignore`.

## Run the check yourself

```bash
docker build -t myapp .
docker run -d -p 3000:3000 --name myapp myapp
curl localhost:3000/health
bash tests/check.sh        # the same check GitHub runs
```

## Push and finish

```bash
git add Dockerfile .dockerignore
git commit -m "Containerise the app"
git push
```

When **AkOps check** is green in the Actions tab, submit your repository link on AkOps Labs.

## Ideas for your LinkedIn post

- Your final image size, and what you did to keep it small
- Why containers shouldn't run as root
- What a HEALTHCHECK gives you that "the process is running" doesn't
