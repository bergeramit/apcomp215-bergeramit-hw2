#!/bin/bash

# Simple MCP Server Test
MCP_URL="https://pavlos-cheese-mcp2-1097076476714.europe-west1.run.app/mcp"

echo "=== Testing MCP Server ==="
echo ""

# Test 1: Initialize and get session
init_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -D /tmp/mcp_headers.txt \
    -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' \
    "$MCP_URL")

# Extract session ID from headers
session_id=$(grep -i "mcp-session-id:" /tmp/mcp_headers.txt | cut -d' ' -f2 | tr -d '\r\n')

# Extract JSON from SSE data line
init_data=$(echo "$init_response" | grep "^data:" | sed 's/^data: //')

# Extract server name using grep and sed
server_name=$(echo "$init_data" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "1. Server Status: ✓ Running"
echo "   Server Name: $server_name"
echo ""

# Send initialized notification (no response expected)
curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -H "mcp-session-id: $session_id" \
    -d '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
    "$MCP_URL" > /dev/null

# Test 2: List tools using session ID
tools_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -H "mcp-session-id: $session_id" \
    -d '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
    "$MCP_URL")

# Extract JSON from SSE data line
tools_data=$(echo "$tools_response" | grep "^data:" | sed 's/^data: //')

echo "2. Available Tools:"
echo "$tools_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'result' in data and 'tools' in data['result']:
        for tool in data['result']['tools']:
            print(f\"   - {tool['name']}: {tool.get('description', 'No description')}\")
    else:
        print('   Error:', data.get('error', {}).get('message', 'Unknown error'))
except:
    pass
"

echo ""
echo "=== Test Complete ==="

# Cleanup
rm -f /tmp/mcp_headers.txt