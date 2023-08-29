for file in ~/.profile.d/[0-9]*; do
  if test -r "${file}"; then
    # shellcheck disable=SC1090
    . "${file}"
  fi
done
