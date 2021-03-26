install:
	pip install --upgrade pip &&\
		pip install -r requirements.txt

test:
	python -m pytest -vv test_papaoutai.py

format:
	black *.py

lint:
	pylint --disable=R,C main_papaoutai.py

all: install lint test