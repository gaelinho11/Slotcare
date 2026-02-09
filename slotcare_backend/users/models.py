from django.db import models
from django.contrib.auth.models import AbstractUser

# Tipus de Rol (Requisit 3)
ROL_OPCIONS = (
    ('Superadmin', 'Superadministrador'),
    ('Admin', 'Administrador'),
    ('Client', 'Usuari Final o Client'),
)

class CustomUser(AbstractUser):
    """Model d'usuari personalitzat per SlotCare (Gestió d'Usuaris)."""
    
    # AbstractUser ja proporciona: username, email, first_name, last_name, password
    
    rol = models.CharField(
        max_length=20,
        choices=ROL_OPCIONS,
        default='Client',
        verbose_name='Rol'
    )
    
    # Camps per a Bloqueig i Autenticació (Requisits 2 i 5)
    comptador_intents_fallits = models.IntegerField(default=0, verbose_name='Intents Fallits')
    esta_bloquejat = models.BooleanField(default=False, verbose_name='Bloquejat')
    
    class Meta:
        verbose_name = 'Usuari'
        verbose_name_plural = 'Usuaris'

    def __str__(self):
        return self.username
    
    def desbloquejar_compte(self):
        """Mètode per desbloquejar i resetejar el comptador (Requisit 5)."""
        self.esta_bloquejat = False
        self.comptador_intents_fallits = 0
        self.save()

class RegistreSessio(models.Model):
    """Model per comptabilitzar inicis de sessió (Requisit 4)."""
    
    username = models.CharField(max_length=150)
    data_hora = models.DateTimeField(auto_now_add=True)
    sistema = models.CharField(max_length=50) # Origen (Web/Android/Flutter)
    inici_correcte = models.BooleanField(default=False)
    raó_fallida = models.TextField(null=True, blank=True)
    
    class Meta:
        verbose_name = 'Registre de Sessió'
        verbose_name_plural = 'Registres de Sessions'
        ordering = ['-data_hora']

    def __str__(self):
        return f"[{self.data_hora.strftime('%Y-%m-%d %H:%M')}] {self.username} - {'OK' if self.inici_correcte else 'FAIL'}"