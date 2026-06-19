# Formato Esperado del Challenge de WebAuthn

## Problema Identificado

El endpoint `/lessors/biometric/challenge` NO está devolviendo un challenge válido de WebAuthn.

**Error:** `FormatException: Expected "rp" to be a Map, got Null`

Esto indica que el campo `rp` (relying party) está ausente o es null en la respuesta del servidor.

## Formato Correcto del Challenge

El challenge debe ser un **JSON string** con la siguiente estructura:

```json
{
  "rp": {
    "id": "vivia.com",
    "name": "Vivia"
  },
  "user": {
    "id": "dXNlci1pZC1iYXNlNjQ=",
    "name": "usuario@example.com",
    "displayName": "Nombre del Usuario"
  },
  "challenge": "cmFuZG9tLWNoYWxsZW5nZS1iYXNlNjQ=",
  "pubKeyCredParams": [
    {
      "type": "public-key",
      "alg": -7
    },
    {
      "type": "public-key",
      "alg": -257
    }
  ],
  "authenticatorSelection": {
    "authenticatorAttachment": "platform",
    "requireResidentKey": false,
    "userVerification": "preferred"
  },
  "timeout": 60000,
  "attestation": "none"
}
```

## Descripción de Campos Obligatorios

### 1. `rp` (Relying Party) - **OBLIGATORIO**
```json
{
  "id": "vivia.com",        // Dominio de la aplicación
  "name": "Vivia"            // Nombre legible de la aplicación
}
```

### 2. `user` - **OBLIGATORIO**
```json
{
  "id": "dXNlci1pZC1iYXNlNjQ=",           // ID del usuario en base64
  "name": "usuario@example.com",          // Email del usuario
  "displayName": "Nombre del Usuario"     // Nombre completo del usuario
}
```

### 3. `challenge` - **OBLIGATORIO**
```json
"challenge": "cmFuZG9tLWNoYWxsZW5nZS1iYXNlNjQ="  // Challenge aleatorio en base64
```

### 4. `pubKeyCredParams` - **OBLIGATORIO**
```json
[
  {
    "type": "public-key",
    "alg": -7        // ES256 (Elliptic Curve)
  },
  {
    "type": "public-key",
    "alg": -257      // RS256 (RSA)
  }
]
```

### 5. `authenticatorSelection` - Recomendado
```json
{
  "authenticatorAttachment": "platform",    // Biometría del dispositivo
  "requireResidentKey": false,
  "userVerification": "preferred"           // Verificar con biometría si está disponible
}
```

### 6. `timeout` - Opcional
```json
60000  // 60 segundos en milisegundos
```

### 7. `attestation` - Opcional
```json
"none"  // No requiere attestation
```

## Ejemplo de Respuesta del Endpoint

El endpoint `/lessors/biometric/challenge` debe devolver:

```json
{
  "success": true,
  "data": "{\"rp\":{\"id\":\"vivia.com\",\"name\":\"Vivia\"},\"user\":{\"id\":\"dXNlci1pZC1iYXNlNjQ=\",\"name\":\"usuario@example.com\",\"displayName\":\"Juan Pérez\"},\"challenge\":\"cmFuZG9tLWNoYWxsZW5nZS1iYXNlNjQ=\",\"pubKeyCredParams\":[{\"type\":\"public-key\",\"alg\":-7},{\"type\":\"public-key\",\"alg\":-257}],\"authenticatorSelection\":{\"authenticatorAttachment\":\"platform\",\"requireResidentKey\":false,\"userVerification\":\"preferred\"},\"timeout\":60000,\"attestation\":\"none\"}",
  "message": "Challenge generado exitosamente",
  "status": "200"
}
```

**IMPORTANTE:** El campo `data` debe ser un **string JSON** (no un objeto), por eso está entrecomillado y escapado.

## Algoritmos Criptográficos Soportados

Los valores de `alg` en `pubKeyCredParams`:

- `-7`: ES256 (ECDSA con SHA-256) - **Recomendado para móviles**
- `-257`: RS256 (RSASSA-PKCS1-v1_5 con SHA-256)
- `-8`: EdDSA
- `-37`: PS256 (RSASSA-PSS con SHA-256)

## Generación del Challenge en el Backend

### Ejemplo en Node.js (TypeScript)

```typescript
import { generateRegistrationOptions } from '@simplewebauthn/server';

const options = await generateRegistrationOptions({
  rpName: 'Vivia',
  rpID: 'vivia.com',
  userID: Buffer.from(user.id),
  userName: user.email,
  userDisplayName: `${user.name} ${user.paternalSurname}`,
  attestationType: 'none',
  authenticatorSelection: {
    authenticatorAttachment: 'platform',
    requireResidentKey: false,
    userVerification: 'preferred',
  },
  supportedAlgorithmIDs: [-7, -257], // ES256 y RS256
});

// Convertir a JSON string para enviar al cliente
const challengeJson = JSON.stringify(options);

return {
  success: true,
  data: challengeJson,
  message: 'Challenge generado exitosamente',
  status: '200'
};
```

### Ejemplo en Java (Spring Boot)

```java
import com.webauthn4j.data.*;
import com.fasterxml.jackson.databind.ObjectMapper;

PublicKeyCredentialCreationOptions options =
    new PublicKeyCredentialCreationOptions(
        new PublicKeyCredentialRpEntity("vivia.com", "Vivia"),
        new PublicKeyCredentialUserEntity(
            userId.getBytes(),
            user.getEmail(),
            user.getName() + " " + user.getPaternalSurname()
        ),
        challenge,
        Arrays.asList(
            new PublicKeyCredentialParameters(PublicKeyCredentialType.PUBLIC_KEY, COSEAlgorithmIdentifier.ES256),
            new PublicKeyCredentialParameters(PublicKeyCredentialType.PUBLIC_KEY, COSEAlgorithmIdentifier.RS256)
        ),
        60000L,
        null,
        new AuthenticatorSelectionCriteria(
            AuthenticatorAttachment.PLATFORM,
            false,
            UserVerificationRequirement.PREFERRED
        ),
        AttestationConveyancePreference.NONE,
        null
    );

ObjectMapper mapper = new ObjectMapper();
String challengeJson = mapper.writeValueAsString(options);

return new BiometricChallengeResponse(
    true,
    challengeJson,
    "Challenge generado exitosamente",
    "200"
);
```

## Validación del Challenge

Para verificar que el challenge es válido, debe cumplir:

1. Ser un JSON válido
2. Contener todos los campos obligatorios (`rp`, `user`, `challenge`, `pubKeyCredParams`)
3. El campo `rp.id` debe coincidir con el dominio de la aplicación
4. El campo `user.id` debe estar en base64
5. El campo `challenge` debe ser un string aleatorio en base64 (mínimo 16 bytes)
6. El `challenge` debe guardarse en el servidor para verificarlo después

## Depuración

Con el código actualizado, ahora verás en los logs exactamente qué está devolviendo el servidor:

```
Challenge recibido del servidor: [contenido del challenge]
```

Si el challenge es inválido, verás:

```
Error parseando challenge: [detalles del error]
Challenge data: [datos incorrectos]
```

## Referencias

- [WebAuthn Specification](https://www.w3.org/TR/webauthn-2/)
- [SimpleWebAuthn Library (Node.js)](https://github.com/MasterKale/SimpleWebAuthn)
- [WebAuthn4J (Java)](https://github.com/webauthn4j/webauthn4j)
- [COSE Algorithm Identifiers](https://www.iana.org/assignments/cose/cose.xhtml#algorithms)
