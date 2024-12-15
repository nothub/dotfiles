date --rfc-3339=s >> "${HOME}/.profile.log"
for file in "${HOME}/.profile.d/"[0-9]*; do
    if test -r "${file}"; then
        echo "exec $(basename "${file}")" >> "${HOME}/.profile.log"
        # shellcheck disable=SC1090
        . "${file}"
    fi
done
