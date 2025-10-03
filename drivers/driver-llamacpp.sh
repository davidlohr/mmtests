run_bench() {
	# Validate mutually exclusive model configuration
	if [ -n "$LLAMACPP_MODEL_URL" ] && [ -n "$LLAMACPP_MODEL_SIZE" ]; then
		die "LLAMACPP_MODEL_URL and LLAMACPP_MODEL_SIZE are mutually exclusive. Please specify only one."
	fi

	ARGS=(
		--compute-backend $LLAMACPP_COMPUTE_BACKEND
		--iterations	$LLAMACPP_ITERATIONS
	)
	
	# Only add performance parameters if set
	if [ -n "$LLAMACPP_BATCH_SIZE" ]; then
		ARGS+=(--batch-size "$LLAMACPP_BATCH_SIZE")
	fi
	if [ -n "$LLAMACPP_PROMPT_TOKENS" ]; then
		ARGS+=(--prompt-tokens "$LLAMACPP_PROMPT_TOKENS")
	fi
	if [ -n "$LLAMACPP_GEN_TOKENS" ]; then
		ARGS+=(--gen-tokens "$LLAMACPP_GEN_TOKENS")
	fi
	
	# Only add model size if set
	if [ -n "$LLAMACPP_MODEL_SIZE" ]; then
		ARGS+=(--model-size "$LLAMACPP_MODEL_SIZE")
	fi
	
	# Only add custom model URL if set
	if [ -n "$LLAMACPP_MODEL_URL" ]; then
		ARGS+=(--model-url "$LLAMACPP_MODEL_URL")
	fi
	
	
	# Only add thread limits if set
	if [ -n "$LLAMACPP_MIN_THREADS" ]; then
		ARGS+=(--min-threads "$LLAMACPP_MIN_THREADS")
	fi
	if [ -n "$LLAMACPP_MAX_THREADS" ]; then
		ARGS+=(--max-threads "$LLAMACPP_MAX_THREADS")
	fi
	
	# Only add NUMA option if set
	if [ -n "$LLAMACPP_MODEL_NUMA" ]; then
		ARGS+=(--numa "$LLAMACPP_MODEL_NUMA")
	fi
	
	# Only add warmup option if set
	if [ -n "$LLAMACPP_WARMUP" ]; then
		ARGS+=(--warmup "$LLAMACPP_WARMUP")
	fi
	
	# Only add no-kv-offload option if set
	if [ -n "$LLAMACPP_NO_KVOFFLOAD" ]; then
		ARGS+=(--no-kv-offload "$LLAMACPP_NO_KVOFFLOAD")
	fi
	
	$SCRIPTDIR/shellpacks/shellpack-bench-llamacpp "${ARGS[@]}"
	return $?
}