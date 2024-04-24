if command -v direnv > /dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

if command -v mise > /dev/null 2>&1; then
    eval "$(mise activate bash)"
fi
