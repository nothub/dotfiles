function sdk-switch-java() {
    if [[ -z ${SDKMAN_DIR} ]]; then
        echo >&2 "Error: \$SDKMAN_DIR not set"
        return 1
    fi
    if [[ $# -le 0 ]]; then
        echo >&2 "Error: missing version argument"
        return 1
    fi
    local candidate
    candidate="$(find "${SDKMAN_DIR}/candidates/java/" \
        -maxdepth 1 \
        -type d \
        -regex ".*\/java\/${1}.*" \
        -exec basename {} \; |
        sort -n -r |
        head -n 1)"
    if test -z "${candidate}"; then
        echo >&2 "Error: no sdkman java candidates"
        return 1
    fi
    sdk use java "${candidate}"
}
export -f sdk-switch-java

alias jdk8="sdk-switch-java 8"
alias jdk11="sdk-switch-java 11"
alias jdk17="sdk-switch-java 17"
