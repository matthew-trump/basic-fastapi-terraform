.PHONY: run test

run:
	. .venv/bin/activate && uvicorn app.main:app --host 127.0.0.1 --port 8011 --reload

test:
	. .venv/bin/activate && python -m pytest
