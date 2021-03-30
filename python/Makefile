install:
	pip install --upgrade pip &&\
		pip install -r requirements.txt

test:
	python -m pytest -vv --cov=papaoutai_main test_papaoutai.py 

format:
	black *.py

lint:
	pylint --disable=R,C papaoutai_main.py

all: install lint test