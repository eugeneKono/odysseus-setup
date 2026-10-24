#!/bin/bash

DEFAULT_SINK=$(pactl get-default-sink)

pactl list short sink-inputs | while read stream; do
    STREAM_ID=$(echo "$stream" | awk '{print $1}')
    pactl move-sink-input "$STREAM_ID" "$DEFAULT_SINK"
done
