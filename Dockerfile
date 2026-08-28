# RunPod Serverless worker for huihui-ai/Qwen2.5-Coder-32B-Instruct-abliterated
# Extends the official RunPod vLLM worker (OpenAI-compatible API).
#
# Docs: https://docs.runpod.io/serverless/vllm/get-started
# Upstream: https://github.com/runpod-workers/worker-vllm

FROM runpod/worker-v1-vllm:v2.26.0

# Model defaults — override any of these in RunPod endpoint env vars.
ENV MODEL_NAME=huihui-ai/Qwen2.5-Coder-32B-Instruct-abliterated \
    MAX_MODEL_LEN=32768 \
    GPU_MEMORY_UTILIZATION=0.95 \
    DTYPE=bfloat16 \
    ENABLE_AUTO_TOOL_CHOICE=true \
    TOOL_CALL_PARSER=hermes \
    OPENAI_SERVED_MODEL_NAME_OVERRIDE=qwen2.5-coder-32b-abliterated \
    MAX_CONCURRENCY=10 \
    VLLM_STARTUP_TIMEOUT=1800
