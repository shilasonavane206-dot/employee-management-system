import os


class Config:
    SECRET_KEY = "employee-management-system-2026"

    # Use environment variable for database host (default to 'db' for Docker, 'localhost' for local)
    DB_HOST = os.getenv("DB_HOST", "host.docker.internal")

    SQLALCHEMY_DATABASE_URI = (
        f"postgresql://postgres:NewPassword123@{DB_HOST}:5432/ems_manage_db"
    )

    SQLALCHEMY_TRACK_MODIFICATIONS = False
