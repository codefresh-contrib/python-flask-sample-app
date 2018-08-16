FROM python:3.6.4-alpine3.6

ENV FLASK_APP=minitwit

COPY . /app

WORKDIR /app

RUN pip install --editable .

RUN flask initdb

# Unit tests
# python setup.py test

EXPOSE 5000


CMD [ "flask", "run", "--host=0.0.0.0" ]



