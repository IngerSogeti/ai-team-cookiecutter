.DEFAULT_GOAL := test
sources = hooks
isort = pdm run isort $(sources) tests
black = pdm run black --target-version py37 $(sources) tests

.PHONY: install
install:
	pdm install --dev
	pdm run pre-commit install

.PHONY: update
update:
	@echo "-------------------------"
	@echo "- Updating dependencies -"
	@echo "-------------------------"

	pdm update --no-sync --update-eager
	pdm sync --clean

	@echo "\a"

.PHONY: update-production
update-production:
	@echo "------------------------------------"
	@echo "- Updating production dependencies -"
	@echo "------------------------------------"

	pdm update --production --no-sync --update-eager
	pdm sync --clean

	@echo "\a"

.PHONY: outdated
outdated:
	@echo "-------------------------"
	@echo "- Outdated dependencies -"
	@echo "-------------------------"

	pdm update --dry-run --unconstrained

	@echo "\a"

.PHONY: format
format:
	@echo "----------------------"
	@echo "- Formating the code -"
	@echo "----------------------"

	$(isort)
	$(black)

	@echo ""

.PHONY: lint
lint:
	@echo "--------------------"
	@echo "- Testing the lint -"
	@echo "--------------------"

	pdm run flake8 $(sources) tests
	{%- if cookiecutter.use_mypy == 'True' %}
	mypy $(sources) tests
	{%- endif %}

	$(isort) --check-only --df
	$(black) --check --diff

	@echo ""

.PHONY: mypy
mypy:
	@echo "----------------"
	@echo "- Testing mypy -"
	@echo "----------------"

	pdm run mypy $(sources) tests

	@echo ""

.PHONY: test
test: test-code test-examples

	@echo "\a"

.PHONY: test-code
test-code:
	@echo "----------------"
	@echo "- Testing code -"
	@echo "----------------"

	pdm run pytest --cov-report term-missing --cov $(sources) tests ${ARGS}

	@echo ""


.PHONY: all
all: lint mypy test security build-docs

	@echo "\a"

.PHONY: docs
docs:
	@echo "-------------------------"
	@echo "- Serving documentation -"
	@echo "-------------------------"

	pdm run mkdocs serve

	@echo ""

.PHONY: bump
bump: pull-main bump-version build-package upload-pypi clean

	@echo "\a"

.PHONY: pull-main
pull-main:
	@echo "------------------------"
	@echo "- Updating repository  -"
	@echo "------------------------"

	git checkout main
	git pull

	@echo ""

.PHONY: build-package
build-package: clean
	@echo "------------------------"
	@echo "- Building the package -"
	@echo "------------------------"

	pdm build

	@echo ""

.PHONY: build-docs
build-docs:
	@echo "--------------------------"
	@echo "- Building documentation -"
	@echo "--------------------------"

	pdm run mkdocs build --strict

	@echo ""

.PHONY: bump-version
bump-version:
	@echo "---------------------------"
	@echo "- Bumping program version -"
	@echo "---------------------------"

	pdm run cz bump --changelog --no-verify
	git push
	git push --tags

	@echo ""

.PHONY: security
security:
	@echo "--------------------"
	@echo "- Testing security -"
	@echo "--------------------"

	pdm run safety check
	@echo ""
	pdm run bandit -r $(sources)

	@echo ""

.PHONY: clean
ifeq ($(OS),Windows_NT)
clean:
	@echo "---------------------------"
	@echo "- Cleaning unwanted files Windows-"
	@echo "---------------------------"

	if exist *.bak del /q /s *.bak
	if exist *.pyc del /q /s *.pyc
	if exist *.egg-info del /q /s *.egg-info
	if exist .coverage del /q /s .coverage
	if exist __pycache_ then rmdir /q /s __pycache__
	if exist .pytest_cache rmdir /q /s .pytest_cache
	if exist dist rmdir /q /s dist
	if exist build rmdir /q /s build
	if exist site rmdir /q /s site
	if exist .tox rmdir /q /s .tox
	if exist ai_team_cookiecutter.egg-info rmdir /q /s ai_team_cookiecutter.egg-info
else
clean:
	@echo "---------------------------"
	@echo "- Cleaning unwanted files Linux-"
	@echo "---------------------------"

	rm -rf `find . -name __pycache__`
	rm -f `find . -type f -name '*.py[co]' `
	rm -f `find . -type f -name '*.rej' `
	rm -rf `find . -type d -name '*.egg-info' `
	rm -rf `find . -type d -name '.mypy_cache' `
	rm -f `find . -type f -name '*~' `
	rm -f `find . -type f -name '.*~' `
	rm -rf .cache
	rm -rf .pytest_cache
	rm -rf .mypy_cache
	rm -rf htmlcov
	rm -f .coverage
	rm -f .coverage.*
	rm -rf build
	rm -rf dist
	rm -f $(sources)/*.c pydantic/*.so
	rm -rf site
	rm -rf docs/_build
	rm -rf docs/.changelog.md docs/.version.md docs/.tmp_schema_mappings.html
	rm -rf codecov.sh
	rm -rf coverage.xml
endif

.PHONY: coverage
coverage:
	pdm run pytest --cov=$(sources) --cov-branch --cov-report=term-missing tests
