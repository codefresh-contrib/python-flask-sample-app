FROM python:3.8.2-alpine3.11

# Set environment
ENV FLASK_APP=flaskr
ENV FLASK_ENV=development

# Copy contents of the current directory to /app in the container
COPY . /app

WORKDIR /app

RUN pip install --editable .

RUN flask init-db

# Unit tests
# RUN pip install pytest && pytest

EXPOSE 5000

CMD [ "flask", "run", "--host=0.0.0.0" ]



