# n8n behind an existing proxy

This workflow launches a single n8n container that expects to
be served behind an upstream proxy (e.g. the Parallel Works ACTIVATE platform)
and therefore forces every generated URL to include a custom base path.

## How it works

Key environment variables in `docker-compose.yml`:

* `N8N_HOST`, `N8N_PROTOCOL`, and `N8N_PORT` describe how users reach the proxy.
* `N8N_PATH` is the URL prefix that will be injected into every link and static
  asset that n8n generates. Change this to match your proxy route.
* `N8N_EDITOR_BASE_URL` must match the full externally visible editor URL
  (`protocol://host/base-path`).
* `WEBHOOK_URL` tells n8n how to construct webhook callback URLs when workflows
  are activated.

The default values assume you want n8n reachable at:

```
https://activate.parallel.works/me/session/Matthew.Shaxted/n8n
```

## Running the stack

From this directory:

```bash
docker compose up -d
```

If your proxy terminates TLS and forwards traffic to the container over HTTP,
update the `N8N_PROTOCOL` to `http` and adjust the exposed port or network
attachment as needed.
