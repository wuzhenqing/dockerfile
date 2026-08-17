# verl

Thin customization on top of a published Ascend veRL / vLLM stack image (`quay.io/ascend/verl` with CANN 9.0.0 and torch-npu). Use `verl/Dockerfile` when you need that training stack with repository-local adjustments rather than assembling the full dependency tree from scratch.

```bash
docker build -f verl/Dockerfile -t verl:dev .
```
