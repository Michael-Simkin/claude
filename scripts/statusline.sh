#!/bin/bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "?"')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
ctx_int=$(printf "%.0f" "$ctx_pct" 2>/dev/null || echo "0")

dir=$(echo "$PWD" | awk -F/ '{if(NF>1) print $(NF-1)"/"$NF; else print $NF}')

block_pct_raw=$(echo "$input"  | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
block_resets=$(echo "$input"   | jq -r '.rate_limits.five_hour.resets_at        // empty' 2>/dev/null)
week_pct_raw=$(echo "$input"   | jq -r '.rate_limits.seven_day.used_percentage  // empty' 2>/dev/null)
week_resets=$(echo "$input"    | jq -r '.rate_limits.seven_day.resets_at         // empty' 2>/dev/null)

block_pct=""
week_pct=""
[ -n "$block_pct_raw" ] && block_pct=$(printf "%.0f" "$block_pct_raw" 2>/dev/null)
[ -n "$week_pct_raw"  ] && week_pct=$(printf  "%.0f" "$week_pct_raw"  2>/dev/null)

fmt_dur() {
    local s=$1
    if   [ "$s" -le 0 ];      then echo "0m"
    elif [ "$s" -lt 3600 ];   then echo "$(( s / 60 ))m"
    elif [ "$s" -lt 86400 ];  then echo "$(( s / 3600 ))h$(printf "%02d" $(( (s % 3600) / 60 )))m"
    else                           echo "$(( s / 86400 ))d$(( (s % 86400) / 3600 ))h"
    fi
}

now_ts=$(date +%s)

block_reset="--"
week_reset="--"
[ -n "$block_resets" ] && block_reset=$(fmt_dur $(( block_resets - now_ts )))
[ -n "$week_resets"  ] && week_reset=$(fmt_dur  $(( week_resets  - now_ts )))

block_label="${block_pct:+${block_pct}%}"
week_label="${week_pct:+${week_pct}%}"
[ -z "$block_label" ] && block_label="--"
[ -z "$week_label"  ] && week_label="--"

# One Dark Pro full palette - foreground
G="38;5;113"     # green
Y="38;5;173"     # yellow
R="38;5;167"     # red
C="38;5;73"      # cyan
FG="38;5;145"    # foreground
W="38;5;188"     # white
DIM="38;5;240"   # dim

# Grays
G4="48;5;237"; G4F="38;5;237"

if   [ "$ctx_int" -lt 25 ]; then ctx_fg="$G"
elif [ "$ctx_int" -lt 75 ]; then ctx_fg="$Y"
else                              ctx_fg="$R"
fi

grade_pct() {
    local p=${1:-0}
    if   [ "$p" -lt 50 ]; then echo "$G"
    elif [ "$p" -lt 80 ]; then echo "$Y"
    else                       echo "$R"
    fi
}
block_color=$(grade_pct "${block_pct:-0}")
week_color=$(grade_pct  "${week_pct:-0}")

render() {
    local dtxt="$1" dbg="$2" dfg="$3"
    local mtxt="$4" mbg="$5" mfg="$6"
    local cbg="$7" cfg="$8"
    local bbg="$9" bfg="${10}"
    local lbl="${11}"

    local bf="" be=""
    [ "$filled" -gt 0 ] && bf=$(printf '%0.s━' $(seq 1 $filled))
    [ "$empty"  -gt 0 ] && be=$(printf '%0.s ' $(seq 1 $empty))
    local cbar="\033[${cfg};${cbg}m${bf}${be}"

    local DIV="\033[38;5;243;${dbg}m│"
    local o="\033[1;${DIM}m${lbl}\033[0m "
    o="${o}\033[${dtxt};${dbg}m %s ${DIV} \033[${mtxt};${mbg}m%s "
    o="${o}${DIV}"
    o="${o}\033[${cfg};${cbg}m %d%% ${cbar} ${DIV}"
    o="${o} \033[1;${DIM};${bbg}m5h \033[1;${block_color};${bbg}m%s \033[${DIM};${bbg}m· \033[${C};${bbg}m%s "
    o="${o}${DIV}"
    o="${o} \033[1;${DIM};${bbg}mwk \033[1;${week_color};${bbg}m%s \033[${DIM};${bbg}m· \033[${C};${bbg}m%s \033[0m"
    printf "$o" "$dir" "$model" "$ctx_int" \
        "$block_label" "$block_reset" \
        "$week_label"  "$week_reset"
}

bar_len=20
filled=$(( ctx_int * bar_len / 100 ))
[ "$filled" -gt "$bar_len" ] && filled=$bar_len
empty=$(( bar_len - filled ))

render "$C" "$G4" "$G4F"  "$W" "$G4" "$G4F"  "$G4" "$ctx_fg"  "$G4" "$FG"  ""
