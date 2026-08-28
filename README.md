# Qwen2.5-Coder-32B-Instruct-abliterated — RunPod Serverless

Deploy [huihui-ai/Qwen2.5-Coder-32B-Instruct-abliterated](https://huggingface.co/huihui-ai/Qwen2.5-Coder-32B-Instruct-abliterated) on [RunPod Serverless](https://www.runpod.io/serverless) with an OpenAI-compatible vLLM endpoint.

Built on the official [RunPod vLLM worker](https://github.com/runpod-workers/worker-vllm) (`runpod/worker-v1-vllm:v2.26.0`).

## GPU requirements

| Setup | GPU | Notes |
|-------|-----|-------|
| **Recommended** | 1× A100 80GB | Full bf16, 32k context |
| **Minimum** | 1× A100 40GB | Lower `MAX_MODEL_LEN` to 8192–16384 |
| **Multi-GPU** | 2× A100 40GB | Set `TENSOR_PARALLEL_SIZE=2` |

The 32B model in bf16 needs substantial VRAM. Do **not** use 16 GB GPUs for the full-precision weights.

## Deploy from GitHub (RunPod Console)

1. **Connect GitHub** in RunPod: [Settings → Connections](https://www.console.runpod.io/user/settings)
2. Go to [Serverless → New Endpoint](https://www.console.runpod.io/serverless)
3. Choose **Deploy from a GitHub repository**
4. Select **`Carnage2109/runpod-qwen25-coder-abliterated`**
5. Configure:
   - **Branch:** `main`
   - **Dockerfile path:** `Dockerfile`
6. **Endpoint type:** Queue (standard serverless)
7. **GPU:** A100 40GB or A100 80GB (see table above)
8. **Environment variables** (optional overrides):

   | Variable | Default | Description |
   |----------|---------|-------------|
   | `MODEL_NAME` | `huihui-ai/Qwen2.5-Coder-32B-Instruct-abliterated` | HuggingFace model ID |
   | `MAX_MODEL_LEN` | `32768` | Max context length |
   | `GPU_MEMORY_UTILIZATION` | `0.95` | VRAM fraction for vLLM |
   | `DTYPE` | `bfloat16` | Weight dtype |
   | `ENABLE_AUTO_TOOL_CHOICE` | `true` | Tool/function calling |
   | `TOOL_CALL_PARSER` | `hermes` | Qwen2.5 tool parser |
   | `TENSOR_PARALLEL_SIZE` | `1` | Set to `2` for 2× GPU |
   | `HF_TOKEN` | — | HuggingFace token (if gated) |

9. Click **Deploy Endpoint** and wait for the build + first cold start (model download can take several minutes).

## Test the endpoint

### RunPod `/runsync` (queue endpoint)

```bash
export RUNPOD_API_KEY="your-runpod-api-key"
export ENDPOINT_ID="your-endpoint-id"

curl -X POST "https://api.runpod.ai/v2/${ENDPOINT_ID}/runsync" \
  -H "Authorization: Bearer ${RUNPOD_API_KEY}" \
  -H "Content-Type: application/json" \
  -d @test_input.json
```

### OpenAI-compatible route (via RunPod OpenAI proxy)

If your endpoint exposes the OpenAI route, point any OpenAI client at RunPod:

```python
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["RUNPOD_API_KEY"],
    base_url=f"https://api.runpod.ai/v2/{ENDPOINT_ID}/openai/v1",
)

response = client.chat.completions.create(
    model="qwen2.5-coder-32b-abliterated",
    messages=[
        {"role": "user", "content": "Write a quicksort in Python."}
    ],
    max_tokens=512,
)
print(response.choices[0].message.content)
```

### Use with Cursor (BYOK)

1. RunPod endpoint must be reachable over **HTTPS** (RunPod provides this)
2. Cursor → **Settings → Models**
3. Enable **OpenAI API Key** (use your RunPod API key or endpoint token)
4. Set **Override OpenAI Base URL** to your RunPod OpenAI proxy URL
5. Add model name: `qwen2.5-coder-32b-abliterated`

## Local build (optional)

```bash
docker build --platform linux/amd64 -t runpod-qwen25-coder-abliterated .
```

RunPod infrastructure requires `linux/amd64`.

## Model notes

- **Source:** [huihui-ai/Qwen2.5-Coder-32B-Instruct-abliterated](https://huggingface.co/huihui-ai/Qwen2.5-Coder-32B-Instruct-abliterated)
- **Base:** Qwen/Qwen2.5-Coder-32B-Instruct (abliterated / reduced refusals)
- **License:** Apache 2.0
- This is an uncensored variant — review outputs before production use.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| OOM on startup | Lower `MAX_MODEL_LEN` to 8192, or use A100 80GB / 2× GPU |
| Slow first request | Normal — model downloads to network volume on cold start |
| Build fails | Ensure Dockerfile path is `Dockerfile` at repo root |
| Tool calling errors | Confirm `ENABLE_AUTO_TOOL_CHOICE=true` and `TOOL_CALL_PARSER=hermes` |

## References

- [RunPod vLLM guide](https://docs.runpod.io/serverless/vllm/get-started)
- [RunPod GitHub integration](https://docs.runpod.io/serverless/workers/github-integration)
- [worker-vllm repo](https://github.com/runpod-workers/worker-vllm)
