#!/bin/bash
input=$(cat)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
total_tokens=$((total_input + total_output))
input_cost=$(echo "scale=4; $total_input * 15 / 1000000" | bc)
output_cost=$(echo "scale=4; $total_output * 75 / 1000000" | bc)
total_cost=$(echo "scale=4; $input_cost + $output_cost" | bc)
if [ -n "$used_pct" ]; then
    used_pct_int=$(printf "%.0f" "$used_pct")
    if [ "$used_pct_int" -lt 25 ]; then
        color="32"  # green
    elif [ "$used_pct_int" -lt 50 ]; then
        color="33"  # yellow
    elif [ "$used_pct_int" -lt 75 ]; then
        color="38;5;208"  # orange
    else
        color="31"  # red
    fi
    printf "\033[${color}m%d%% context\033[0m (\033[90m\$%.4f, %d tokens\033[0m)" \
        "$used_pct_int" "$total_cost" "$total_tokens"
else
    printf "\033[32m0%% context\033[0m (\033[90m\$0.0000, 0 tokens\033[0m)"
fi
