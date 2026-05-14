"""
URL configuration for wasteworth_backend project.

The `urlpatterns` list routes URLs to views.
https://docs.djangoproject.com/en/6.0/topics/http/urls/
"""

from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include
from rest_framework.authtoken import views as drf_auth_views

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include("core.urls")),  # register/login/me/pickups...
    path("api-token-auth/", drf_auth_views.obtain_auth_token, name="api_token_auth"),
]

# ✅ Serve uploaded media files in development (DEBUG=True)
# This makes URLs like /media/pickup_photos/xxx.jpg open correctly. [web:1003]
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
