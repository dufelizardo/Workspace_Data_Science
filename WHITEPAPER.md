# Whitepaper — Workspace Data Science

**Versão:** 1.0.0
**Data:** 2026-07-09
**Autor:** Eduardo Felizardo
**Repositório:** `C:\dev\Workspace Data Science`

---

## Sumário

1. [Resumo Executivo](#1-resumo-executivo)
2. [Motivação e Escopo](#2-motivação-e-escopo)
3. [Arquitetura do Workspace](#3-arquitetura-do-workspace)
4. [Decisões de Design](#4-decisões-de-design)
5. [Stack Tecnológica](#5-stack-tecnológica)
6. [Análise Comparativa de Ferramentas](#6-análise-comparativa-de-ferramentas)
7. [Fluxo de Trabalho](#7-fluxo-de-trabalho)
8. [Qualidade e Governança de Código](#8-qualidade-e-governança-de-código)
9. [Convenções e Boas Práticas](#9-convenções-e-boas-práticas)
10. [Extensibilidade e Roadmap](#10-extensibilidade-e-roadmap)
11. [Conclusão](#11-conclusão)

---

## 1. Resumo Executivo

Este documento descreve a arquitetura, as decisões técnicas e as práticas adotadas no **Workspace Data Science** — um ambiente Python monorepo dedicado exclusivamente a projetos de análise de dados, visualização e Machine Learning.

A proposta central é oferecer um ambiente de desenvolvimento **reproduzível, versionado e com qualidade de código** desde o início, eliminando o atrito comum em projetos de ciência de dados: ambientes inconsistentes entre máquinas, notebooks não reproduzíveis, ausência de testes e dependências descontroladas.

O workspace é construído sobre Python 3.12 e gerenciado com `uv`, priorizando velocidade de setup, isolamento de projetos e rastreabilidade de dependências via lock file único.

---

## 2. Motivação e Escopo

### 2.1 Problema

Projetos de Data Science historicamente sofrem com:

- **Ambientes frágeis** — `pip install` sem versionamento resulta em ambientes não reproduzíveis
- **Notebooks como produto final** — código de análise que nunca vira módulo testável
- **Ausência de qualidade de código** — sem linting, formatação ou type checking
- **Dependências conflitantes** — múltiplos projetos num único venv global
- **Dados versionados junto ao código** — repositórios pesados e desnecessariamente complexos

### 2.2 Escopo

Este workspace cobre exclusivamente o ciclo:

```
Ingestão → Exploração (EDA) → Transformação → Visualização → Modelagem → Avaliação
```

**Fora de escopo** (workspace separado de AI Engineering):

- Modelos de linguagem (LLMs)
- AI Generativa (RAG, fine-tuning, embeddings)
- Inferência em produção e MLOps avançado (MLflow, Airflow, Kubeflow)

### 2.3 Público-alvo

Cientistas de dados e engenheiros de dados que trabalham com:

- Análise exploratória e estatística
- Modelos de Machine Learning clássico (tabular)
- Relatórios e dashboards baseados em dados

---

## 3. Arquitetura do Workspace

### 3.1 Modelo monorepo com uv workspaces

O workspace adota o modelo **monorepo com uv workspaces**: um único `pyproject.toml` raiz declara as dependências compartilhadas, e cada projeto em `projetos/<nome>/` possui seu próprio `pyproject.toml` com dependências específicas.

```
Workspace Data Science/         ← root do workspace
├── pyproject.toml              ← deps compartilhadas + configs de ferramentas
├── uv.lock                     ← lock único e determinístico (commitado)
├── .venv/                      ← venv compartilhado (gitignored)
└── projetos/
    ├── .gitkeep                ← mantém a pasta no repositório
    ├── .template/              ← scaffolding base (commitado)
    └── <nome-projeto>/         ← gitignored — cada projeto é local
        ├── pyproject.toml      ← deps específicas do projeto
        ├── notebooks/          ← análises (*.ipynb)
        ├── data/               ← raw / processed / outputs (gitignored)
        ├── src/<nome>/         ← módulos Python reutilizáveis
        └── tests/              ← testes unitários e de integração
```

### 3.2 Separação de responsabilidades

| Camada | Localização | Responsabilidade |
|---|---|---|
| Infraestrutura | root `pyproject.toml` | Deps científicas compartilhadas |
| Projeto | `projetos/<nome>/pyproject.toml` | Deps específicas, config pytest |
| Código reutilizável | `src/<nome>/` | Funções, classes, pipelines |
| Exploração | `notebooks/` | EDA, prototipação, relatórios |
| Dados | `data/` | Segregados por estágio; gitignored dentro de cada projeto |

### 3.3 Fluxo de dados dentro de um projeto

```
data/raw/          ← ingestão (CSVs, APIs, bancos)
    ↓
data/processed/    ← limpeza e transformação (código em src/)
    ↓
data/outputs/      ← resultados, predições, relatórios
    ↓
notebooks/         ← visualização e comunicação dos resultados
```

---

## 4. Decisões de Design

### 4.1 Por que `uv` em vez de `pip` + `venv` + `conda`?

`uv` é um gerenciador de pacotes e ambientes Python escrito em Rust, com resolução de dependências 10–100x mais rápida que `pip`. As razões para adotá-lo:

| Critério | pip + venv | conda | **uv** |
|---|---|---|---|
| Velocidade de resolução | Lenta | Moderada | **Ultrarrápida** |
| Lock file determinístico | Parcial (`pip freeze`) | Parcial | **Sim (`uv.lock`)** |
| Suporte a workspaces | Não | Não | **Sim** |
| Compatível com `pyproject.toml` | Sim | Parcial | **Sim** |
| Gerenciamento de Python | Não | Sim | **Sim** |

O lock file `uv.lock` garante que qualquer desenvolvedor que execute `uv sync` obtenha exatamente as mesmas versões de todos os pacotes, incluindo dependências transitivas.

### 4.2 Por que monorepo em vez de repositórios separados?

- **Lock file único** — um único `uv.lock` raiz garante consistência de versões entre projetos
- **Venv compartilhado** — a instalação de deps científicas grandes (NumPy, SciPy, etc.) ocorre uma única vez
- **Configs centralizadas** — Ruff, BasedPyright e pre-commit configurados uma vez no root
- **Scaffolding padronizado** — `novo-projeto.ps1` garante que todos os projetos nasçam com a mesma estrutura

### 4.3 Por que separar dados do código?

Datasets são versionados de forma diferente de código:

- **Mutam frequentemente** e são grandes demais para o Git
- **Contêm informações sensíveis** (PII, dados financeiros) que não devem ir ao repositório
- **São derivados** — dados processados sempre podem ser re-gerados a partir dos brutos com o código

A convenção adotada: código e configuração vão ao Git; dados vão para armazenamento externo (S3, SharePoint, DVC, banco de dados).

### 4.4 Por que dois motores tabulares (Pandas e Polars)?

| Cenário | Ferramenta recomendada |
|---|---|
| Datasets < 1 GB; API familiar; integração com libs legadas | **Pandas** |
| Datasets > 1 GB; performance crítica; lazy evaluation | **Polars** |
| Consultas SQL sobre Parquet/CSV sem servidor | **DuckDB** |

A coexistência dos três cobre todo o espectro de tamanho e complexidade de dados sem forçar uma única abstração.

---

## 5. Stack Tecnológica

### 5.1 Visão geral

```
┌─────────────────────────────────────────────────────────────────┐
│                    AMBIENTE INTERATIVO                          │
│            JupyterLab 4.6  /  Notebook 7.6                     │
├─────────────┬───────────────┬──────────────────────────────────┤
│  DADOS      │  VISUALIZAÇÃO │  MACHINE LEARNING                │
│  NumPy      │  Matplotlib   │  Scikit-learn                    │
│  Pandas     │  Seaborn      │  XGBoost                         │
│  Polars     │  Plotly       │  LightGBM                        │
│  PyArrow    ├───────────────┤  SciPy                           │
│  DuckDB     │  ESTATÍSTICA  │  Statsmodels                     │
│  OpenPyXL   │  SciPy        │                                  │
│             │  Statsmodels  │                                  │
├─────────────┴───────────────┴──────────────────────────────────┤
│                       UTILITÁRIOS                               │
│    python-dotenv  │  Rich  │  Typer  │  HTTPX  │  Pydantic     │
├─────────────────────────────────────────────────────────────────┤
│                  QUALIDADE DE CÓDIGO                            │
│         Ruff  │  BasedPyright  │  Pytest  │  pre-commit        │
├─────────────────────────────────────────────────────────────────┤
│                  INFRAESTRUTURA                                 │
│              Python 3.12  │  uv  │  Git  │  Docker             │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Versões instaladas (2026-07-09)

| Pacote | Versão |
|---|---|
| Python | 3.12.10 |
| jupyterlab | 4.6.1 |
| notebook | 7.6.0 |
| ipykernel | 7.3.0 |
| numpy | 2.5.1 |
| pandas | 3.0.3 |
| polars | 1.42.1 |
| pyarrow | 24.0.0 |
| openpyxl | 3.1.5 |
| duckdb | 1.5.4 |
| matplotlib | 3.11.0 |
| plotly | 6.9.0 |
| seaborn | 0.13.2 |
| scikit-learn | 1.9.0 |
| xgboost | 3.3.0 |
| lightgbm | 4.6.0 |
| scipy | 1.18.0 |
| statsmodels | 0.14.6 |
| pytest | 9.1.1 |
| pytest-cov | 7.1.0 |
| python-dotenv | 1.2.2 |
| rich | 15.0.0 |
| typer | 0.26.8 |
| httpx | 0.28.1 |
| pydantic | 2.13.4 |
| ruff | 0.15.20 |
| basedpyright | 1.39.9 |
| pre-commit | 4.6.0 |

---

## 6. Análise Comparativa de Ferramentas

### 6.1 Manipulação de dados

| Critério | Pandas | Polars | DuckDB |
|---|---|---|---|
| API | Orientada a índice | Orientada a expressão | SQL |
| Performance (grande volume) | Média | Alta | Alta |
| Lazy evaluation | Não | Sim | Sim |
| Uso de memória | Alto | Baixo (zero-copy) | Baixo |
| Curva de aprendizado | Baixa | Média | Baixa (SQL) |
| Ecossistema / integrações | Muito grande | Crescente | Crescente |

**Recomendação:** começar com Pandas para familiaridade; migrar para Polars ou DuckDB quando o volume de dados exigir.

### 6.2 Machine Learning

| Critério | Scikit-learn | XGBoost | LightGBM |
|---|---|---|---|
| Algoritmos | Amplo (clássicos) | Gradient Boosting | Gradient Boosting |
| Performance tabular | Boa | Muito boa | Excelente |
| Velocidade de treino | Variável | Rápida | Muito rápida |
| Uso de memória | Variável | Moderado | Baixo |
| API | Pipeline padrão | Scikit-learn API | Scikit-learn API |

**Recomendação:** Scikit-learn para pré-processamento e algoritmos clássicos; XGBoost como baseline sólido; LightGBM para datasets grandes (> 500k linhas).

### 6.3 Visualização

| Critério | Matplotlib | Seaborn | Plotly |
|---|---|---|---|
| Tipo de output | Estático | Estático | Interativo |
| Controle de layout | Total | Limitado | Alto |
| Facilidade de uso | Baixa | Alta | Média |
| EDA rápida | Não | Sim | Sim |
| Exportação HTML | Não | Não | Sim |

**Recomendação:** Seaborn para EDA; Plotly para apresentações e relatórios interativos; Matplotlib quando precisar de controle total de layout.

### 6.4 Gerenciamento de pacotes

| Critério | pip + venv | conda | Poetry | **uv** |
|---|---|---|---|---|
| Velocidade | Lenta | Lenta | Média | **Ultrarrápida** |
| Lock file | pip freeze | Parcial | Sim | **Sim** |
| Workspaces | Não | Não | Não | **Sim** |
| Gerencia Python | Não | Sim | Não | **Sim** |
| Compatível com PyPI | Sim | Parcial | Sim | **Sim** |

---

## 7. Fluxo de Trabalho

### 7.1 Criação de um novo projeto

```powershell
# 1. Scaffolding
.\novo-projeto.ps1 -Nome "analise-churn"

# 2. Atualizar venv
uv sync

# 3. Adicionar deps específicas do projeto
uv add imbalanced-learn --package analise-churn

# 4. Iniciar exploração
cd projetos\analise-churn
uv run jupyter lab
```

### 7.2 Ciclo de análise dentro de um projeto

```
01_exploracao.ipynb     ← entender a estrutura dos dados
02_limpeza.ipynb        ← tratar nulos, outliers, tipos
03_feature_eng.ipynb    ← criar e selecionar features
04_modelo.ipynb         ← treinar, validar e comparar modelos
05_avaliacao.ipynb      ← métricas, curvas ROC, importância de features
06_relatorio.ipynb      ← comunicação dos resultados
```

Funções reutilizadas entre notebooks são extraídas para `src/<nome>/`.

### 7.3 Promoção de notebook para módulo

Quando uma transformação ou pipeline de features se estabiliza no notebook, ela deve ser extraída para um módulo Python testável:

```
notebooks/02_limpeza.ipynb
    → src/analise_churn/preprocessing.py
        → tests/test_preprocessing.py
```

Isso garante que o código crítico tenha cobertura de testes e possa ser reutilizado por outros notebooks ou scripts.

### 7.4 Controle de versão e commit

```powershell
# Antes do commit — limpar outputs dos notebooks
uv run jupyter nbconvert --clear-output --inplace notebooks/*.ipynb

# pre-commit executa automaticamente no git commit:
# ruff check (lint) + ruff format + trailing-whitespace + large-files
git add pyproject.toml uv.lock .pre-commit-config.yaml CLAUDE.md README.md
git commit -m "feat: adicionar pipeline de feature engineering"
```

> Projetos individuais (`projetos/<nome>/`) são gitignored e não entram no commit do workspace.
> Para versionar o código de um projeto, inicializar um repositório Git separado dentro dele.

---

## 8. Qualidade e Governança de Código

### 8.1 Linting e formatação — Ruff

Ruff substitui `flake8`, `isort` e `black` com uma única ferramenta escrita em Rust, 10–100x mais rápida.

Regras ativadas neste workspace:

| Prefixo | Origem | Exemplos de verificação |
|---|---|---|
| `E`, `W` | pycodestyle | Indentação, espaçamentos |
| `F` | pyflakes | Imports não usados, variáveis indefinidas |
| `I` | isort | Ordem de imports |
| `B` | flake8-bugbear | Armadilhas comuns (mutable defaults, etc.) |
| `C4` | flake8-comprehensions | Simplificação de list/dict comprehensions |
| `UP` | pyupgrade | Sintaxe moderna (f-strings, `|` para union types) |
| `N` | pep8-naming | Convenções de nomenclatura PEP 8 |
| `SIM` | flake8-simplify | Simplificação de estruturas condicionais |

### 8.2 Type checking — BasedPyright

BasedPyright é um fork do Pyright (Microsoft) com verificações mais rigorosas. Configurado em modo `standard` para equilibrar rigor e produtividade.

Benefícios práticos em Data Science:

- Detecta erros de tipo em transformações Pandas/Polars antes de executar
- Valida schemas Pydantic em tempo de desenvolvimento
- Autocompletar mais preciso no VS Code via Pylance

### 8.3 Testes — Pytest

Estrutura de testes recomendada por projeto:

```
tests/
├── test_preprocessing.py   ← funções de limpeza e transformação
├── test_features.py        ← feature engineering
├── test_model.py           ← asserções sobre output do modelo
└── conftest.py             ← fixtures compartilhadas (dados sintéticos)
```

**Princípio:** testar módulos Python (`src/`), não notebooks. Notebooks são artefatos de exploração; o código que vai para produção ou é reutilizado deve estar em módulos com testes.

### 8.4 Pre-commit hooks

| Hook | Ação |
|---|---|
| `ruff` | Lint com fix automático |
| `ruff-format` | Formatação automática |
| `trailing-whitespace` | Remove espaços no final de linha |
| `end-of-file-fixer` | Garante newline ao final dos arquivos |
| `check-yaml` | Valida sintaxe YAML |
| `check-toml` | Valida sintaxe TOML |
| `check-merge-conflict` | Bloqueia arquivos com marcadores de conflito |
| `debug-statements` | Bloqueia `print()` / `breakpoint()` acidentais |
| `check-added-large-files` | Bloqueia arquivos > 10 MB (datasets) |

---

## 9. Convenções e Boas Práticas

### 9.1 Nomenclatura de projetos

```
analise-<dominio>       # ex.: analise-churn, analise-vendas
modelo-<objetivo>       # ex.: modelo-previsao-demanda
etl-<fonte>-<destino>   # ex.: etl-api-warehouse
relatorio-<periodo>     # ex.: relatorio-mensal-kpis
```

### 9.2 Notebooks

- Prefixo numérico indica sequência lógica: `01_`, `02_`, `03_`
- Cada notebook tem um único propósito (exploração, limpeza, modelo)
- Outputs são sempre limpos antes do commit (`nbconvert --clear-output`)
- Nunca colocar credenciais, URLs privadas ou dados sensíveis em notebooks

### 9.3 Dados

| Pasta | Conteúdo | Gitignored |
|---|---|---|
| `data/raw/` | Dados brutos; nunca modificados diretamente | Sim |
| `data/processed/` | Dados após limpeza e transformação | Sim |
| `data/outputs/` | Predições, relatórios, exports | Sim |

Datasets grandes (> 10 MB) devem usar armazenamento externo:

- **Arquivos:** S3, Azure Blob, SharePoint
- **Bancos:** PostgreSQL, BigQuery, Databricks
- **Versionamento de dados:** DVC (Data Version Control)

### 9.4 Variáveis de ambiente

Nunca hardcodar credenciais ou configurações sensíveis no código. Usar `.env` (gitignored) com base em `.env.example` (versionado):

```python
from dotenv import load_dotenv
import os

load_dotenv()
DB_URL = os.getenv("DATABASE_URL")
```

### 9.5 Deps específicas de projeto

Quando um projeto precisar de uma biblioteca não presente no root (ex.: `imbalanced-learn`, `optuna`, `shap`), adicioná-la ao `pyproject.toml` do projeto, nunca ao root:

```powershell
uv add optuna --package analise-churn
```

Isso mantém o venv raiz enxuto e evita conflitos entre projetos.

---

## 10. Extensibilidade e Roadmap

### 10.1 Integrações futuras possíveis

| Ferramenta | Caso de uso |
|---|---|
| **MLflow** | Rastreamento de experimentos e registro de modelos |
| **Optuna** | Otimização de hiperparâmetros |
| **SHAP** | Explicabilidade de modelos (feature importance) |
| **DVC** | Versionamento de datasets e pipelines de dados |
| **Great Expectations** | Validação e qualidade de dados |
| **Evidently** | Monitoramento de drift em produção |

Estas ferramentas são intencionalmente deixadas fora do workspace base para manter o ambiente enxuto; podem ser adicionadas por projeto conforme necessidade.

### 10.2 Escalonamento para AI Engineering

Quando um projeto evoluir para usar LLMs, embeddings ou AI Generativa, ele deve ser migrado para o **Workspace AI Engineering** (workspace separado), que conterá:

- SDKs de modelos (Anthropic, OpenAI)
- Frameworks de agentes
- Vector databases (Chroma, Pinecone)
- Ferramentas de observabilidade de LLMs

A separação é intencional: dependências de AI Engineering são pesadas e têm ciclos de atualização diferentes das libs científicas clássicas.

---

## 11. Conclusão

O **Workspace Data Science** resolve os problemas mais comuns em ambientes de ciência de dados ao estabelecer:

1. **Reproduzibilidade** — `uv.lock` garante que qualquer `uv sync` resulta no ambiente exato
2. **Isolamento** — monorepo com workspaces separa deps por projeto sem duplicar o venv
3. **Qualidade desde o início** — Ruff, BasedPyright e pre-commit integrados ao fluxo de commit
4. **Estrutura escalável** — notebooks para exploração, módulos para código reutilizável, testes para código crítico
5. **Dados separados do código** — convenção explícita que previne commits acidentais de datasets

A stack foi escolhida para cobrir desde a exploração inicial de dados até o treinamento de modelos de ML clássico, sem incluir ferramentas que seriam mais adequadas para outros contextos (AI Engineering, MLOps avançado), mantendo o ambiente focado e com baixo tempo de setup.

---

*Documento gerado em 2026-07-09. Para atualizações de versões, consulte [REQUIREMENTS.md](REQUIREMENTS.md).*

---

Eduardo Felizardo Cândido

Senior QA Automation Engineer | AI-driven Testing | Robot Framework
