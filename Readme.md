# Port Scanner para Redes Internas en Hack The Box

Este script es un port scanner personalizado para identificar puertos abiertos en un rango de direcciones IP en situaciones donde Python y herramientas comunes como Nmap no están disponibles o requieren permisos de administrador. 
Está diseñado específicamente para entornos de CTF como Hack The Box, donde se necesita obtener información sobre la red interna y los puertos de contenedores de Docker o similares desde una máquina víctima con permisos limitados.

## Características
- Escaneo de puertos en un rango de direcciones IP especificado.
- Verificación de la actividad de las IPs en la red antes de escanear los puertos.
- Validación de parámetros de entrada: puertos, IPs y máscara en formato CIDR.
- Gestión de señal `Ctrl+C` para detener el script en cualquier momento.
- Salida en colores, facilitando la identificación de mensajes de error, éxito y advertencias.

## Uso
Este script permite especificar un rango de puertos y una red en formato CIDR para el escaneo. Además, incorpora validaciones y un pequeño sistema de ayuda para guiar al usuario. En resumen:
```bash
./portscanner.sh <puerto_inicial> <puerto_final> <red/máscara>
```

Ejemplo:
```bash
./portscanner.sh 80 90 172.17.0.0/24
```

Este script se convierte en una herramienta útil cuando las opciones están limitadas y se requiere recopilar información de red para avanzar en el compromiso de la máquina objetivo.
