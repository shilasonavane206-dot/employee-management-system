from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from prometheus_flask_exporter import PrometheusMetrics

from app.config import Config

app = Flask(__name__)
app.config.from_object(Config)

# Prometheus application metrics
metrics = PrometheusMetrics(app)

db = SQLAlchemy(app)

from app import routes  # noqa: F401, E402
