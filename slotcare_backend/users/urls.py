from django.urls import path, include, re_path
from rest_framework.routers import DefaultRouter
from .views import LoginView, RegisterClientView, UserManagementViewSet

# Router per a les vistes de gestió d'usuaris (CRUD)
router = DefaultRouter()
router.register(r'gestion', UserManagementViewSet, basename='gestion') 

urlpatterns = [
    # Rutes d'Autenticació: 
    # Utilitzem re_path amb el símbol '?' al final per fer la barra obliqua opcional.
    re_path(r'^register/?$', RegisterClientView.as_view(), name='register_client'), 
    re_path(r'^login/?$', LoginView.as_view(), name='api_login'),
    
    # Rutes de Gestió d'Usuaris (CRUD i Desbloqueig)
    path('', include(router.urls)), 
]