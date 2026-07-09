# Workspace Data Science

Monorepo Python dedicado a **análise de dados, visualização e Machine Learning**.
Gerenciado com `uv` workspaces. Python 3.12. Fora de escopo: LLMs e AI Generativa.

---

## Comandos essenciais

```powershell
# Instalar/atualizar o venv
uv sync

# Criar novo projeto
.\novo-projeto.ps1 -Nome "analise-xyz"

# Adicionar dep a um projeto específico
uv add <pacote> --package <nome-projeto>

# Rodar testes de um projeto
cd projetos\<nome>
uv run pytest

# Rodar testes com cobertura
uv run pytest --cov

# Lint
ruff check .

# Formatação
ruff format .

# Type check
basedpyright

# JupyterLab
uv run jupyter lab

# Limpar outputs de notebooks antes de commit
uv run jupyter nbconvert --clear-output --inplace notebooks/*.ipynb
```

---

## Estrutura do workspace

```
Workspace Data Science/
├── pyproject.toml          ← deps compartilhadas + configs Ruff/BasedPyright/Pytest
├── uv.lock                 ← lock único e determinístico (commitado, nunca editar manualmente)
├── .venv/                  ← venv compartilhado (gitignored, nunca versionar)
├── projetos/
│   ├── .gitkeep            ← mantém a pasta no repositório
│   ├── .template/          ← base para novos projetos (commitado, não editar diretamente)
│   └── <nome-projeto>/     ← GITIGNORED — não entra no repositório do workspace
│       ├── pyproject.toml  ← deps específicas do projeto
│       ├── notebooks/      ← análises (01_exploracao.ipynb, 02_limpeza.ipynb ...)
│       ├── data/
│       │   ├── raw/        ← dados brutos — nunca modificar, nunca commitar
│       │   ├── processed/  ← dados tratados — nunca commitar
│       │   └── outputs/    ← resultados gerados — nunca commitar
│       ├── src/<nome>/     ← módulos Python reutilizáveis e testáveis
│       └── tests/          ← testes unitários (testam src/, não notebooks)
├── novo-projeto.ps1
├── .pre-commit-config.yaml
├── .env.example
└── .gitignore
```

---

## Regras de código

### Geral
- Nunca usar `pip` diretamente — sempre `uv add` ou `uv sync`
- Deps científicas compartilhadas (numpy, pandas, scikit-learn etc.) ficam no root `pyproject.toml`
- Deps específicas de projeto ficam em `projetos/<nome>/pyproject.toml`
- Nunca adicionar ao root deps que só um projeto usa (ex.: `optuna`, `shap`, `imbalanced-learn`)

### Módulos Python (`src/`)
- Seguir src layout: `src/<nome-projeto>/`
- Todo código reutilizado entre notebooks deve virar módulo em `src/`
- Todo módulo em `src/` deve ter testes em `tests/`
- Type hints obrigatórios em funções públicas (BasedPyright modo standard)
- Sem `print()` em módulos — usar `rich.console.Console()` ou logging

### Notebooks (`notebooks/`)
- Prefixo numérico obrigatório: `01_exploracao.ipynb`, `02_limpeza.ipynb`, `03_modelo.ipynb`
- Cada notebook tem um único propósito (exploração, limpeza, modelagem, relatório)
- Nunca commitar outputs de células — limpar com `nbconvert --clear-output` antes do commit
- Nunca colocar credenciais, URLs privadas ou dados sensíveis em notebooks
- Notebooks são para prototipação; código estável vai para `src/`

### Projetos (`projetos/`)
- A pasta `projetos/` é versionada (rastreada via `projetos/.gitkeep`)
- Cada projeto dentro dela (`projetos/<nome>/`) é gitignored — nenhum projeto individual vai ao repositório
- Para preservar código de um projeto, criar um repositório Git separado dentro dele

### Dados (`data/`)
- `data/raw/` — somente leitura; nunca transformar no lugar
- `data/processed/` e `data/outputs/` — sempre derivados do código em `src/`
- Arquivos de dados são sempre gitignored (CSV, Parquet, XLSX, PKL, modelos)
- Datasets > 10 MB: usar armazenamento externo (S3, SharePoint) ou DVC

### Variáveis de ambiente
- Nunca hardcodar credenciais ou URLs no código
- Usar `python-dotenv` com `.env` local (gitignored) baseado em `.env.example`

---

## Quando usar cada biblioteca

### Dados tabulares

| Situação | Use |
|---|---|
| Dataset < 1 GB, API familiar, integração com libs legadas | `pandas` |
| Dataset > 1 GB, performance crítica, lazy evaluation | `polars` |
| Consulta SQL sobre Parquet/CSV sem servidor | `duckdb` |
| Ler/escrever `.xlsx` | `openpyxl` via `pandas` ou `polars` |
| Serialização eficiente entre libs | `pyarrow` (Parquet) |

### Visualização

| Situação | Use |
|---|---|
| EDA rápida com estatísticas | `seaborn` |
| Gráfico para apresentação/relatório interativo | `plotly` |
| Controle total de layout, subplots complexos | `matplotlib` |

### Machine Learning

| Situação | Use |
|---|---|
| Pré-processamento, pipelines, algoritmos clássicos | `scikit-learn` |
| Baseline tabular forte, dados médios | `xgboost` |
| Dataset grande (> 500k linhas), treino rápido | `lightgbm` |
| Testes estatísticos, otimização numérica | `scipy` |
| Regressão com output detalhado, séries temporais | `statsmodels` |

---

## Qualidade de código

### Ruff (linter + formatter)
- `line-length = 100`
- Regras ativas: `E`, `W`, `F`, `I`, `B`, `C4`, `UP`, `N`, `SIM`
- Notebooks (`.ipynb`) excluídos do Ruff — formatação manual
- Rodar `ruff check --fix .` antes de propor mudanças

### BasedPyright
- Modo `standard`
- Inclui apenas `projetos/`; exclui `.venv` e notebooks
- Type hints obrigatórios em funções públicas de módulos `src/`

### Pytest
- Testa somente código em `src/` — nunca testa lógica de notebooks diretamente
- Fixtures com dados sintéticos em `conftest.py`
- Rodar `uv run pytest --cov` e garantir que não há regressão antes de finalizar

### Pre-commit hooks
Executam automaticamente no `git commit`. Se um hook falhar, corrigir antes de retentar — nunca usar `--no-verify`.

---

## Criação de novo projeto

```powershell
# 1. Scaffold
.\novo-projeto.ps1 -Nome "analise-churn"

# 2. Atualizar venv
uv sync

# 3. Adicionar deps específicas (se necessário)
uv add imbalanced-learn --package analise-churn

# 4. Explorar
cd projetos\analise-churn
uv run jupyter lab
```

A estrutura gerada pelo scaffold já inclui:
- `pyproject.toml` com nome e pytest configurado
- `notebooks/01_exploracao.ipynb` com imports padrão prontos
- `src/<nome>/__init__.py` e `tests/__init__.py`
- Pastas `data/raw`, `data/processed`, `data/outputs`

---

## Checklist antes de gerar ou modificar código

- [ ] Dep nova adicionada via `uv add --package <nome>`, não editando `pyproject.toml` manualmente
- [ ] `uv sync` executado após mudança de dependências
- [ ] Código reutilizável está em `src/`, não duplicado entre notebooks
- [ ] Funções em `src/` têm type hints e testes em `tests/`
- [ ] Nenhum `print()` em módulos Python
- [ ] Nenhuma credencial ou dado sensível em notebooks ou código
- [ ] Outputs de notebooks limpos antes de propor commit
- [ ] `ruff check --fix .` passou sem erros
- [ ] `uv run pytest` passou sem regressão

---

Eduardo Felizardo Cândido

Senior QA Automation Engineer | AI-driven Testing | Robot Framework
