#!/usr/bin/env bash
set -euo pipefail

# This script lives in bin/, write to data/orders.csv
CSV="data/orders.csv"

INTERVAL_SECONDS=2
MAX_ROWS=500            # data rows, excluding header
BAD_CHANCE=18           # ~1 in 18 rows is bad (lower = more bad rows)

# Incident spike settings (rare burst of multiple bad rows)
SPIKE_CHANCE=90         # ~1 in 90 cycles starts a spike
SPIKE_MIN=4
SPIKE_MAX=7
spike_remaining=0

# Create CSV with header if it doesn't exist
if [ ! -f "$CSV" ]; then
  echo "row_id,timestamp,customer_id,order_amount,status" > "$CSV"
fi

row_id() {
  local last
  last=$(tail -n 1 "$CSV" | cut -d',' -f1)
  if [[ "$last" =~ ^[0-9]+$ ]]; then
    echo $((last + 1))
  else
    echo 1
  fi
}

iso_ts() {
  date +"%Y-%m-%dT%H:%M:%S"
}

rand_customer() {
  printf "CUST%04d" $((RANDOM % 9999 + 1))
}

rand_amount() {
  # 5.00 to 500.00 (two decimals) using awk for portability
  awk -v r="$RANDOM" 'BEGIN{
    min=500; max=50000;  # cents
    cents = min + (r % (max-min+1));
    printf "%.2f", cents/100.0
  }'
}

rand_status() {
  local pick=$((RANDOM % 4))
  case "$pick" in
    0) echo "NEW" ;;
    1) echo "PAID" ;;
    2) echo "SHIPPED" ;;
    *) echo "REFUNDED" ;;
  esac
}

make_good_row() {
  local id ts cust amt st
  id="$(row_id)"
  ts="$(iso_ts)"
  cust="$(rand_customer)"
  amt="$(rand_amount)"
  st="$(rand_status)"
  echo "${id},${ts},${cust},${amt},${st}"
}

make_bad_row() {
  # Rotate through different “bad data” patterns to support varied rules
  local id ts cust amt st which
  id="$(row_id)"
  ts="$(iso_ts)"
  cust="$(rand_customer)"
  amt="$(rand_amount)"
  st="$(rand_status)"

  which=$((RANDOM % 5))
  case "$which" in
    0) cust="" ;;                    # missing customer_id
    1) amt="-50.00" ;;               # negative amount
    2) st="PROCESSING" ;;            # invalid status
    3) ts="not-a-timestamp" ;;       # invalid timestamp
    *) amt="50000.00" ;;             # suspiciously high amount
  esac

  echo "${id},${ts},${cust},${amt},${st}"
}

trim_csv() {
  # Keep header + last MAX_ROWS data lines
  local total
  total=$(wc -l < "$CSV")
  if [ "$total" -gt $((MAX_ROWS + 1)) ]; then
    {
      head -n 1 "$CSV"
      tail -n "$MAX_ROWS" "$CSV"
    } > "${CSV}.tmp"
    mv "${CSV}.tmp" "$CSV"
  fi
}

echo "Writing to $(realpath "$CSV" 2>/dev/null || echo "$CSV") every ${INTERVAL_SECONDS}s - Ctrl+C to stop"
rowtype=""
while true; do
  # Rare incident spike: several bad rows in a burst to simulate an outage/incident
  if [ "$spike_remaining" -le 0 ] && [ $((RANDOM % SPIKE_CHANCE)) -eq 0 ]; then
    spike_remaining=$((SPIKE_MIN + (RANDOM % (SPIKE_MAX - SPIKE_MIN + 1))))
    echo "!! Incident spike started: next ${spike_remaining} row(s) will be bad"
  fi

  if [ "$spike_remaining" -gt 0 ]; then
    rowtype="bad"
    row="$(make_bad_row)"
    spike_remaining=$((spike_remaining - 1))
  else
    # Otherwise: mostly good rows, occasional bad ones
    if [ $((RANDOM % BAD_CHANCE)) -eq 0 ]; then
      rowtype="bad"
      row="$(make_bad_row)"
    else
      rowtype="good"
      row="$(make_good_row)"
    fi
  fi

  echo "$row" >> "$CSV"
  trim_csv

  if [ "${rowtype}" = "bad" ]; then
    echo "$row ***"
  else
    echo "$row"
  fi

  sleep "$INTERVAL_SECONDS"
done

