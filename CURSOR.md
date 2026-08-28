# Cursor custom model setup for RunPod endpoint

Use these exact values after the endpoint worker shows **ready** (first cold start downloads ~15GB model, can take 5–10 min).

## Endpoint details

| Setting | Value |
|---------|-------|
| **Endpoint name** | `qwen-coder-7b-cursor` |
| **Endpoint ID** | `sgn1zcp2l3oe8d` |
| **Model** | `huihui-ai/Qwen2.5-Coder-7B-Instruct-abliterated` |
| **GPU pool** | AMPERE_24 (RTX A5000 class, ~$0.69/hr serverless) |
| **Scale** | 0–1 workers (pay only when running) |

## Cursor Settings → Models

1. **OpenAI API Key** → toggle **ON**
   - Paste your RunPod API key from [console.runpod.io/user/settings](https://www.console.runpod.io/user/settings)

2. **Override OpenAI Base URL** → set to:
   ```
   https://api.runpod.ai/v2/sgn1zcp2l3oe8d/openai/v1
   ```

3. **Add custom model** → click **+ Add Model**, enter:
   ```
   qwen2.5-coder-7b-abliterated
   ```
   (Must match `OPENAI_SERVED_MODEL_NAME_OVERRIDE` on the endpoint.)

4. In Chat/Agent, select **only** `qwen2.5-coder-7b-abliterated` (not Composer/Grok).

## Verify before using Cursor

```bash
curl -s https://api.runpod.ai/v2/sgn1zcp2l3oe8d/openai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_RUNPOD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5-coder-7b-abliterated",
    "messages": [{"role": "user", "content": "Say hello in one line"}],
    "max_tokens": 50
  }'
```

First request may take several minutes while the worker cold-starts and downloads the model.

## Cost tips

- **workersMin: 0** — no GPU cost when idle; you pay per second while a worker runs.
- **idleTimeout: 120s** — worker shuts down 2 min after last request.
- Each Cursor Agent message triggers inference; cold starts add latency.

## Upgrade to 32B later

Change `MODEL_NAME` env on the endpoint to `huihui-ai/Qwen2.5-Coder-32B-Instruct-abliterated`, switch GPU pool to `AMPERE_80` or `ADA_80_PRO`, and set `MAX_MODEL_LEN=8192`. Or redeploy from this repo after switching Dockerfile defaults back to 32B.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Empty/spinner forever | Worker still initializing — check RunPod console workers tab |
| Model not found | OpenAI key toggle OFF, or wrong model name in picker |
| 401 Unauthorized | Wrong RunPod API key |
| Agent tools fail | Endpoint has `ENABLE_AUTO_TOOL_CHOICE=true` — if issues persist, try **Ask mode** first |
