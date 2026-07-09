# Requirements — Workspace Data Science

Lista completa de dependências diretas com versões instaladas e justificativas de escolha.

---

## Ambiente interativo

| Pacote | Versão | Justificativa |
|---|---|---|
| jupyterlab | 4.6.1 | IDE interativa para exploração, visualização e documentação de análises |
| notebook | 7.6.0 | Interface clássica do Jupyter; compatibilidade com ambientes legados |
| ipykernel | 7.3.0 | Kernel Python para execução de notebooks no JupyterLab |

---

## Manipulação de dados

| Pacote | Versão | Justificativa |
|---|---|---|
| numpy | 2.5.1 | Computação numérica de alto desempenho; base de toda a stack científica |
| pandas | 3.0.3 | Manipulação tabular orientada a índice; API amplamente conhecida no mercado |
| polars | 1.42.1 | Alternativa de alta performance ao Pandas (lazy evaluation, zero-copy, Rust) |
| pyarrow | 24.0.0 | Serialização columnar eficiente (Parquet, Arrow IPC); interop Pandas/Polars |
| openpyxl | 3.1.5 | Leitura e escrita de arquivos `.xlsx` sem dependência do Excel |
| duckdb | 1.5.4 | SQL analítico in-process; consultas eficientes em Parquet/CSV sem servidor |

---

## Visualização de dados

| Pacote | Versão | Justificativa |
|---|---|---|
| matplotlib | 3.11.0 | Base de toda visualização científica Python; controle total de layout |
| seaborn | 0.13.2 | Estatísticas visuais de alto nível sobre Matplotlib; EDA rápida |
| plotly | 6.9.0 | Gráficos interativos para notebooks e dashboards (HTML exportável) |

---

## Machine Learning

| Pacote | Versão | Justificativa |
|---|---|---|
| scikit-learn | 1.9.0 | Algoritmos clássicos de ML; pipelines, pré-processamento e avaliação |
| xgboost | 3.3.0 | Gradient Boosting de alta performance; forte baseline para dados tabulares |
| lightgbm | 4.6.0 | Alternativa ao XGBoost com treinamento mais rápido em datasets grandes |

---

## Estatística

| Pacote | Versão | Justificativa |
|---|---|---|
| scipy | 1.18.0 | Testes estatísticos, otimização, álgebra linear e funções científicas |
| statsmodels | 0.14.6 | Modelos estatísticos com output detalhado (OLS, GLM, séries temporais) |

---

## Qualidade de código

| Pacote / Ferramenta | Versão | Modo | Justificativa |
|---|---|---|---|
| ruff | 0.15.20 | `uv tool` | Linter + formatter ultrarrápido (substitui flake8, isort, black) |
| basedpyright | 1.39.9 | `uv tool` | Type checker estático rigoroso, fork do Pyright |
| pre-commit | 4.6.0 | `uv tool` | Executa hooks de qualidade automaticamente antes de cada commit |
| pytest | 9.1.1 | dep | Framework de testes moderno com fixtures e plugins |
| pytest-cov | 7.1.0 | dep | Relatório de cobertura integrado ao pytest |

---

## Utilitários

| Pacote | Versão | Justificativa |
|---|---|---|
| python-dotenv | 1.2.2 | Carrega variáveis de `.env` para gerenciamento de configuração |
| rich | 15.0.0 | Output colorido e tabelas formatadas no terminal |
| typer | 0.26.8 | CLIs com type hints Python; zero boilerplate |
| httpx | 0.28.1 | Cliente HTTP async/sync moderno; substitui `requests` em código novo |
| pydantic | 2.13.4 | Validação e serialização de dados com type hints (v2) |

---

## Ferramentas de infraestrutura

| Ferramenta | Versão | Justificativa |
|---|---|---|
| Python | 3.12.10 | Versão LTS atual; melhorias de performance e sintaxe (f-strings, match) |
| uv | 0.11+ | Gerenciador de pacotes e workspaces ultrarrápido (substitui pip + venv) |
| Git | 2.40+ | Versionamento de código |
| Docker Desktop | — | Opcional; para bancos de dados, MLflow tracking server, etc. |

---

## Extensões VS Code recomendadas

| Extensão | ID | Função |
|---|---|---|
| Python | `ms-python.python` | Suporte completo Python (debugging, IntelliSense) |
| Pylance | `ms-python.vscode-pylance` | Language server Python (basedpyright integrado) |
| Jupyter | `ms-toolsai.jupyter` | Execução de notebooks dentro do VS Code |
| Ruff | `charliermarsh.ruff` | Lint e format on-save |
| GitLens | `eamodio.gitlens` | Histórico e blame inline |
| Error Lens | `usernamehw.errorlens` | Erros inline no editor |
| Even Better TOML | `tamasfe.even-better-toml` | Suporte a `pyproject.toml` |
| YAML | `redhat.vscode-yaml` | Validação de `.pre-commit-config.yaml` |
| Docker | `ms-azuretools.vscode-docker` | Gerenciamento de containers |

---

Eduardo Felizardo Cândido

Senior QA Automation Engineer | AI-driven Testing | Robot Framework
