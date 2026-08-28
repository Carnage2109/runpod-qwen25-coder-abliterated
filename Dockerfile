# RunPod Serverless worker for huihui-ai/Qwen2.5-Coder-32B-Instruct-abliterated
# Based on https://github.com/runpod-workers/worker-vllm

ARG VLLM_VERSION=v0.28.0
FROM vllm/vllm-openai:${VLLM_VERSION}
ARG VLLM_VERSION

COPY builder/requirements.txt /requirements.txt
RUN python3 -m ensurepip --upgrade 2>/dev/null || true \
    && python3 -m pip install --no-cache-dir -r /requirements.txt

RUN python3 -m pip install --no-cache-dir --no-deps "vllm-bnb-plugin>=0.0.3"

RUN test "$(python3 -c 'import vllm; print(vllm.__version__)')" = "${VLLM_VERSION#v}"

ARG MODEL_NAME=""
ARG MODEL_REVISION=""
ARG TOKENIZER_NAME=""
ARG TOKENIZER_REVISION=""
ARG QUANTIZATION=""
ARG BASE_PATH="/runpod-volume"

ENV MODEL_NAME=${MODEL_NAME:-huihui-ai/Qwen2.5-Coder-32B-Instruct-abliterated} \
    MODEL_REVISION=$MODEL_REVISION \
    TOKENIZER_NAME=$TOKENIZER_NAME \
    TOKENIZER_REVISION=$TOKENIZER_REVISION \
    QUANTIZATION=$QUANTIZATION \
    BASE_PATH=$BASE_PATH \
    MAX_MODEL_LEN=32768 \
    GPU_MEMORY_UTILIZATION=0.95 \
    DTYPE=bfloat16 \
    ENABLE_AUTO_TOOL_CHOICE=true \
    TOOL_CALL_PARSER=hermes \
    OPENAI_SERVED_MODEL_NAME_OVERRIDE=qwen2.5-coder-32b-abliterated \
    MAX_CONCURRENCY=10 \
    VLLM_STARTUP_TIMEOUT=1800 \
    HF_HOME="${BASE_PATH}/huggingface-cache/hub" \
    HUGGINGFACE_HUB_CACHE="${BASE_PATH}/huggingface-cache/hub" \
    HF_DATASETS_CACHE="${BASE_PATH}/huggingface-cache/datasets" \
    HF_HUB_ENABLE_HF_TRANSFER=0 \
    TOKENIZERS_PARALLELISM=false

COPY src /src

RUN --mount=type=secret,id=HF_TOKEN,required=false \
    if [ -n "$MODEL_NAME" ]; then \
        if [ -f /run/secrets/HF_TOKEN ]; then \
            export HF_TOKEN=$(cat /run/secrets/HF_TOKEN); \
        fi && \
        python3 /src/download_model.py; \
    fi

ENTRYPOINT ["python3", "/src/main.py"]
