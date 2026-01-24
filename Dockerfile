# ETAPA 1: Construir la App Web con Flutter
FROM ghcr.io/cirruslabs/flutter:3.19.0 AS build

WORKDIR /app

# Copiamos los archivos del proyecto
COPY . .

# Descargamos dependencias y construimos la versión Web
RUN flutter pub get
RUN flutter build web --release

# ETAPA 2: Servir la App con Nginx (Servidor Web rápido)
FROM nginx:alpine

# Copiamos los archivos construidos al servidor
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponemos el puerto 80 (Estándar web)
EXPOSE 80

# Arrancamos Nginx
CMD ["nginx", "-g", "daemon off;"]