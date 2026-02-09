from rest_framework import serializers
from .models import CustomUser
from .validators import SlotCarePasswordValidator

class CustomUserSerializer(serializers.ModelSerializer):
    # ... (aquest serialitzador és per a la gestió CRUD, no per al registre)
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'rol', 'esta_bloquejat', 'comptador_intents_fallits']
        read_only_fields = ['comptador_intents_fallits'] 
        

class UserCreationSerializer(serializers.ModelSerializer):
    """Serialitzador per a la creació d'usuaris (Requisit 1)."""
    password = serializers.CharField(
        write_only=True, 
        required=True, 
        style={'input_type': 'password'},
        validators=[SlotCarePasswordValidator()] # Apliquem el validador estricte
    )
    
    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'first_name', 'last_name', 'password', 'rol']
        extra_kwargs = {
            # Assegurem que aquests camps siguin obligatoris.
            'first_name': {'required': True}, 
            'last_name': {'required': True}, 
            'rol': {'required': False, 'default': 'Client'},
        }

    def create(self, validated_data):
        # Aquesta crida ha de ser correcta i utilitzar totes les dades.
        user = CustomUser.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],
            rol=validated_data.get('rol', 'Client') 
        )
        return user