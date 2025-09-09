# -------- Make targets --------
.PHONY: help setup test dvc-repro dvc-push clean

help:
	@echo "Targets:"
	@echo "  setup      - create venv and install requirements"
	@echo "  test       - run unit tests with pytest"
	@echo "  dvc-repro  - run the full DVC pipeline"
	@echo "  dvc-push   - push tracked artifacts to the configured DVC remote"
	@echo "  clean      - remove python/dvc build artifacts"

VENV?=.venv
PY?=$(VENV)/bin/python
PIP?=$(VENV)/bin/pip

setup:
	python -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

test:
	pytest -q --disable-warnings --maxfail=1

dvc-repro:
	dvc repro

dvc-push:
	dvc push

clean:
	rm -rf __pycache__ .pytest_cache .dvc/tmp dvclive
	find . -name "*.pyc" -delete
