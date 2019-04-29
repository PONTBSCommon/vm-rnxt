if [ hash kops 2>/dev/null ]; then
  source <(kops completion bash)
fi
if [ hash helm 2>/dev/null ]; then
  source <(helm completion bash)
fi
if [ hash kubectl 2>/dev/null ]; then
  source <(kubectl completion bash)
fi