number2word() {
    local full_mode=0
    local input

    if [[ "$1" == "-f" ]]; then
        full_mode=1
        shift
    fi

    if [ -t 0 ]; then
        input=$1
    else
        read -r input
    fi

    [[ ! "$input" =~ ^[0-9]+$ ]] && {
        echo "Error: input must be a positive integer"
        return 1
    }

    # Core word arrays
    local -a units=(zero one two three four five six seven eight nine)
    local -a teens=(ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen)
    local -a tens=(zero ten twenty thirty forty fifty sixty seventy eighty ninety)
    local -a scales=("" thousand, million, billion, trillion, quadrillion, quintillion, sextillion, septillion, octillion, nonillion, decillion,)


    if [[ "$full_mode" -eq 0 ]]; then
        for (( i=0; i<${#input}; i++ )); do
            digit="${input:$i:1}"
            echo -n "${units[$digit]} "
        done
        echo
        return 0
    fi

    # Pad with leading zeros to make length multiple of 3
    local padded_input="$input"
    while (( ${#padded_input} % 3 != 0 )); do
        padded_input="0$padded_input"
    done

    local num_groups=$(( ${#padded_input} / 3 ))
    local output=""
    local and_required=0

    for (( g=0; g<num_groups; g++ )); do
        local idx=$(( g * 3 ))
        local h=${padded_input:$idx:1}
        local t=${padded_input:$((idx+1)):1}
        local u=${padded_input:$((idx+2)):1}
        local group_value=$((10#$h * 100 + 10#$t * 10 + 10#$u))

        if (( group_value == 0 )); then
            continue
        fi

        local group=""
        if (( h > 0 )); then
            group="${units[$h]} hundred"
            if (( t > 0 || u > 0 )); then
                group+=" and"
            fi
        fi

        if (( t == 1 )); then
            group+=" ${teens[$u]}"
        else
            if (( t > 1 )); then
                group+=" ${tens[$t]}"
                if (( u > 0 )); then
                    group+="-${units[$u]}"
                fi
            elif (( u > 0 )); then
                group+=" ${units[$u]}"
            fi
        fi

        local scale_idx=$((num_groups - g - 1))
        if [[ -n "${scales[$scale_idx]}" ]]; then
            group+=" ${scales[$scale_idx]}"
        fi

        output+="$group "
    done

    echo "$output" | sed 's/^ *//; s/  */ /g'
}

