from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from app.config import Config
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
app.config.from_object(Config)

# Prometheus application metrics
metrics = PrometheusMetrics(app)

db = SQLAlchemy(app)

from app import routes
