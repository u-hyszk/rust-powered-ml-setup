#!/bin/bash

function ask_yes_no {
    while true; do
    echo -n "$* [y/n]: "
    read ANS
        case $ANS in
            [Yy]*)
            return 0
            ;;
        [Nn]*)
            return 1
            ;;
        *)
            echo "yまたはnを入力してください"
            ;;
        esac
    done
}

if ask_yes_no "Rye本体のインストールを行いますか？"; then
    curl -sSf https://rye-up.com/get | bash
    echo 'source "$HOME/.rye/env' >> ~/.bashrc
    source ~/.bashrc
    rye config --set-bool behavior.use-uv=true
fi

if ask_yes_no "Ryeプロジェクトを作成しますか？"; then
    rye init

    if ask_yes_no "Pythonのバージョンを指定しますか？(デフォルト: 3.10): "; then
        read PYTHON_VERSION
        rye pin ${PYTHON_VERSION}
    else
        rye pin 3.10
    fi
    rye sync
fi


if ask_yes_no "pytestをインストールしますか？"; then
    rye add pytest pytest-clarity pytest-cov pytest-randomly pytest-xdist
    rye add pytest-mock pytest-faker

    if ask_yes_no "pyproject.tomlに設定を追加しますか？"; then
        echo "" >> pyproject.toml
        echo "[tool.pytest.ini_options]" >> pyproject.toml
        echo "addopts = \"-v -s -n auto --cov --cov-branch\"" >> pyproject.toml
    fi
fi

if ask_yes_no "pydanticをインストールしますか？"; then
    rye add pydantic
fi

if ask_yes_no "pytorchをインストールしますか？"; then
    echo "${TORCH_URL}からダウンロードします"
    rye add torch --url ${TORCH_URL}
fi

if ask_yes_no "hydra-coreとinvokeをインストールしますか？"; then
    rye add hydra-core invoke
fi

if ask_yes_no "wandbをインストールしますか？"; then
    rye add wandb
    if ask_yes_no "wandbにログインしますか？"; then
        rye run wandb login
    fi
fi

if ask_yes_no "vscode拡張機能をインストールしますか？"; then
    if ask_yes_no "Ruffをインストールしますか？"; then
        code --install-extension charliermarsh.ruff
    fi
    if ask_yes_no "mypy-type-checkerをインストールしますか？"; then
        code --install-extension ms-python.mypy-type-checker
    fi
    if ask_yes_no "github copilotをインストールしますか？"; then
        code --install-extension github.copilot github.copilot-chat
    fi
fi

if ask_yes_no "gitリポジトリを初期化しますか？"; then
    rm -rf .git
    git init
fi

echo "セットアップが完了しました"
exit 0
