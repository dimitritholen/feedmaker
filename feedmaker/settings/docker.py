import os
from feedmaker.settings.production import *

# Add staticfiles app to INSTALLED_APPS
INSTALLED_APPS = list(INSTALLED_APPS) + ["django.contrib.staticfiles"]

# Database configuration
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": os.path.join(BASE_DIR, "data", "db.sqlite3"),
    }
}

# Cache configuration
# Try to use Redis, but fall back to local memory cache if there are issues
try:
    import redis
    redis_client = redis.Redis(
        host=os.environ.get('REDIS_HOST', 'localhost'),
        port=int(os.environ.get('REDIS_PORT', '6379')),
        db=1,
        socket_connect_timeout=2,
        socket_timeout=2,
    )
    # Test the connection
    redis_client.ping()

    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.redis.RedisCache",
            "LOCATION": f"redis://{os.environ.get('REDIS_HOST', 'localhost')}:{os.environ.get('REDIS_PORT', '6379')}/1",
        }
    }
    print("Using Redis cache backend")
except Exception as e:
    print(f"Redis connection failed: {e}. Using LocMemCache instead.")
    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
            "LOCATION": "unique-snowflake",
        }
    }

# Static files configuration
STATIC_URL = "/static/"
STATIC_ROOT = os.path.join(BASE_DIR, "static")
STATICFILES_DIRS = []

# Ensure directories exist
os.makedirs(os.path.join(BASE_DIR, "data"), exist_ok=True)
os.makedirs(STATIC_ROOT, exist_ok=True)
