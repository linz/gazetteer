# Contributing to the NZGB Gazetteer App
To contribute to the project certain standards are enforced and must be follow.

## Formatting

Formatting is handled by `black`.

[Black](https://github.com/psf/black) is an uncompromising Python code formatting tool. It takes a Python file as an input, and provides a reformatted Python file as an output, using rules that are a strict subset of PEP 8. It offers very little in the way of configuration (line length being the main exception) in order to achieve formatting consistency. It is deterministic - it will always produce the same output from the same inputs.

The line length configuration is stored in pyproject.toml.

## Linting

Linting is handled by `pylint`.

[Pylint](https://www.pylint.org/) checks Python files in order to detect syntax errors and potential bugs (unreachable code / unused variables), provide refactoring help,

The configuration is stored in .pylintrc.

## Commit message

This repository uses Conventional Commits

This enforces precise rules over how git commit messages can be formatted. This leads to more readable messages that are easy to follow when looking through the project history. But also, the git commit messages are used to generate the chnagelog

### Type

Must be one of the following:

- build: Changes that affect the build system or external dependencies
- ci: Changes to our CI configuration files and scripts
- docs: Documentation only changes
- feat: A new feature
- fix: A bug fix
- perf: A code change that improves performance
- refactor: A code change that neither fixes a bug nor adds a feature
- style: Changes that do not affect the meaning of the code
- test: Adding missing tests or correcting existing tests
- chore: updating grunt tasks etc; no production code change
