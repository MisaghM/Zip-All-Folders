#!/bin/bash

[[ -n "$1" ]] && { cd "$1" || exit 1; }

# Get a yes/no choice from the user.
getchoice() { # Args: 1:prompt. Returns: 0:true 1:false
    local choice
    while true; do
        read -n 1 -r -p "$1 [Y,N] " choice
        echo
        case $choice in
            [Yy] ) return 0 ;;
            [Nn] ) return 1 ;;
            *    ) echo "Invalid input." ;;
        esac
    done
}

# Get human-readable size from bytes.
prettysize() { # Args: 1:size
    local size=$1
    local unit="B"
    local roundup=0

    for u in KB MB GB TB; do
        if [[ "$size" -ge 1024 ]]; then
            unit="$u"
            roundup=$((size & 512))
            ((size >>= 10))
        else break
        fi
    done

    [[ "$roundup" -gt 0 ]] && ((++size))
    echo "$size $unit"
    return 0
}

getchoice "Remove original folders?" && rmFolders="true"
echo

count=0
for f in */ ; do
    folder="${f%/}"

    [[ "$folder" = "*" ]] && break
    [[ -L "$folder" ]] && continue

    ((++count))
    echo "Folder $count: $folder"

    zipname="${folder}.zip"
    (cd "$folder" && zip "../$zipname" -r -0 . -i \\* > /dev/null || exit 1)

    zipsize="$(wc -c < "$zipname")"
    echo "Size ~ $(prettysize "$zipsize")"

    if [[ "$rmFolders" = "true" ]]; then
        rm -rf "$folder"
        echo "Folder deleted."
    fi

    echo
done

echo "Done."
read -n 1 -r -s -p "Press any key to continue . . . "
echo
exit 0
