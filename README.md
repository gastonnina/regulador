# regulador.sh
Script que ayuda en la instalación de servicio Proxy [**"squid"**](https://en.wikipedia.org/wiki/Squid_(software)) y Filtrador de contenido [**"e2guardian"**](http://e2guardian.org/cms/index.php)

## Requerimientos

- Se asume se tiene acceso a servidor por ssh con un usuario root
- Tener conexión a internet

## Insalación

- Se debe copiar el archivo `regulador.sh` y toda la carpeta  `tools_regulador` con su contenido a `/usr/local/bin/` del servidor *( esto se ouede hacer tambien con ayuda de Filezilla )*


![Regulador patalla inslacion](img_instalacion.png?raw=true "Regulador patalla inslacion")
# Uso

Se puede ver en el video

[![VIDEO](https://img.youtube.com/vi/6ZKh3Jlf8NA/0.jpg)](https://www.youtube.com/watch?v=6ZKh3Jlf8NA)


Para poder obtener ayuda del script basta con ejecutar sin parametros

```bash
regulador.sh
```
![Regulador patalla ayuda](img_ayuda.png?raw=true "Regulador patalla ayuda")

Para configurar la red de las interfaces, se asume se tiene ya configurado a internet en interfaz principal y se corre el siguiente comando (se aconseja reiniciar equipo despues de ello)
Este preguntara por los nombres de interfaz de red

```bash
regulador.sh red
```

Para proceder a la instalación se ejecuta

```bash
regulador.sh instalar
```