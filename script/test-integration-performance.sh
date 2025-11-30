#!/bin/bash

echo "=========================================="
echo "gRPC vs REST Performance Comparison"
echo "=========================================="
echo ""

# 결과 저장 디렉토리
RESULTS_DIR="benchmark-results"
mkdir -p $RESULTS_DIR

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "Testing gRPC..."
./script/benchmark-grpc.sh > "$RESULTS_DIR/grpc_$TIMESTAMP.txt" 2>&1

echo ""
echo "Testing REST..."
./script/benchmark-rest.sh > "$RESULTS_DIR/rest_$TIMESTAMP.txt" 2>&1

echo ""
echo "Results saved to $RESULTS_DIR/"
echo "- grpc_$TIMESTAMP.txt"
echo "- rest_$TIMESTAMP.txt"
echo ""
echo "=========================================="
echo "Performance Comparison Completed"
echo "=========================================="
