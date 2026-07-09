# Workspace Data Science

Workspace monorepo dedicado a **análise de dados, visualização e Machine Learning**, construído sobre Python 3.12 e gerenciado com `uv`.

> Bibliotecas de LLMs e AI Generativa ficam em workspace separado (AI Engineering).

---

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Python | 3.12 |
| uv | 0.11+ |
| Git | 2.40+ |
| Docker Desktop | opcional |

---

## Instalação

```powershell
# Clone ou acesse a pasta
cd "C:\dev\Workspace Data Science"

# Instalar todas as dependências
uv sync

# Instalar ferramentas globais (se ainda não instaladas)
uv tool install ruff
uv tool install basedpyright
uv tool install pre-commit

# Configurar hooks de qualidade de código
pre-commit install
```

---

## Estrutura

```
Workspace Data Science/
├── pyproject.toml              ← root do workspace (deps compartilhadas)
├── uv.lock                     ← lock único para todos os projetos (commitado)
├── .venv/                      ← venv compartilhado (gitignored)
├── projetos/
│   ├── .gitkeep                ← mantém a pasta no repositório
│   ├── .template/              ← base para novos projetos (commitado)
│   └── <nome-projeto>/         ← gitignored — não entra no repositório
│       ├── pyproject.toml
│       ├── notebooks/          ← Jupyter notebooks (01_*, 02_*, ...)
│       ├── data/
│       │   ├── raw/            ← dados brutos (gitignored)
│       │   ├── processed/      ← dados tratados (gitignored)
│       │   └── outputs/        ← resultados gerados (gitignored)
│       ├── src/<nome>/         ← módulos Python reutilizáveis
│       └── tests/
├── novo-projeto.ps1            ← scaffolding de novos projetos
├── .pre-commit-config.yaml
├── .env.example
├── .gitignore
└── .vscode/
    ├── extensions.json
    └── settings.json
```

---

## Criar um novo projeto

```powershell
.\novo-projeto.ps1 -Nome "analise-vendas"

uv sync
cd projetos\analise-vendas
uv run jupyter lab
```

---

## Comandos úteis

| Ação | Comando |
|---|---|
| Atualizar venv | `uv sync` |
| Adicionar dep global | `uv add <pacote>` |
| Adicionar dep a um projeto | `uv add <pacote> --package <nome>` |
| Rodar testes de um projeto | `cd projetos\<nome>` → `uv run pytest` |
| Rodar testes com cobertura | `uv run pytest --cov` |
| Linting | `ruff check .` |
| Formatação | `ruff format .` |
| Type check | `basedpyright` |
| JupyterLab | `uv run jupyter lab` |
| DuckDB interativo | `uv run python -c "import duckdb; duckdb.connect().sql('SELECT 42').show()"` |

---

## Stack

Veja [REQUIREMENTS.md](REQUIREMENTS.md) para a lista completa de pacotes com versões e justificativas.

---

## Convenções de notebooks

- Prefixo numérico indica ordem: `01_exploracao.ipynb`, `02_limpeza.ipynb`, `03_modelo.ipynb`
- Nunca commitar saídas de células (`outputs`): use `jupyter nbconvert --clear-output` antes do commit
- Dados brutos, processados e modelos treinados são **sempre gitignored** — usar armazenamento externo ou DVC para versionamento de dados

---

## Qualidade de código

Os hooks do `pre-commit` executam automaticamente a cada `git commit`:

- **ruff** — lint + fix automático
- **ruff-format** — formatação
- **trailing-whitespace** — remove espaços no final
- **end-of-file-fixer** — garante newline final
- **check-yaml / check-toml** — valida sintaxe
- **check-merge-conflict** — bloqueia conflitos não resolvidos
- **check-added-large-files** — bloqueia arquivos > 10 MB

---

Eduardo Felizardo Cândido

Senior QA Automation Engineer | AI-driven Testing | Robot Framework
