#!/bin/bash

# ---------- Parse arguments

usage_exit() {
    echo "Usage: $0 [-o] [-d] [-s PYTHON_FILE_OR_DIR_PATH]" 1>&2
    echo ""
    echo "-o                        : Output LINT results to file."
    echo "-d                        : Disable to create stub file."
    echo "-s PYTHON_FILE_OR_DIR_PATH: Lint target file or directory path. Default value is ./src"
    exit 1
}

disable_createstub=0
output_to_file=0
target_file_or_dir='./src'
while getopts dos:h OPT; do
    case $OPT in
    d)
        disable_createstub=1
        ;;
    o)
        output_to_file=1
        ;;
    s)
        target_file_or_dir=$OPTARG
        ;;
    h)
        usage_exit
        ;;
    \?)
        usage_exit
        ;;
    esac
done

shift $((OPTIND - 1))

# ---------- Change directory

script_dir=$(cd "$(dirname "$0")" && pwd -P)

pushd "$script_dir" || exit 1

# ---------- Create stubs

if [ $disable_createstub == 0 ]; then
    if [ -e '.stublist' ]; then
        while read -r package_name; do
            if [ "$package_name" != "" ]; then
                poetry run pyright --createstub "$package_name"
            fi
        done <'.stublist'
    fi
fi

: nop &&
    # ---------- Maintain modules
    poetry run python script/pythonpath_maintainer.py ./src &&

    # ---------- Format JSON files
    poetry run python script/json_formatter.py .vscode/settings.json \
        --as_set_paths '["/cSpell.ignoreRegExpList","/cSpell.words"]' \
        >.vscode/settings.json.tmp &&
    rm -rf .vscode/settings.json &&
    mv .vscode/settings.json.tmp .vscode/settings.json &&

    # ---------- Format Python files

    # To move import to top.
    poetry run find "$target_file_or_dir" -name '*.py' -exec autopep8 --in-place '{}' \; &&
    # To sort import.
    poetry run isort "$target_file_or_dir" &&
    # To format python code.
    poetry run black "$target_file_or_dir" &&

    # ---------- Lint python files
    if [ $output_to_file == 1 ]; then
        if [ -e 'lint_result' ]; then
            rm -rf lint_result
        fi &&
            mkdir lint_result &&
            if type "node_modules/.bin/pyright" >/dev/null 2>&1; then
                npm run pyright --outputjson >lint_result/pyright.json
            fi &&
            poetry run flake8 --config .flake8 --output-file lint_result/flake8.log "$target_file_or_dir"
    else
        if type "node_modules/.bin/pyright" >/dev/null 2>&1; then
            npm run pyright
        fi &&
            poetry run flake8 --config .flake8 "$target_file_or_dir"
    fi

popd || exit 1
