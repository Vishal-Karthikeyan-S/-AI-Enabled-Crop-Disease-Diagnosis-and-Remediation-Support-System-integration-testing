from celery import Celery

celery = Celery(
    "app",
    broker="redis://localhost:6379/0",
    backend="redis://localhost:6379/0",
    include=["app.tasks.ml_task"]   # ⭐ FORCE LOAD TASK
)

# For testing without Redis on Windows, force eager execution (sync)
celery.conf.task_always_eager = True
